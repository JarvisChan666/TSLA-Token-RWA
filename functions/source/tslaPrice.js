// This JavaScript source code is used by Chainlink Functions to fetch TSLA price from Alpaca Markets

// Check if Alpaca API credentials are provided
if (!secrets.alpacaKey || !secrets.alpacaSecret) {
    throw Error("Need Alpaca API credentials.");
}

// Make HTTP request to Alpaca Markets API to get TSLA price
const apiResponse = await Functions.makeHttpRequest({
    url: "https://data.alpaca.markets/v2/stocks/TSLA/quotes/latest",
    headers: {
        'APCA-API-KEY-ID': secrets.alpacaKey,
        'APCA-API-SECRET-KEY': secrets.alpacaSecret
    }
});

// Check if the request was successful
if (apiResponse.error) {
    throw Error(`Request Failed: ${apiResponse.error}`);
}

// Extract data from the response
const { data } = apiResponse;

// Validate the response structure
if (!data || !data.quote) {
    throw Error("Invalid response structure from Alpaca.");
}

// Get the latest price (ask price first, then bid price as fallback)
let latestPrice = data.quote.ap;

if (latestPrice === 0) {
    latestPrice = data.quote.bp;
}

// Validate that we have a valid price
if (latestPrice === 0) {
    throw Error("Both ask price and bid price are zero. No valid price available.");
}

// Log the price for debugging
console.log(`The latest price of TSLA is $${latestPrice}`);

// Return the price as a uint256 with 8 decimals (Chainlink price feeds typically use 8 decimals)
return Functions.encodeUint256(Math.round(latestPrice * 1e8));