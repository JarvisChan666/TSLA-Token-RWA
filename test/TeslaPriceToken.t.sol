// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TeslaPriceToken} from "../src/TeslaPriceToken.sol";

contract TeslaPriceTokenTest is Test {
    TeslaPriceToken public token;
    
    // Mock addresses for testing
    address private constant MOCK_ROUTER = address(0x1);
    address private constant MOCK_PRICE_FEED = address(0x2);
    address private constant MOCK_SEQUENCER_FEED = address(0x3);
    string private constant MOCK_DON_ID = "0x1234567890123456789012345678901234567890123456789012345678901234";
    uint64 private constant MOCK_SUBSCRIPTION_ID = 1;
    uint32 private constant MOCK_DON_HOSTED_SECRETS_SLOT_ID = 0;
    uint64 private constant MOCK_DON_HOSTED_SECRETS_VERSION = 1;
    
    event TokensMinted(address indexed to, uint256 amount);
    event TokensRedeemed(address indexed from, uint256 amount);
    
    function setUp() public {
        token = new TeslaPriceToken(
            MOCK_ROUTER,
            MOCK_DON_ID,
            MOCK_SUBSCRIPTION_ID,
            MOCK_PRICE_FEED,
            MOCK_SEQUENCER_FEED,
            MOCK_DON_HOSTED_SECRETS_SLOT_ID,
            MOCK_DON_HOSTED_SECRETS_VERSION
        );
    }
    
    function testConstructor() public {
        assertEq(token.name(), "Tesla Price Token");
        assertEq(token.symbol(), "TPT");
        assertEq(token.totalSupply(), 0);
    }
    
    function testMintTokens() public {
        // Mock a Tesla price of $200 (with 18 decimals)
        vm.mockCall(
            MOCK_PRICE_FEED,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(200 * 1e8), uint256(0), uint256(block.timestamp), uint80(1))
        );
        
        // Mock sequencer as up
        vm.mockCall(
            MOCK_SEQUENCER_FEED,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(1), uint256(block.timestamp), uint256(block.timestamp), uint80(1))
        );
        
        uint256 mintAmount = 1000 * 10**18; // 1000 USD
        uint256 expectedTokens = (mintAmount * 10**18) / (200 * 10**18); // 5 tokens
        
        vm.expectEmit(true, true, true, true);
        emit TokensMinted(address(this), expectedTokens);
        
        token.mintTokens{value: mintAmount}(mintAmount);
        
        assertEq(token.balanceOf(address(this)), expectedTokens);
        assertEq(token.totalSupply(), expectedTokens);
    }
    
    function testRedeemTokens() public {
        // First mint some tokens
        vm.mockCall(
            MOCK_PRICE_FEED,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(200 * 1e8), uint256(0), uint256(block.timestamp), uint80(1))
        );
        
        vm.mockCall(
            MOCK_SEQUENCER_FEED,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(1), uint256(block.timestamp), uint256(block.timestamp), uint80(1))
        );
        
        uint256 mintAmount = 1000 * 10**18; // 1000 USD
        uint256 expectedTokens = (mintAmount * 10**18) / (200 * 10**18); // 5 tokens
        
        token.mintTokens{value: mintAmount}(mintAmount);
        
        // Now redeem the tokens
        uint256 redeemAmount = expectedTokens;
        uint256 expectedUSD = (redeemAmount * 200 * 10**18) / 10**18; // 1000 USD
        
        vm.expectEmit(true, true, true, true);
        emit TokensRedeemed(address(this), expectedUSD);
        
        token.redeemTokens(redeemAmount);
        
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.totalSupply(), 0);
    }
}