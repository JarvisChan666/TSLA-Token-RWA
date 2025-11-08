// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title TeslaPriceToken
 * @dev ERC20 token backed by Tesla stock price, using Chainlink Functions for price data
 */
contract TeslaPriceToken is FunctionsClient, ConfirmedOwner, ERC20, Pausable, ReentrancyGuard {
    // Chainlink Functions configuration
    bytes32 private s_lastRequestId;
    bytes32 private s_lastError;
    string private s_lastResponse;
    uint32 private constant GAS_LIMIT = 300_000;
    
    // Oracle configuration
    string private s_donId;
    uint64 private s_subscriptionId;
    uint32 private s_callbackGasLimit = GAS_LIMIT;
    uint16 private s_donHostedSecretsSlotID;
    uint64 private s_donHostedSecretsVersion;
    
    // Price feed
    AggregatorV3Interface private priceFeed;
    
    // Token parameters
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1 million tokens
    uint256 public constant MIN_MINT_AMOUNT = 10 * 10**18; // 10 tokens minimum
    
    // Rate limiting
    uint256 private constant UPDATE_INTERVAL = 1 hours;
    uint256 private lastUpdateTime;
    
    // Sequencer check
    AggregatorV3Interface private sequencerUptimeFeed;
    bool private isSequencerDown;
    
    // Events
    event RequestSent(bytes32 indexed requestId);
    event RequestFulfilled(bytes32 indexed requestId, string response, string err);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensRedeemed(address indexed from, uint256 amount);
    
    // Errors
    error SequencerDown();
    error InsufficientPayment();
    error RateLimited();
    error InvalidAmount();
    error ExceedsMaxSupply();
    
    constructor(
        address router,
        string memory donId,
        uint64 subscriptionId,
        address priceFeedAddress,
        address sequencerUptimeFeedAddress,
        uint32 donHostedSecretsSlotId,
        uint64 donHostedSecretsVersion
    ) 
        FunctionsClient(router) 
        ConfirmedOwner(msg.sender)
        ERC20("Tesla Price Token", "TPT")
    {
        s_donId = donId;
        s_subscriptionId = subscriptionId;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        sequencerUptimeFeed = AggregatorV3Interface(sequencerUptimeFeedAddress);
        s_donHostedSecretsSlotID = donHostedSecretsSlotId;
        s_donHostedSecretsVersion = donHostedSecretsVersion;
        lastUpdateTime = block.timestamp;
        _checkSequencerStatus();
    }
    
    /**
     * @dev Request Tesla stock price from Chainlink Functions
     */
    function requestTeslaPrice() external {
        if (isSequencerDown) {
            revert SequencerDown();
        }
        
        if (block.timestamp < lastUpdateTime + UPDATE_INTERVAL) {
            revert RateLimited();
        }
        
        // Chainlink Functions source code to fetch Tesla price from Alpaca Markets
        string memory source = "// This JavaScript source code is used by Chainlink Functions to fetch TSLA price from Alpaca Markets\n\n// Check if Alpaca API credentials are provided\nif (!secrets.alpacaKey || !secrets.alpacaSecret) {\n    throw Error(\"Need Alpaca API credentials.\");\n}\n\n// Make HTTP request to Alpaca Markets API to get TSLA price\nconst apiResponse = await Functions.makeHttpRequest({\n    url: \"https://data.alpaca.markets/v2/stocks/TSLA/quotes/latest\",\n    headers: {\n        'APCA-API-KEY-ID': secrets.alpacaKey,\n        'APCA-API-SECRET-KEY': secrets.alpacaSecret\n    }\n});\n\n// Check if the request was successful\nif (apiResponse.error) {\n    throw Error(`Request Failed: ${apiResponse.error}`);\n}\n\n// Extract data from the response\nconst { data } = apiResponse;\n\n// Validate the response structure\nif (!data || !data.quote) {\n    throw Error(\"Invalid response structure from Alpaca.\");\n}\n\n// Get the latest price (ask price first, then bid price as fallback)\nlet latestPrice = data.quote.ap;\n\nif (latestPrice === 0) {\n    latestPrice = data.quote.bp;\n}\n\n// Validate that we have a valid price\nif (latestPrice === 0) {\n    throw Error(\"Both ask price and bid price are zero. No valid price available.\");\n}\n\n// Log the price for debugging\nconsole.log(`The latest price of TSLA is $${latestPrice}`);\n\n// Return the price as a uint256 with 8 decimals (Chainlink price feeds typically use 8 decimals)\nreturn Functions.encodeUint256(Math.round(latestPrice * 1e8));";
        
        // Encrypted secrets reference
        bytes32[] memory donHostedSecretsEncryptedUrls = new bytes32[](0);
        
        // Send request
        s_lastRequestId = _sendRequest(
            source,
            donHostedSecretsEncryptedUrls,
            s_donHostedSecretsSlotID,
            s_donHostedSecretsVersion,
            s_callbackGasLimit,
            s_donId,
            s_subscriptionId
        );
        
        emit RequestSent(s_lastRequestId);
    }
    
    /**
     * @dev Callback function for Chainlink Functions
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        s_lastResponse = string(response);
        s_lastError = string(err);
        lastUpdateTime = block.timestamp;
        emit RequestFulfilled(requestId, s_lastResponse, s_lastError);
    }
    
    /**
     * @dev Mint tokens based on Tesla stock price
     */
    function mintTokens(uint256 amountInUSD) external payable nonReentrant whenNotPaused {
        if (isSequencerDown) {
            revert SequencerDown();
        }
        
        if (amountInUSD < MIN_MINT_AMOUNT) {
            revert InvalidAmount();
        }
        
        if (totalSupply() + amountInUSD > MAX_SUPPLY) {
            revert ExceedsMaxSupply();
        }
        
        // Calculate tokens to mint based on current Tesla price
        uint256 teslaPrice = getTeslaPrice();
        uint256 tokensToMint = (amountInUSD * 10**18) / teslaPrice;
        
        _mint(msg.sender, tokensToMint);
        emit TokensMinted(msg.sender, tokensToMint);
    }
    
    /**
     * @dev Redeem tokens for USD value
     */
    function redeemTokens(uint256 tokenAmount) external nonReentrant whenNotPaused {
        if (tokenAmount == 0 || balanceOf(msg.sender) < tokenAmount) {
            revert InvalidAmount();
        }
        
        // Calculate USD value of tokens
        uint256 teslaPrice = getTeslaPrice();
        uint256 usdValue = (tokenAmount * teslaPrice) / 10**18;
        
        _burn(msg.sender, tokenAmount);
        
        // In a real implementation, you would transfer USD to the user
        // For this example, we'll just emit an event
        emit TokensRedeemed(msg.sender, usdValue);
    }
    
    /**
     * @dev Get current Tesla stock price from Chainlink price feed
     */
    function getTeslaPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int256 price,
            /*uint256 startedAt*/,
            /*uint256 timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        
        // Chainlink price feeds have 8 decimals for stock prices
        return uint256(price) * 10**10; // Convert to 18 decimals
    }
    
    /**
     * @dev Check if sequencer is down
     */
    function _checkSequencerStatus() internal {
        (
            /*uint80 roundID*/,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            /*uint80 answeredInRound*/
        ) = sequencerUptimeFeed.latestRoundData();
        
        // Answer is 0 if sequencer is down, 1 if up
        isSequencerDown = (answer == 0);
        
        // If the latest update is more than 1 hour old, consider sequencer down
        if (block.timestamp - updatedAt > 3600) {
            isSequencerDown = true;
        }
    }
    
    /**
     * @dev Pause contract operations
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause contract operations
     */
    function unpause() external onlyOwner {
        _unpause();
        _checkSequencerStatus();
    }
    
    /**
     * @dev Set DON hosted secrets slot ID and version
     */
    function setDonHostedSecrets(uint32 slotId, uint64 version) external onlyOwner {
        s_donHostedSecretsSlotID = slotId;
        s_donHostedSecretsVersion = version;
    }
    
    /**
     * @dev Get the last request ID
     */
    function getLastRequestId() external view returns (bytes32) {
        return s_lastRequestId;
    }
    
    /**
     * @dev Get the last response
     */
    function getLastResponse() external view returns (string memory) {
        return s_lastResponse;
    }
    
    /**
     * @dev Get the last error
     */
    function getLastError() external view returns (string memory) {
        return s_lastError;
    }
    
    /**
     * @dev Check if sequencer is down
     */
    function getSequencerStatus() external view returns (bool) {
        return isSequencerDown;
    }
}