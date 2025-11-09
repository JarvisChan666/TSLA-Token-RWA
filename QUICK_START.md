# Tesla Price Token 快速开始指南

## 概述

本指南将帮助您在15分钟内完成Tesla Price Token项目的安装、部署和基本使用。Tesla Price Token是一个超额抵押的稳定币，使用ETH作为抵押品，通过Chainlink价格预言机获取TSLA和ETH的实时价格。

## 前置条件

在开始之前，请确保您已安装以下软件：

- **Node.js**: 版本 16.x 或更高
- **Git**: 用于克隆项目
- **Foundry**: 智能合约开发框架
- **MetaMask**: 浏览器钱包（用于测试网交互）

## 快速开始步骤

### 1. 克隆项目

```bash
git clone <项目仓库URL>
cd TSLAToken
```

### 2. 安装依赖

```bash
# 安装Node.js依赖
npm install

# 安装Foundry依赖
forge install
```

### 3. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env
```

编辑`.env`文件，填入以下信息：

```bash
# 网络配置
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here

# 价格预言机地址（Sepolia测试网）
TSLA_PRICE_FEED=0x5EE36631590451608A0C4C4F4764a6a4c783eB66
ETH_PRICE_FEED=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

### 4. 获取测试网ETH

1. 访问 [Sepolia Faucet](https://sepoliafaucet.com/)
2. 输入您的钱包地址
3. 获取测试网ETH（至少需要0.1 ETH用于部署和测试）

### 5. 编译和测试合约

```bash
# 编译合约
forge build

# 运行测试
forge test
```

### 6. 部署合约

```bash
# 部署到Sepolia测试网
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

部署成功后，您将看到类似以下输出：

```
TeslaPriceToken deployed at: 0x1234567890abcdef1234567890abcdef12345678
```

### 7. 测试合约交互

#### 获取价格

```bash
# 获取TSLA价格
cast call <CONTRACT_ADDRESS> "getTeslaPrice()" --rpc-url $SEPOLIA_RPC_URL

# 获取ETH价格
cast call <CONTRACT_ADDRESS> "getEthPrice()" --rpc-url $SEPOLIA_RPC_URL
```

#### 存入ETH并铸造TPT代币

```bash
# 存入0.1 ETH并铸造价值50美元的TPT代币
cast send <CONTRACT_ADDRESS> "depositAndMint()" --value 0.1ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

#### 查询余额

```bash
# 查询TPT代币余额
cast call <CONTRACT_ADDRESS> "balanceOf(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL

# 查询抵押品余额
cast call <CONTRACT_ADDRESS> "getUserCollateral(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

#### 检查健康因子

```bash
# 检查您的健康因子
cast call <CONTRACT_ADDRESS> "getHealthFactor(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

#### 赎回抵押品

```bash
# 赎回价值50美元的TPT代币，获得相应ETH
cast send <CONTRACT_ADDRESS> "redeemAndBurn(uint256)" 50000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

## 使用Web界面

### 1. 添加合约到MetaMask

1. 打开MetaMask
2. 点击"添加代币"
3. 选择"自定义代币"
4. 输入合约地址
5. 代币符号将自动填充为"TPT"
6. 点击"添加代币"

### 2. 与合约交互

1. 访问 [Etherscan](https://sepolia.etherscan.io/)
2. 搜索您的合约地址
3. 点击"Contract"标签
4. 点击"Write Contract"
5. 连接您的MetaMask钱包
6. 使用以下函数进行交互：
   - `depositAndMint`: 存入ETH并铸造TPT
   - `redeemAndBurn`: 赎回ETH并销毁TPT
   - `requestPriceUpdate`: 请求价格更新

## 常见问题

### 1. 部署失败

**问题**: Gas不足
```bash
# 解决方案：增加Gas限制
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --gas-limit 3000000
```

**问题**: 交易失败
```bash
# 解决方案：检查交易状态
cast receipt <TRANSACTION_HASH> --rpc-url $SEPOLIA_RPC_URL
```

### 2. 价格获取失败

**问题**: 价格数据过期
```bash
# 解决方案：请求价格更新
cast send <CONTRACT_ADDRESS> "requestPriceUpdate()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

### 3. 铸造失败

**问题**: 抵押品不足
```bash
# 解决方案：增加抵押品金额
cast send <CONTRACT_ADDRESS> "depositAndMint()" --value 0.2ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

**问题**: 健康因子过低
```bash
# 解决方案：检查健康因子，增加抵押品或减少代币数量
cast call <CONTRACT_ADDRESS> "getHealthFactor(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

## 下一步

完成快速开始后，您可以：

1. 阅读 [README.md](README.md) 了解项目详细信息
2. 查看 [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) 了解更多使用示例
3. 参考 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) 了解高级部署选项
4. 探索测试文件了解合约功能

## 合约核心功能

### 存款和铸造

- `depositAndMint()`: 存入ETH并铸造TPT代币
- 抵押率要求：200%（每1美元TPT需要2美元ETH抵押）
- 最小存款金额：0.01 ETH

### 赎回和销毁

- `redeemAndBurn(uint256 amount)`: 销毁TPT代币并赎回相应ETH
- 赎回后必须保持抵押率不低于200%

### 价格管理

- `getTeslaPrice()`: 获取TSLA价格
- `getEthPrice()`: 获取ETH价格
- `requestPriceUpdate()`: 请求价格更新
- 价格数据过期时间：3小时

### 健康因子

- `getHealthFactor(address user)`: 获取用户健康因子
- 健康因子阈值：150%
- 低于阈值将面临清算风险

## 安全提示

1. **测试网使用**: 仅在测试网上进行测试，不要使用主网资金
2. **私钥安全**: 不要在公共代码库中提交私钥
3. **小额测试**: 初次使用时请用小额资金进行测试
4. **价格监控**: 密切关注价格变化，及时调整抵押品

## 获取帮助

如果您遇到任何问题：

1. 查看项目的 [README.md](README.md)
2. 阅读 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
3. 在GitHub上创建Issue
4. 加入项目社区讨论

---

恭喜！您已成功完成Tesla Price Token的快速开始。现在您可以开始探索这个超额抵押的特斯拉股价代币化项目了！