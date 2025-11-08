# Tesla Price Token (TPT)

一个基于区块链的特斯拉股价挂钩代币，使用Chainlink Functions从Alpaca Markets获取实时TSLA价格，允许用户铸造和赎回与特斯拉股价挂钩的代币。

## 项目概述

Tesla Price Token (TPT) 是一种ERC20代币，其价值与特斯拉(TSLA)股票价格挂钩。用户可以使用USDC铸造TPT代币，也可以随时赎回TPT代币换取等值的USDC。代币的价值由Chainlink Functions从Alpaca Markets获取的实时TSLA价格决定。

### 核心功能

- **实时价格跟踪**：通过Chainlink Functions从Alpaca Markets获取特斯拉实时股价
- **USDC铸造/赎回**：支持使用USDC铸造TPT代币，以及将TPT代币赎回为USDC
- **安全机制**：包含请求限流、余额验证和紧急暂停机制
- **L2支持**：内置L2 sequencer安全检查，确保在L2网络上的安全运行

## 技术栈

- **Solidity 0.8.20** - 智能合约开发语言
- **Chainlink Functions** - 用于获取外部数据(TSLA价格)
- **Foundry** - 智能合约开发、测试和部署框架
- **OpenZeppelin Contracts** - 安全的智能合约库

## 项目结构

```
TSLAToken/
├── src/
│   └── TeslaPriceToken.sol      # 主合约文件
├── script/
│   └── Deploy.s.sol             # 部署脚本
├── test/
│   └── TeslaPriceToken.t.sol    # 测试文件
├── functions/
│   ├── source/
│   │   └── tslaPrice.js         # Chainlink Functions源代码
│   └── uploadSecrets.js         # 密钥上传脚本
├── .env.example                 # 环境变量示例
├── foundry.toml                 # Foundry配置文件
├── Makefile                     # 构建和部署命令
├── DEPLOYMENT_GUIDE.md          # 部署指南
└── USAGE_EXAMPLES.md            # 使用示例
```

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd TSLAToken
```

### 2. 安装依赖

```bash
# 安装Foundry依赖
forge install

# 安装npm依赖
npm install
```

### 3. 配置环境变量

复制`.env.example`文件为`.env`并填入您的配置：

```bash
cp .env.example .env
```

编辑`.env`文件，填入您的配置：
- `SEPOLIA_RPC_URL`: Sepolia测试网RPC URL
- `PRIVATE_KEY`: 部署者私钥
- `ETHERSCAN_API_KEY`: Etherscan API密钥
- `SUBSCRIPTION_ID`: Chainlink Functions订阅ID
- `FUNCTIONS_ROUTER`: Chainlink Functions路由器地址
- `DON_ID`: 去中心化预言机网络ID
- `ALPACA_API_KEY_ID`: Alpaca Markets API密钥ID
- `ALPACA_API_SECRET_KEY`: Alpaca Markets API密钥

### 4. 上传Chainlink Functions密钥

```bash
make upload-secrets
# 或者
npm run upload-secrets
```

### 5. 编译和测试

```bash
# 编译合约
forge build

# 运行测试
forge test
```

### 6. 部署合约

```bash
# 部署到Sepolia测试网
make deploy-sepolia
# 或者
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 使用方法

### 1. 请求TSLA价格

```javascript
await contract.requestTeslaPrice();
```

### 2. 获取当前TSLA价格

```javascript
const price = await contract.getTeslaPrice();
```

### 3. 铸造TPT代币

```javascript
await contract.mintTokens(amountInUSD, { value: amountInUSD });
```

### 4. 赎回TPT代币

```javascript
await contract.redeemTokens(tokenAmount);
```

### 5. 查询代币余额

```javascript
const balance = await contract.balanceOf(address);
```

## 详细文档

- [部署指南](DEPLOYMENT_GUIDE.md) - 详细的部署步骤和说明
- [使用示例](USAGE_EXAMPLES.md) - 详细的使用示例和代码
