// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TeslaPriceToken} from "../src/TeslaPriceToken.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract DeployTeslaPriceToken is Script {
    // 价格馈送参数
    uint8 public constant DECIMALS = 8;
    int256 public constant TSLA_INITIAL_PRICE = 200 * 1e8; // $200 with 8 decimals
    int256 public constant ETH_USD_INITIAL_PRICE = 2000 * 1e8; // $2000 with 8 decimals
    
    function run() external returns (TeslaPriceToken) {
        // --- Configuration ---
        // 在本地测试环境中，我们使用模拟的价格馈送
        // 在实际部署中，应该使用真实的Chainlink价格馈送地址
        
        // Start broadcasting (signs and sends transaction)
        vm.startBroadcast();
        
        // 部署模拟价格馈送
        MockV3Aggregator tslaPriceFeed = new MockV3Aggregator(DECIMALS, TSLA_INITIAL_PRICE);
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_INITIAL_PRICE);
        
        // 部署TeslaPriceToken合约
        TeslaPriceToken token = new TeslaPriceToken(address(tslaPriceFeed), address(ethUsdPriceFeed));
        
        // 记录部署的地址
        console.log("TSLA Price Feed deployed at:", address(tslaPriceFeed));
        console.log("ETH/USD Price Feed deployed at:", address(ethUsdPriceFeed));
        console.log("TeslaPriceToken deployed at:", address(token));
        
        vm.stopBroadcast();
        
        return token;
    }
    
    function runWithRealFeeds(address tslaFeed, address ethUsdFeed) public returns (TeslaPriceToken) {
        // 使用真实价格馈送的部署函数
        vm.startBroadcast();
        
        TeslaPriceToken token = new TeslaPriceToken(tslaFeed, ethUsdFeed);
        
        console.log("TSLA Price Feed address:", tslaFeed);
        console.log("ETH/USD Price Feed address:", ethUsdFeed);
        console.log("TeslaPriceToken deployed at:", address(token));
        
        vm.stopBroadcast();
        
        return token;
    }
    
    // BSC主网部署函数
    function deployBSCMainnet() external returns (TeslaPriceToken) {
        // BSC主网价格预言机地址
        address tslaFeed = 0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893; // TSLA/USD on BSC Mainnet
        address ethUsdFeed = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e; // ETH/USD on BSC Mainnet
        
        return runWithRealFeeds(tslaFeed, ethUsdFeed);
    }
    
    // BSC测试网部署函数
    function deployBSCTestnet() external returns (TeslaPriceToken) {
        // BSC测试网价格预言机地址（需要替换为实际地址）
        address tslaFeed = 0x0000000000000000000000000000000000000000; // Replace with actual testnet feed
        address ethUsdFeed = 0x0000000000000000000000000000000000000000; // Replace with actual testnet feed
        
        return runWithRealFeeds(tslaFeed, ethUsdFeed);
    }
    
    // Sepolia测试网部署函数
    function deploySepolia() external returns (TeslaPriceToken) {
        // Sepolia测试网价格预言机地址
        address tslaFeed = 0xc59E3633BAAC79493d908e63626716e204A45EdF; // LINK/USD as placeholder
        address ethUsdFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // ETH/USD on Sepolia
        
        return runWithRealFeeds(tslaFeed, ethUsdFeed);
    }
}