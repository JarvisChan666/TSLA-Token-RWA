# BSC 部署指南

## 概述

本指南详细介绍了如何在BSC（币安智能链）主网和测试网上部署Tesla Price Token合约。BSC是一个与以太坊兼容的区块链平台，提供更快的交易速度和更低的交易费用。

## BSC网络配置

### BSC主网
- **网络名称**: BSC Mainnet
- **链ID**: 56 (0x38)
- **RPC URL**: https://bsc-dataseed.bnbchain.org
- **区块浏览器**: https://bscscan.com
- **原生代币**: BNB

### BSC测试网
- **网络名称**: BSC Testnet
- **链ID**: 97 (0x61)
- **RPC URL**: https://bsc-testnet-dataseed.bnbchain.org
- **区块浏览器**: https://testnet.bscscan.com
- **水龙头**: https://testnet.binance.org/faucet-smart

## BSC价格预言机地址

### BSC主网价格预言机
- **TSLA/USD**: 0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893
- **ETH/USD**: 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e

### BSC测试网价格预言机
- **TSLA/USD**: 需要替换为实际测试网地址
- **ETH/USD**: 需要替换为实际测试网地址

## 环境配置

### 1. 设置环境变量

在`.env`文件中添加以下BSC配置：

```bash
# BSC主网配置
BSC_RPC_URL=https://bsc-dataseed.bnbchain.org
BSC_CHAIN_ID=56
# Etherscan API V2 now supports all chains including BSC
ETHERSCAN_API_KEY=your_etherscan_api_key_here

# BSC测试网配置
BSC_TESTNET_RPC_URL=https://bsc-testnet-dataseed.bnbchain.org
BSC_TESTNET_CHAIN_ID=97

# BSC价格预言机地址
BSC_TSLA_PRICE_FEED=0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893  # TSLA/USD on BSC Mainnet
BSC_ETH_USD_PRICE_FEED=0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e  # ETH/USD on BSC Mainnet
```

### 获取Etherscan API密钥

1. 访问 [Etherscan API文档](https://docs.etherscan.io/getting-an-api-key)
2. 注册账户并登录
3. 前往 API-KEYs 页面
4. 创建新的API密钥
5. 将密钥添加到您的`.env`文件中的`ETHERSCAN_API_KEY`变量

注意：Etherscan API V2现在支持所有链，包括BSC，所以您只需要一个API密钥。

### 2. 配置钱包

确保您的钱包（如MetaMask）已配置BSC网络：

1. 打开MetaMask
2. 点击网络下拉菜单
3. 点击"添加网络"
4. 选择"手动添加网络"
5. 输入以下信息：
   - **网络名称**: BSC Mainnet 或 BSC Testnet
   - **新的RPC URL**: https://bsc-dataseed.bnbchain.org (主网) 或 https://bsc-testnet-dataseed.bnbchain.org (测试网)
   - **链ID**: 56 (主网) 或 97 (测试网)
   - **货币符号**: BNB
   - **区块浏览器URL**: https://bscscan.com (主网) 或 https://testnet.bscscan.com (测试网)

## 部署步骤

### 1. 准备工作

1. **获取测试BNB**（测试网部署）：
   - 访问 [BSC测试网水龙头](https://testnet.binance.org/faucet-smart)
   - 输入您的钱包地址获取测试BNB

2. **准备主网BNB**（主网部署）：
   - 确保您的钱包有足够的BNB用于部署Gas费用
   - BSC主网Gas费用通常远低于以太坊主网

### 2. 部署到BSC测试网

```bash
# 使用部署脚本部署到BSC测试网
forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCTestnet()" --rpc-url $BSC_TESTNET_RPC_URL --private-key $PRIVATE_KEY --broadcast

# 或者使用Make命令
make deploy-bsc-testnet
```

### 3. 部署到BSC主网

```bash
# 使用部署脚本部署到BSC主网
forge script script/Deploy.s.sol:DeployTeslaPriceToken --sig "deployBSCMainnet()" --rpc-url $BSC_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --verifier-url https://api.bscscan.com/api --etherscan-api-key $BSC_EXPLORER_API_KEY

# 或者使用Make命令
make deploy-bsc-mainnet
```

## 部署后操作

### 1. 验证合约

```bash
# 验证BSC合约源码
forge verify-contract <CONTRACT_ADDRESS> src/TeslaPriceToken.sol:TeslaPriceToken --chain-id 56 --verifier bscscan --etherscan-api-key $BSC_EXPLORER_API_KEY
```

### 2. 测试合约交互

```bash
# 获取TSLA价格
cast call <CONTRACT_ADDRESS> "getTeslaPrice()" --rpc-url $BSC_RPC_URL

# 获取ETH价格
cast call <CONTRACT_ADDRESS> "getEthPrice()" --rpc-url $BSC_RPC_URL

# 检查健康因子
cast call <CONTRACT_ADDRESS> "getHealthFactor(address)" <USER_ADDRESS> --rpc-url $BSC_RPC_URL
```

## BSC特定注意事项

### 1. Gas费用

- BSC网络的Gas费用通常比以太坊主网低得多
- 建议使用标准的Gas价格设置，无需过高
- 可以使用 [BSC Gas Station](https://bscgas.info/) 查看推荐的Gas价格

### 2. 交易确认

- BSC网络的区块时间约为3秒，交易确认速度快
- 大多数交易在几个区块内即可确认
- 建议等待至少3-6个区块确认以确保交易安全

### 3. 价格预言机

- 确保使用BSC网络上的价格预言机地址
- 定期检查价格预言机的运行状态
- 注意BSC上的价格可能与以太坊上的价格略有差异

### 4. 安全考虑

- BSC网络虽然速度快，但仍需遵循与以太坊相同的安全最佳实践
- 使用硬件钱包进行主网部署
- 考虑使用多签钱包管理合约

## 常见问题

### 1. 交易失败

- 检查Gas价格是否足够
- 确认账户有足够的BNB支付Gas费用
- 检查网络连接和RPC端点是否正常

### 2. 合约验证失败

- 确认BSCScan API密钥正确
- 检查合约地址是否正确
- 确认编译器版本和优化设置与部署时一致

### 3. 价格预言机问题

- 确认使用的是BSC网络上的价格预言机地址
- 检查价格预言机是否正常运行
- 考虑设置价格异常检测机制

## 总结

BSC网络为Tesla Price Token提供了高效、低成本的部署环境。通过遵循本指南，您可以成功在BSC主网和测试网上部署合约，并利用BSC网络的优势进行快速、低成本的交易。

如需更多帮助，请参考：
- [BSC官方文档](https://docs.binance.org/)
- [Chainlink BSC价格预言机文档](https://docs.chain.link/data-feeds/price-feeds/addresses?network=bsc)
- [BSCScan文档](https://docs.bscscan.com/)