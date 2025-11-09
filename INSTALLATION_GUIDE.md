# Tesla Price Token 安装指南

## 系统要求

在开始安装之前，请确保您的系统已安装以下基础软件：

- **Node.js**: 版本 16.x 或更高
- **Git**: 用于克隆项目
- **Foundry**: 智能合约开发框架

## 安装步骤

### 1. 安装 Node.js

如果您尚未安装Node.js，请访问 [Node.js官网](https://nodejs.org/) 下载并安装LTS版本。

验证安装：
```bash
node --version
npm --version
```

### 2. 安装 Git

如果您尚未安装Git，请访问 [Git官网](https://git-scm.com/) 下载并安装。

验证安装：
```bash
git --version
```

### 3. 安装 Foundry

Foundry是以太坊智能合约开发框架，包含Forge（构建工具）、Cast（命令行工具）和Anvil（本地节点）。

在Windows PowerShell中运行以下命令：

```powershell
# 安装Foundryup
irm https://foundry.paradigm.xyz | iex

# 安装Foundry
foundryup
```

验证安装：
```bash
forge --version
cast --version
anvil --version
```

### 4. 克隆项目

如果您还没有克隆项目，请使用以下命令：

```bash
git clone <项目仓库URL>
cd TSLAToken
```

### 5. 安装项目依赖

在项目根目录下运行以下命令安装Node.js依赖：

```bash
npm install
```

### 6. 安装 Foundry 依赖

在项目根目录下运行以下命令安装Solidity依赖：

```bash
forge install
```

### 7. 验证安装

运行以下命令验证所有组件是否正确安装：

```bash
# 编译合约
forge build

# 运行测试
forge test

# 检查项目状态
make help
```

## 项目依赖说明

本项目使用以下主要依赖：

### Solidity 依赖

- **OpenZeppelin Contracts**: 提供安全的ERC20、Ownable、ReentrancyGuard等合约实现
- **Chainlink Contracts**: 提供价格预言机接口和实现

### Foundry 库

- **ds-test**: Foundry的测试框架
- **forge-std**: Foundry的标准库，包含常用的测试工具和脚本

## 环境变量配置

安装完成后，请复制环境变量模板并配置您的环境变量：

```bash
# 复制环境变量模板
cp .env.example .env
```

然后编辑 `.env` 文件，填入您的实际配置值：

```bash
# 网络配置
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here

# 价格预言机地址
TSLA_PRICE_FEED=0x0000000000000000000000000000000000000000  # 替换为实际地址
ETH_PRICE_FEED=0x0000000000000000000000000000000000000000   # 替换为实际地址
```

## 常见问题与解决方案

### Foundry 安装问题

如果在Windows上安装Foundry遇到问题，可以尝试以下替代方法：

1. **使用Scoop包管理器**：
   ```bash
   scoop bucket add forge https://github.com/foundry-rs/foundry-toolchain
   scoop install foundry
   ```

2. **手动下载**：
   - 从 [Foundry GitHub Releases](https://github.com/foundry-rs/foundry/releases) 下载最新版本
   - 解压并将可执行文件路径添加到系统PATH

3. **WSL环境**：
   如果在Windows上遇到权限问题，可以考虑在WSL环境中安装Foundry：
   ```bash
   # 在WSL中
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

### Node.js 依赖问题

如果在安装Node.js依赖时遇到问题，可以尝试：

```bash
# 清除npm缓存
npm cache clean --force

# 删除node_modules和package-lock.json
rm -rf node_modules package-lock.json

# 重新安装
npm install
```

### Foundry 依赖问题

如果在安装Foundry依赖时遇到问题，可以尝试：

```bash
# 清除Foundry缓存
forge clean

# 重新安装依赖
forge install

# 如果特定库安装失败，可以尝试单独安装
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```

### Windows 特定问题

1. **路径长度限制**：
   Windows有路径长度限制，如果遇到问题，可以：
   - 启用长路径支持
   - 将项目放在较短的路径下，如 `C:\dev\TSLAToken`

2. **权限问题**：
   以管理员身份运行PowerShell执行安装命令

3. **防火墙/杀毒软件**：
   某些防火墙或杀毒软件可能会阻止下载，请临时禁用或添加例外

## 开发环境设置

### VS Code 扩展推荐

为了更好的开发体验，建议安装以下VS Code扩展：

- **Solidity by Nomic Foundation**: Solidity语言支持
- **Prettier - Code formatter**: 代码格式化
- **ESLint**: 代码检查
- **GitLens**: Git增强

### 代码格式化

项目使用Prettier进行代码格式化，可以在保存时自动格式化：

```bash
# 安装Prettier
npm install --save-dev prettier

# 格式化所有文件
npx prettier --write .
```

## 下一步

安装完成后，您可以：

1. 阅读 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) 了解如何部署合约
2. 阅读 [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) 了解如何使用项目
3. 运行 `make help` 查看可用的命令
4. 查看 [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md) 了解安全注意事项

---

如果遇到任何问题，请参考项目的 [README.md](README.md) 或在GitHub上创建Issue获取帮助。