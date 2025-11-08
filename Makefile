.PHONY: help build deploy-sepolia

# Default target
help:
	@echo "Available commands:"
	@echo "  build         - Build the project"
	@echo "  deploy-sepolia - Deploy to Sepolia testnet"
	@echo "  upload-secrets - Upload secrets to Chainlink Functions"

# Build the project
build:
	forge build

# Deploy to Sepolia testnet
deploy-sepolia:
	forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --private-key $(PRIVATE_KEY)

# Upload secrets to Chainlink Functions
upload-secrets:
	npm run upload-secrets