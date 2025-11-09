// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TeslaPriceToken} from "../src/TeslaPriceToken.sol";
import {DeployTeslaPriceToken} from "../script/DeployTeslaPriceToken.s.sol";

contract TeslaPriceTokenTest is Test {
    TeslaPriceToken public token;
    DeployTeslaPriceToken public deployer;
    
    // 测试用户地址
    address private constant USER = address(0x1);
    address private constant LIQUIDATOR = address(0x2);
    
    // 事件定义
    event TokensMinted(address indexed to, uint256 ethAmount, uint256 tokenAmount);
    event TokensRedeemed(address indexed from, uint256 ethAmount, uint256 tokenAmount);
    event CollateralAdded(address indexed user, uint256 ethAmount);
    event CollateralWithdrawn(address indexed user, uint256 ethAmount);
    
    // 测试参数
    uint256 private constant TSLA_PRICE = 200 * 1e8; // $200 with 8 decimals
    uint256 private constant ETH_PRICE = 2000 * 1e8; // $2000 with 8 decimals
    uint256 private constant STARTING_BALANCE = 100 ether;
    
    function setUp() public {
        // 部署合约
        deployer = new DeployTeslaPriceToken();
        token = deployer.run();
        
        // 给测试用户一些初始ETH
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(LIQUIDATOR, STARTING_BALANCE);
    }
    
    function testConstructor() public {
        assertEq(token.name(), "Tesla Stock Token");
        assertEq(token.symbol(), "TST");
        assertEq(token.totalSupply(), 0);
    }
    
    function testGetTslaPrice() public {
        int256 price = token.getTslaPrice();
        assertEq(price, TSLA_PRICE);
    }
    
    function testGetEthPrice() public {
        int256 price = token.getEthPrice();
        assertEq(price, ETH_PRICE);
    }
    
    function testDepositAndMint() public {
        uint256 ethAmount = 1 ether; // 1 ETH
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount); // $2000 worth of ETH
        uint256 expectedTokens = token.getEthAmountFromUsd(ethValueInUsd); // 1 ETH worth of tokens
        
        vm.prank(USER);
        vm.expectEmit(true, true, true, true);
        emit TokensMinted(USER, ethAmount, expectedTokens);
        
        token.depositAndMint{value: ethAmount}(expectedTokens);
        
        assertEq(token.balanceOf(USER), expectedTokens);
        assertEq(token.totalSupply(), expectedTokens);
    }
    
    function testRedeemAndBurn() public {
        // 先铸造一些代币
        uint256 ethAmount = 1 ether;
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd);
        
        vm.prank(USER);
        token.depositAndMint{value: ethAmount}(tokensToMint);
        
        // 现在赎回代币
        uint256 tokensToRedeem = tokensToMint / 2; // 赎回一半
        uint256 valueRedeemed = token.getUsdAmountFromTsla(tokensToRedeem);
        uint256 ethToReturn = token.getEthAmountFromUsd(valueRedeemed);
        
        vm.prank(USER);
        vm.expectEmit(true, true, true, true);
        emit TokensRedeemed(USER, ethToReturn, tokensToRedeem);
        
        token.redeemAndBurn(tokensToRedeem);
        
        assertEq(token.balanceOf(USER), tokensToMint - tokensToRedeem);
        assertEq(token.totalSupply(), tokensToMint - tokensToRedeem);
    }
    
    function testAddCollateral() public {
        uint256 ethAmount = 0.5 ether;
        
        vm.prank(USER);
        vm.expectEmit(true, true, true, true);
        emit CollateralAdded(USER, ethAmount);
        
        token.addCollateral{value: ethAmount}();
    }
    
    function testWithdrawCollateral() public {
        // 先添加抵押品
        uint256 ethAmount = 1 ether;
        
        vm.prank(USER);
        token.addCollateral{value: ethAmount}();
        
        // 现在提取部分抵押品
        uint256 ethToWithdraw = 0.2 ether;
        
        vm.prank(USER);
        vm.expectEmit(true, true, true, true);
        emit CollateralWithdrawn(USER, ethToWithdraw);
        
        token.withdrawCollateral(ethToWithdraw);
    }
    
    function testHealthFactor() public {
        // 存入ETH并铸造代币
        uint256 ethAmount = 1 ether;
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd);
        
        vm.prank(USER);
        token.depositAndMint{value: ethAmount}(tokensToMint);
        
        // 检查健康因子
        uint256 healthFactor = token.getHealthFactor(USER);
        
        // 由于是200%抵押，健康因子应该是2e18
        assertEq(healthFactor, 2e18);
    }
    
    function testHealthFactorWithNoTokens() public {
        // 只添加抵押品，不铸造代币
        uint256 ethAmount = 1 ether;
        
        vm.prank(USER);
        token.addCollateral{value: ethAmount}();
        
        // 检查健康因子
        uint256 healthFactor = token.getHealthFactor(USER);
        
        // 没有铸造代币时，健康因子应该是最大值
        assertEq(healthFactor, type(uint256).max);
    }
    
    function testCannotMintWithInsufficientCollateral() public {
        // 尝试用不足的抵押铸造代币
        uint256 ethAmount = 0.1 ether; // 0.1 ETH = $200
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        
        // 尝试铸造价值超过抵押品价值的代币
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd * 3); // 3倍价值
        
        vm.prank(USER);
        vm.expectRevert(TeslaPriceToken.TeslaPriceToken__InsufficientCollateral.selector);
        token.depositAndMint{value: ethAmount}(tokensToMint);
    }
    
    function testCannotRedeemWithInsufficientCollateral() public {
        // 先铸造一些代币
        uint256 ethAmount = 1 ether;
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd);
        
        vm.prank(USER);
        token.depositAndMint{value: ethAmount}(tokensToMint);
        
        // 尝试赎回所有代币，这会导致健康因子低于阈值
        vm.prank(USER);
        vm.expectRevert(TeslaPriceToken.TeslaPriceToken__InsufficientCollateral.selector);
        token.redeemAndBurn(tokensToMint);
    }
    
    function testCannotWithdrawWithInsufficientCollateral() public {
        // 先铸造一些代币
        uint256 ethAmount = 1 ether;
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd);
        
        vm.prank(USER);
        token.depositAndMint{value: ethAmount}(tokensToMint);
        
        // 尝试提取过多抵押品
        uint256 ethToWithdraw = 0.8 ether; // 提取80%的抵押品
        
        vm.prank(USER);
        vm.expectRevert(TeslaPriceToken.TeslaPriceToken__InsufficientCollateral.selector);
        token.withdrawCollateral(ethToWithdraw);
    }
    
    function testPause() public {
        token.pause();
        assertTrue(token.paused());
    }
    
    function testUnpause() public {
        token.pause();
        token.unpause();
        assertFalse(token.paused());
    }
    
    function testCannotMintWhenPaused() public {
        token.pause();
        
        uint256 ethAmount = 1 ether;
        uint256 ethValueInUsd = token.getUsdAmountFromEth(ethAmount);
        uint256 tokensToMint = token.getEthAmountFromUsd(ethValueInUsd);
        
        vm.prank(USER);
        vm.expectRevert();
        token.depositAndMint{value: ethAmount}(tokensToMint);
    }
    
    function testEmergencyWithdraw() public {
        // 发送一些ETH到合约
        vm.deal(address(token), 1 ether);
        
        uint256 ownerBalance = token.owner().balance;
        token.emergencyWithdraw();
        assertEq(token.owner().balance, ownerBalance + 1 ether);
    }
    
    function testUpdatePriceFeeds() public {
        address newTslaFeed = address(0x3);
        address newEthUsdFeed = address(0x4);
        
        token.updateTslaPriceFeed(newTslaFeed);
        token.updateEthPriceFeed(newEthUsdFeed);
    }
}