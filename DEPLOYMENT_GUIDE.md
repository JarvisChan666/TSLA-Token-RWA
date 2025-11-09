# Tesla Price Token 部署指南

## 概述

本指南将详细介绍如何在测试网和主网上部署Tesla Price Token合约。Tesla Price Token是一个超额抵押的稳定币，使用ETH作为抵押品，通过Chainlink价格预言机获取TSLA和ETH的实时价格。

## 前置条件

在开始部署之前，请确保您已完成以下准备工作：

1. **完成项目安装**：按照 [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) 完成所有依赖安装
2. **获取测试网ETH**：确保您有足够的测试网ETH用于部署和测试
3. **配置环境变量**：在`.env`文件中设置所有必要的环境变量
4. **获取价格预言机地址**：获取目标网络上的TSLA和ETH价格预言机地址

## 环境配置

### 1. 环境变量设置

复制环境变量模板并填入您的实际配置：

```bash
# 复制环境变量模板
cp .env.example .env
```

编辑`.env`文件，设置以下变量：

```bash
# Ethereum Sepolia Configuration
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
ETHERSCAN_API_KEY=YOUR_ETHERCAN_API_KEY
PRIVATE_KEY=YOUR_PRIVATE_KEY

# BSC Mainnet Configuration
BSC_RPC_URL=https://bsc-dataseed.bnbchain.org
BSC_CHAIN_ID=56

# BSC Testnet Configuration
BSC_TESTNET_RPC_URL=https://bsc-testnet-dataseed.bnbchain.org
BSC_TESTNET_CHAIN_ID=97

# Token Configuration
# Note: Chainlink does not provide a TSLA/USD price feed on Sepolia
# We use LINK/USD as a placeholder for testing purposes
TSLA_PRICE_FEED=0xc59E3633BAAC79493d908e63626716e204A45EdF # LINK/USD Price Feed on Sepolia (placeholder)

# BSC Mainnet Price Feeds
BSC_TSLA_PRICE_FEED=0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893 # TSLA/USD Price Feed on BSC Mainnet
BSC_ETH_USD_PRICE_FEED=0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e # ETH/USD Price Feed on BSC Mainnet

# BSC Testnet Price Feeds (Replace with actual testnet feeds)
BSC_TESTNET_TSLA_PRICE_FEED=0x0000000000000000000000000000000000000000 # Replace with actual testnet feed
BSC_TESTNET_ETH_USD_PRICE_FEED=0x0000000000000000000000000000000000000000 # Replace with actual testnet feed

# Ethereum Sepolia Price Feeds
SEPOLIA_ETH_PRICE_FEED=0x694AA1769357215DE4FAC081bf1f309aDC325306 # ETH/USD Price Feed on Sepolia
USDC_ADDRESS=0xEFD553316C1F6C556D08A013690ABC759C0addD2 # USDC on Sepolia
SEQUENCER_UPTIME_FEED=0x0000000000000000000000000000000000000000 # Not needed on L1 (Sepolia)

# 合约参数
COLLATERALIZATION_RATIO=200  # 200%抵押率
PRICE_EXPIRY_TIME=10800      # 3小时价格过期时间（秒）
HEALTH_FACTOR_THRESHOLD=150  # 健康因子阈值
```

### 获取Etherscan API密钥

1. 访问 [Etherscan API文档](https://docs.etherscan.io/getting-an-api-key)
2. 注册账户并登录
3. 前往 API-KEYs 页面
4. 创建新的API密钥
5. 将密钥添加到您的`.env`文件中的`ETHERSCAN_API_KEY`变量

注意：Etherscan API V2现在支持所有链，包括BSC，所以您只需要一个API密钥。

### 2. 获取价格预言机地址

您可以从以下资源获取各网络的价格预言机地址：

- **Chainlink文档**：[Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
- **Chainlink市场**：[Market](https://market.link/data-feeds)
- **各网络文档**：查看目标网络的官方文档

## 部署步骤

### 1. 安装依赖

确保所有依赖已正确安装：

```bash
# 安装Node.js依赖
npm install

# 安装Foundry依赖
forge install
```

### 2. 编译合约

```bash
# 编译所有合约
forge build

# 或者使用Make命令
make build
```

### 3. 运行测试

在部署前运行测试确保一切正常：

```bash
# 运行所有测试
forge test

# 或者使用Make命令
make test
```

### 4. 部署到测试网

#### Sepolia测试网部署

```bash
# 使用部署脚本部署到Sepolia
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# 或者使用Make命令
make deploy-sepolia
```

#### BSC测试网部署

```bash
# 使用部署脚本部署到BSC测试网
forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCTestnet()" --rpc-url $BSC_TESTNET_RPC_URL --private-key $PRIVATE_KEY --broadcast

# 或者使用Make命令
make deploy-bsc-testnet
```

#### 其他测试网部署

```bash
# 部署到Goerli测试网
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast

# 部署到Mumbai测试网
forge script script/Deploy.s.sol --rpc-url $MUMBAI_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 5. 部署到主网

⚠️ **警告**：在主网部署前，请确保：
- 已通过全面测试
- 已完成安全审计
- 已进行充分的资金准备
- 了解所有潜在风险

#### 以太坊主网部署

```bash
# 部署到以太坊主网
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# 或者使用Make命令
make deploy-mainnet
```

#### BSC主网部署

```bash
# 使用部署脚本部署到BSC主网
forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCMainnet()" --rpc-url $BSC_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --verifier-url https://api.bscscan.com/api --etherscan-api-key $BSC_EXPLORER_API_KEY

# 或者使用Make命令
make deploy-bsc-mainnet
```

## 部署后操作

### 1. 验证合约部署

部署完成后，验证合约是否正确部署：

```bash
# 验证以太坊合约源码
forge verify-contract <CONTRACT_ADDRESS> src/TeslaPriceToken.sol:TeslaPriceToken --chain-id <CHAIN_ID> --etherscan-api-key $ETHERSCAN_API_KEY

# 验证BSC合约源码
forge verify-contract <CONTRACT_ADDRESS> src/TeslaPriceToken.sol:TeslaPriceToken --chain-id 56 --verifier bscscan --etherscan-api-key $BSC_EXPLORER_API_KEY
```

### 2. 配置价格预言机

如果需要，可以更新价格预言机地址：

```bash
# 使用Cast命令调用合约
cast send <CONTRACT_ADDRESS> "updatePriceFeeds(address,address)" $TSLA_PRICE_FEED $ETH_PRICE_FEED --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. 测试合约交互

```bash
# 获取TSLA价格
cast call <CONTRACT_ADDRESS> "getTeslaPrice()" --rpc-url $RPC_URL

# 获取ETH价格
cast call <CONTRACT_ADDRESS> "getEthPrice()" --rpc-url $RPC_URL

# 检查健康因子
cast call <CONTRACT_ADDRESS> "getHealthFactor(address)" <USER_ADDRESS> --rpc-url $RPC_URL
```

## 合约参数说明

### 核心参数

- **抵押率 (COLLATERALIZATION_RATIO)**: 200%，表示每铸造1美元价值的TPT代币需要2美元价值的ETH抵押
- **价格过期时间 (PRICE_EXPIRY_TIME)**: 3小时（10800秒），超过此时间的价格数据将被视为过期
- **健康因子阈值 (HEALTH_FACTOR_THRESHOLD)**: 150%，低于此值的仓位将面临清算风险

### OracleLib参数

- **最大价格偏差 (MAX_PRICE_DEVIATION)**: 5%，用于检测价格异常波动
- **价格更新冷却时间 (PRICE_UPDATE_COOLDOWN)**: 1小时，防止频繁的价格更新

## 安全注意事项

1. **私钥安全**：
   - 不要在公共代码库中提交私钥
   - 使用硬件钱包进行主网部署
   - 考虑使用多签钱包管理合约

2. **合约安全**：
   - 部署前进行充分的测试
   - 考虑进行第三方安全审计
   - 设置适当的访问控制

3. **价格预言机安全**：
   - 使用可靠的Chainlink价格预言机
   - 监控价格预言机的运行状态
   - 设置价格异常检测机制

4. **资金安全**：
   - 不要在合约中保留过多资金
   - 设置紧急暂停机制
   - 定期监控合约状态

## 故障排除

### 常见部署问题

1. **Gas不足错误**：
   ```bash
   # 增加Gas限制
   forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --gas-limit 3000000
   ```

2. **交易失败**：
   ```bash
   # 检查交易状态
   cast receipt <TRANSACTION_HASH> --rpc-url $RPC_URL
   ```

3. **验证失败**：
   ```bash
   # 手动验证合约
   forge verify-contract <CONTRACT_ADDRESS> src/TeslaPriceToken.sol:TeslaPriceToken --chain-id <CHAIN_ID> --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
   ```

### 网络问题

1. **RPC连接问题**：
   - 尝试更换RPC端点
   - 检查网络连接
   - 确认RPC URL正确

2. **交易确认慢**：
   - 增加Gas价格
   - 使用加速服务
   - 等待网络拥堵缓解

## 监控与维护

### 1. 合约监控

设置监控脚本跟踪以下指标：

- 抵押品总价值
- TPT代币总供应量
- 平均健康因子
- 价格预言机状态

### 2. 定期维护

- 定期检查价格预言机状态
- 监控合约资金安全
- 更新安全补丁
- 备份重要数据

## 多网络部署

### 支持的网络

- **以太坊主网**
- **Sepolia测试网**
- **Goerli测试网**
- **Polygon主网**
- **Polygon Mumbai测试网**
- **BSC主网**
- **BSC测试网**

### 网络特定配置

每个网络的价格预言机地址和RPC URL不同，请根据目标网络调整配置。

### BSC网络特定注意事项

1. **Gas费用**：BSC网络的Gas费用通常比以太坊主网低，但仍需设置适当的Gas价格
2. **区块确认时间**：BSC网络的区块确认时间约为3秒，比以太坊主网快
3. **价格预言机**：确保使用BSC网络上的价格预言机地址

## 部署脚本详解

### Deploy.s.sol 脚本

部署脚本位于 `script/Deploy.s.sol`，主要功能：

1. 部署TeslaPriceToken合约
2. 设置初始价格预言机地址
3. 配置合约参数
4. 验证部署结果

### 网络特定部署函数

- `deployBSCMainnet()`: 部署到BSC主网
- `deployBSCTestnet()`: 部署到BSC测试网
- `deploySepolia()`: 部署到Sepolia测试网

### 自定义部署

如需自定义部署参数，可以修改部署脚本：

```solidity
// 修改抵押率
uint256 collateralizationRatio = 200; // 200%

// 修改价格过期时间
uint256 priceExpiryTime = 10800; // 3小时

// 修改健康因子阈值
uint256 healthFactorThreshold = 150; // 150%
```

## 部署后验证清单

- [ ] 合约已成功部署并验证
- [ ] 价格预言机地址已正确设置
- [ ] 合约参数已正确配置
- [ ] 初始测试已通过
- [ ] 监控系统已设置
- [ ] 安全措施已实施
- [ ] 文档已更新

---

如果遇到任何问题，请参考项目的 [README.md](README.md) 或在GitHub上创建Issue获取帮助。