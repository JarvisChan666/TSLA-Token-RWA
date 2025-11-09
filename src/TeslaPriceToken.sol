// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {OracleLib, AggregatorV3Interface} from "./library/OracleLib.sol";

/**
 * @title TeslaPriceToken (TPT)
 * @notice 基于ETH超额抵押的TSLA价格关联代币
 * @dev 核心机制说明：
 * - 超额抵押机制：用户需提供至少200%的ETH抵押才能铸造TPT
 * - 价格预言机集成：使用Chainlink获取TSLA和ETH实时价格
 * - ERC20兼容：完全符合ERC20标准，支持DeFi生态集成
 * - 健康因子系统：抵押率低于150%将触发清算
 * - 紧急暂停：管理员可暂停合约应对风险（详见Deploy.s.sol）
 */

contract TeslaPriceToken is ERC20, Ownable, ReentrancyGuard, Pausable {
    using OracleLib for AggregatorV3Interface;

    error TeslaPriceToken__InsufficientCollateral();

    // 价格馈送地址
    address private i_tslaFeed;
    address private i_ethUsdFeed;
    
    // 常量参数
    uint256 public constant DECIMALS = 8;
    uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 public constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 需要200%超额抵押
    uint256 private constant LIQUIDATION_BONUS = 10; // 清算时10%折扣
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    
    // 用户状态映射
    mapping(address user => uint256 tslaMinted) public s_tslaMintedPerUser;
    mapping(address user => uint256 ethCollateral) public s_ethCollateralPerUser;

    // 事件
    event TokensMinted(address indexed to, uint256 ethAmount, uint256 tokenAmount);
    event TokensRedeemed(address indexed from, uint256 ethAmount, uint256 tokenAmount);
    event CollateralAdded(address indexed user, uint256 ethAmount);
    event CollateralWithdrawn(address indexed user, uint256 ethAmount);

    /**
     * @dev 构造函数
     * @param _tslaFeed TSLA/USD价格馈送地址
     * @param _ethUsdFeed ETH/USD价格馈送地址
     */
    constructor(address _tslaFeed, address _ethUsdFeed) ERC20("Tesla Stock Token", "TST") Ownable(msg.sender) {
        i_tslaFeed = _tslaFeed;
        i_ethUsdFeed = _ethUsdFeed;
    }

    /**
     * @dev 存入ETH并铸造TSLA代币
     * @param amountToMint 要铸造的代币数量
     */
    function depositAndMint(uint256 amountToMint) external payable nonReentrant whenNotPaused {
        require(amountToMint > 0, "Amount must be greater than 0");
        require(msg.value > 0, "Must send ETH");
        
        // 更新用户状态
        s_ethCollateralPerUser[msg.sender] += msg.value;
        s_tslaMintedPerUser[msg.sender] += amountToMint;

        // 检查健康因子
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert TeslaPriceToken__InsufficientCollateral();
        }
        
        // 铸造代币
        _mint(msg.sender, amountToMint);
        emit TokensMinted(msg.sender, msg.value, amountToMint);
    }

    /**
     * @dev 赎回代币并取回ETH
     * @param amountToRedeem 要赎回的代币数量
     */
    function redeemAndBurn(uint256 amountToRedeem) external nonReentrant whenNotPaused {
        require(amountToRedeem > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amountToRedeem, "Insufficient token balance");
        
        // 计算可赎回的ETH数量
        uint256 valueRedeemed = getUsdAmountFromTsla(amountToRedeem);
        uint256 ethToReturn = getEthAmountFromUsd(valueRedeemed);
        
        // 更新用户状态
        s_tslaMintedPerUser[msg.sender] -= amountToRedeem;
        
        // 检查赎回后的健康因子
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert TeslaPriceToken__InsufficientCollateral();
        }
        
        // 销毁代币并返还ETH
        _burn(msg.sender, amountToRedeem);
        emit TokensRedeemed(msg.sender, ethToReturn, amountToRedeem);
        
        (bool success,) = msg.sender.call{value: ethToReturn}("");
        if (!success) {
            revert("ETH transfer failed");
        }
    }

    /**
     * @dev 添加抵押品（仅增加ETH，不铸造代币）
     */
    function addCollateral() external payable nonReentrant whenNotPaused {
        require(msg.value > 0, "Must send ETH");
        s_ethCollateralPerUser[msg.sender] += msg.value;
        emit CollateralAdded(msg.sender, msg.value);
    }

    /**
     * @dev 提取抵押品（需要保持健康因子）
     * @param ethAmount 要提取的ETH数量
     */
    function withdrawCollateral(uint256 ethAmount) external nonReentrant whenNotPaused {
        require(ethAmount > 0, "Amount must be greater than 0");
        require(s_ethCollateralPerUser[msg.sender] >= ethAmount, "Insufficient collateral");
        
        // 更新用户状态
        s_ethCollateralPerUser[msg.sender] -= ethAmount;
        
        // 检查提取后的健康因子
        uint256 healthFactor = getHealthFactor(msg.sender);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert TeslaPriceToken__InsufficientCollateral();
        }
        
        emit CollateralWithdrawn(msg.sender, ethAmount);
        
        (bool success,) = msg.sender.call{value: ethAmount}("");
        if (!success) {
            revert("ETH transfer failed");
        }
    }

    /**
     * @dev 获取用户健康因子
     * @param user 用户地址
     * @return 健康因子值
     */
    function getHealthFactor(address user) public view returns (uint256) {
        (uint256 totalTslaMintedValueInUsd, uint256 totalCollateralEthValueInUsd) = getAccountInformationValue(user);
        return _calculateHealthFactor(totalTslaMintedValueInUsd, totalCollateralEthValueInUsd);
    }

    /**
     * @dev 根据TSLA代币数量获取USD价值
     * @param amountTslaInWei TSLA代币数量
     * @return USD价值
     */
    function getUsdAmountFromTsla(uint256 amountTslaInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_tslaFeed);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (amountTslaInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    /**
     * @dev 根据ETH数量获取USD价值
     * @param ethAmountInWei ETH数量
     * @return USD价值
     */
    function getUsdAmountFromEth(uint256 ethAmountInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_ethUsdFeed);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (ethAmountInWei * (uint256(price) * ADDITIONAL_FEED_PRECISION)) / PRECISION;
    }

    /**
     * @dev 根据USD价值获取ETH数量
     * @param usdAmountInWei USD价值
     * @return ETH数量
     */
    function getEthAmountFromUsd(uint256 usdAmountInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_ethUsdFeed);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (usdAmountInWei * PRECISION) / ((uint256(price) * ADDITIONAL_FEED_PRECISION));
    }

    /**
     * @dev 获取用户账户信息
     * @param user 用户地址
     * @return totalTslaMintedValueUsd 用户铸造的TSLA代币总价值(USD)
     * @return totalCollateralValueUsd 用户抵押的ETH总价值(USD)
     */
    function getAccountInformationValue(address user)
        public
        view
        returns (uint256 totalTslaMintedValueUsd, uint256 totalCollateralValueUsd)
    {
        (uint256 totalTslaMinted, uint256 totalCollateralEth) = _getAccountInformation(user);
        totalTslaMintedValueUsd = getUsdAmountFromTsla(totalTslaMinted);
        totalCollateralValueUsd = getUsdAmountFromEth(totalCollateralEth);
    }

    /**
     * @dev 计算健康因子
     * @param tslaMintedValueUsd TSLA代币价值
     * @param collateralValueUsd 抵押品价值
     * @return 健康因子
     */
    function _calculateHealthFactor(uint256 tslaMintedValueUsd, uint256 collateralValueUsd)
        internal
        pure
        returns (uint256)
    {
        if (tslaMintedValueUsd == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / tslaMintedValueUsd;
    }

    /**
     * @dev 获取用户账户信息
     * @param user 用户地址
     * @return totalTslaMinted 用户铸造的TSLA代币总量
     * @return totalCollateralEth 用户抵押的ETH总量
     */
    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalTslaMinted, uint256 totalCollateralEth)
    {
        totalTslaMinted = s_tslaMintedPerUser[user];
        totalCollateralEth = s_ethCollateralPerUser[user];
    }

    /**
     * @dev 获取TSLA价格
     * @return TSLA/USD价格
     */
    function getTslaPrice() public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_tslaFeed);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return price;
    }

    /**
     * @dev 获取ETH价格
     * @return ETH/USD价格
     */
    function getEthPrice() public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_ethUsdFeed);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return price;
    }

    /**
     * @dev 暂停合约
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev 恢复合约
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev 紧急提取ETH
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev 更新TSLA价格馈送地址
     */
    function updateTslaPriceFeed(address _tslaFeed) external onlyOwner {
        i_tslaFeed = _tslaFeed;
    }

    /**
     * @dev 更新ETH价格馈送地址
     */
    function updateEthPriceFeed(address _ethUsdFeed) external onlyOwner {
        i_ethUsdFeed = _ethUsdFeed;
    }
}