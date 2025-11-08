# Tesla Price Token 部署指南

本指南将帮助您在Sepolia测试网上部署Tesla Price Token (TPT)项目。

## 前置条件

1. 已安装Foundry框架
2. 已安装Node.js和npm
3. 已获取Sepolia测试网ETH
4. 已创建Chainlink Functions订阅
5. 已获取Alpaca Markets API密钥

## 部署步骤

### 1. 环境配置

1. 复制环境变量模板：
```bash
cp .env.example .env
```

2. 编辑.env文件，填入以下信息：
- `PRIVATE_KEY`: 您的私钥（确保有足够的Sepolia ETH）
- `SEPOLIA_RPC_URL`: 您的Sepolia RPC URL（如Infura）
- `ETHERSCAN_API_KEY`: Etherscan API密钥（用于验证合约）
- `SUBSCRIPTION_ID`: 您的Chainlink Functions订阅ID
- `ALPACA_API_KEY_ID`: 您的Alpaca API Key ID
- `ALPACA_API_SECRET_KEY`: 您的Alpaca API Secret Key

### 2. 安装依赖

```bash
# 安装Foundry依赖
forge install

# 安装Node.js依赖
npm install
```

### 3. 上传Chainlink Functions秘密

1. 运行以下命令上传Alpaca API密钥到Chainlink Functions：
```bash
make upload-secrets
```

2. 命令执行后，您将看到类似以下输出：
```
Secrets uploaded successfully to slot 0
Version: 1234567890
Expiration: 2023-XX-XX XX:XX:XX.XXXZ
Update your .env file with: DON_HOSTED_SECRETS_VERSION=1234567890
```

3. 更新.env文件中的`DON_HOSTED_SECRETS_VERSION`值

### 4. 编译合约

```bash
make build
```

### 5. 运行测试（可选）

```bash
forge test
```

### 6. 部署合约

```bash
make deploy-sepolia
```

部署成功后，您将看到类似以下输出：
```
TeslaPriceToken deployed at: 0x1234567890abcdef1234567890abcdef12345678
```

## 部署后操作

### 1. 验证合约

部署脚本会自动尝试在Etherscan上验证合约。如果验证失败，您可以手动验证。

### 2. 添加消费者

1. 访问[Chainlink Functions](https://functions.chain.link/)
2. 找到您的订阅
3. 添加新部署的合约地址作为消费者

### 3. 测试合约

您可以使用以下命令与合约交互：

1. 请求TSLA价格：
```bash
cast send <CONTRACT_ADDRESS> "requestTeslaPrice()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

2. 铸造代币：
```bash
cast send <CONTRACT_ADDRESS> "mintTokens(uint256)" <AMOUNT_IN_USD> --value <AMOUNT_IN_USD> --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

3. 查询代币余额：
```bash
cast call <CONTRACT_ADDRESS> "balanceOf(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

## 注意事项

1. **API密钥安全**：请妥善保管您的Alpaca API密钥，不要提交到版本控制系统
2. **测试网限制**：Sepolia测试网上没有真实的TSLA/USD价格预言机，我们使用LINK/USD作为占位符
3. **价格更新频率**：合约限制每小时只能更新一次价格
4. **最大供应量**：合约最大供应量为100万枚代币

## 故障排除

### 1. 部署失败

- 检查私钥是否有足够的Sepolia ETH
- 确认RPC URL是否正确
- 检查Chainlink Functions订阅是否有效

### 2. 价格请求失败

- 确认已正确上传Alpaca API密钥
- 检查合约是否已添加为Chainlink Functions的消费者
- 确认DON_HOSTED_SECRETS_VERSION是否正确

### 3. 代币铸造失败

- 确认发送的ETH足够支付铸造费用
- 检查是否超过了最大供应量限制
- 确认铸造金额不小于最小限制（10 USD）

## 生产环境部署

在生产环境中部署时，您需要：

1. 使用支持TSLA/USD价格预言机的网络（如BNB Chain）
2. 更新价格预言机地址
3. 进行专业的智能合约安全审计
4. 考虑实施更严格的安全控制措施

## 技术支持

如果您在部署过程中遇到问题，可以：

1. 查看项目的README.md文件
2. 检查Chainlink Functions官方文档
3. 在GitHub上创建Issue