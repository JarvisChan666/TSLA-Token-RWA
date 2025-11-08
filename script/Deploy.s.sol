// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TeslaPriceToken} from "../src/TeslaPriceToken.sol";

contract Deploy is Script {
    function run() external {
        // --- Configuration ---
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID")); // Your Functions subscription ID
        address functionsRouter = vm.envAddress("FUNCTIONS_ROUTER"); // Sepolia Functions Router
        bytes32 donId = bytes32(bytes(vm.envString("DON_ID"))); // DON ID (must be bytes32)

        // TSLA/USD Price Feed (using LINK/USD as placeholder on Sepolia)
        // Note: There is no real TSLA/USD feed on Sepolia.
        // For testing, we use a supported feed (e.g., LINK/USD) or deploy a mock.
        address tslaPriceFeed = vm.envAddress("TSLA_PRICE_FEED"); // LINK/USD on Sepolia

        // Sequencer Uptime Feed: Only required on L2 (e.g., Optimism, Arbitrum)
        // On L1 networks like Sepolia, set to address(0) to disable check
        address sequencerUptimeFeed = vm.envAddress("SEQUENCER_UPTIME_FEED");

        // USDC Token on Sepolia
        address usdcAddress = vm.envAddress("USDC_ADDRESS");

        // DON Hosted Secrets Configuration
        uint32 donHostedSecretsSlotId = uint32(vm.envUint("DON_HOSTED_SECRETS_SLOT_ID"));
        uint64 donHostedSecretsVersion = uint64(vm.envUint("DON_HOSTED_SECRETS_VERSION"));

        // Start broadcasting (signs and sends transaction)
        vm.startBroadcast();

        // Deploy the TeslaPriceToken contract
        TeslaPriceToken token = new TeslaPriceToken(
            functionsRouter,
            vm.envString("DON_ID"),
            subscriptionId,
            tslaPriceFeed,
            sequencerUptimeFeed, // Use real address on L2, address(0) on L1
            usdcAddress,
            donHostedSecretsSlotId,
            donHostedSecretsVersion
        );

        // Log the deployed address
        console.log("TeslaPriceToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}