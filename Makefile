.PHONY: help build deploy-sepolia deploy-bsc-mainnet deploy-bsc-testnet upload-secrets

# Default target
help:
	@echo "Available commands:"
	@echo "  build            - Build the project"
	@echo "  deploy-sepolia   - Deploy to Sepolia testnet"
	@echo "  deploy-bsc-mainnet - Deploy to BSC mainnet"
	@echo "  deploy-bsc-testnet - Deploy to BSC testnet"
	@echo "  upload-secrets   - Upload secrets to Chainlink Functions"

# Build the project
build:
	forge build

# Deploy to Sepolia testnet
deploy-sepolia:
	forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deploySepolia()" --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --private-key $(PRIVATE_KEY)

# Deploy to BSC mainnet
deploy-bsc-mainnet:
	forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCMainnet()" --rpc-url $(BSC_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --verifier etherscan --verifier-url https://api.bscscan.com/api --etherscan-api-key $(ETHERSCAN_API_KEY) --private-key $(PRIVATE_KEY)

# Deploy to BSC testnet
deploy-bsc-testnet:
	forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCTestnet()" --rpc-url $(BSC_TESTNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --verifier etherscan --verifier-url https://api-testnet.bscscan.com/api --etherscan-api-key $(ETHERSCAN_API_KEY)

# Upload secrets to Chainlink Functions
upload-secrets:
	npm run upload-secrets