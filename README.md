# Tesla Price Token (TPT)

一个基于区块链的特斯拉股票代币化项目，使用超额抵押机制和Chainlink价格预言机，实现与特斯拉(TSLA)股票价格挂钩的代币铸造和赎回。

## 项目概述

Tesla Price Token (TPT) 是一种ERC20代币，其价值与特斯拉(TSLA)股票价格挂钩。本项目对标 [DeFi-Unchained-IITK/Asset-Tokenization](https://github.com/DeFi-Unchained-IITK/Asset-Tokenization) 项目的MSFT资产代币化实现，采用超额抵押机制，用户可以使用ETH作为抵押品铸造TPT代币，也可以随时赎回TPT代币取回抵押的ETH。代币的价值由Chainlink价格预言机提供的实时TSLA和ETH价格决定。

### 核心特性

- **超额抵押机制**：需要200%的ETH抵押品才能铸造TPT代币，确保系统安全
- **健康因子监控**：实时计算和监控用户账户的健康状况，防止清算风险
- **双价格预言机**：使用Chainlink TSLA/USD和ETH/USD价格预言机，确保价格准确性
- **价格数据验证**：通过OracleLib库验证价格数据的新鲜度，防止使用过期价格
- **安全机制**：包含暂停/恢复、紧急提取、清算保护等多种安全机制
- **模块化设计**：将价格验证逻辑分离到独立库中，提高代码可维护性

## 技术栈

- **Solidity 0.8.20** - 智能合约开发语言
- **Chainlink Price Feeds** - 用于获取TSLA和ETH价格数据
- **Foundry** - 智能合约开发、测试和部署框架
- **OpenZeppelin Contracts** - 安全的智能合约库

## 项目结构

```
TSLAToken/
├── src/
│   ├── TeslaPriceToken.sol     # 主合约文件
│   └── library/
│       └── OracleLib.sol        # 价格数据验证库
├── script/
│   └── Deploy.s.sol             # 部署脚本
├── test/
│   ├── TeslaPriceToken.t.sol    # 主合约测试
│   └── mocks/
│       └── MockV3Aggregator.sol # 模拟价格馈送合约
├── .env.example                 # 环境变量示例
├── foundry.toml                 # Foundry配置文件
├── Makefile                     # 构建和部署命令
├── DEPLOYMENT_GUIDE.md          # 部署指南
├── USAGE_EXAMPLES.md            # 使用示例
├── SECURITY_CHECKLIST.md        # 安全检查清单
├── PROJECT_SUMMARY.md           # 项目总结
└── README.md                    # 项目说明
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

# 安装npm依赖（如果需要）
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
- `TSLA_PRICE_FEED`: TSLA/USD价格预言机地址
- `ETH_PRICE_FEED`: ETH/USD价格预言机地址

### 4. 编译和测试

```bash
# 编译合约
forge build

# 运行测试
forge test
```

### 5. 部署合约

```bash
# 部署到Sepolia测试网
make deploy-sepolia
# 或者
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 核心功能

### 1. 存入ETH并铸造TPT代币

```javascript
await contract.depositAndMnt(amountInETH);
```

### 2. 赎回TPT代币并取回ETH

```javascript
await contract.redeemAndBurn(tokenAmount);
```

### 3. 添加抵押品

```javascript
await contract.addCollateral({ value: amountInETH });
```

### 4. 提取抵押品

```javascript
await contract.withdrawCollateral(amountInETH);
```

### 5. 获取健康因子

```javascript
const healthFactor = await contract.getHealthFactor(userAddress);
```

### 6. 查询代币余额

```javascript
const balance = await contract.balanceOf(address);
```

## 详细文档

- [安装指南](INSTALLATION_GUIDE.md) - 详细的安装步骤和说明
- [部署指南](DEPLOYMENT_GUIDE.md) - 详细的部署步骤和说明
- [使用示例](USAGE_EXAMPLES.md) - 详细的使用示例和代码
- [安全检查清单](SECURITY_CHECKLIST.md) - 安全检查清单
- [项目总结](PROJECT_SUMMARY.md) - 项目总结和技术实现

## 合约参数

- **最大供应量**: 1,000,000 TPT代币
- **抵押率**: 200%（需要价值2倍于代币的ETH抵押品）
- **清算阈值**: 50%（抵押品价值低于代币价值的50%时将被清算）
- **价格过期时间**: 3小时（超过3小时未更新的价格将被视为过期）

## 安全特性

- **暂停/恢复机制**: 合约所有者可以暂停/恢复合约操作
- **紧急提取**: 在紧急情况下，所有者可以提取合约中的ETH
- **价格数据验证**: 确保使用的价格数据是最新且有效的
- **健康因子检查**: 防止用户抵押不足导致的风险
- **重入攻击防护**: 使用OpenZeppelin的ReentrancyGuard防护重入攻击

## 许可证

本项目采用MIT许可证 - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

## 支持

如果您在使用过程中遇到问题，可以：

1. 查看项目的文档
2. 在GitHub上创建Issue
3. 加入我们的社区讨论

---

**注意**: 本项目仅用于教育和演示目的，在生产环境中使用前请进行充分的安全审计。
