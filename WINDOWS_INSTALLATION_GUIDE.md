# Windows系统Foundry安装指南

## 问题分析

您遇到的错误是因为您使用了Linux/Mac系统的安装命令，但在Windows上需要使用PowerShell特定的命令。

## 正确的Windows安装方法

### 方法1：使用PowerShell安装（推荐）

1. **打开PowerShell（以管理员身份运行）**

2. **执行以下命令安装Foundryup**：
   ```powershell
   irm https://foundry.paradigm.xyz | iex
   ```

3. **安装Foundry**：
   ```powershell
   foundryup
   ```

4. **验证安装**：
   ```powershell
   forge --version
   cast --version
   anvil --version
   ```

### 方法2：使用Scoop包管理器

如果方法1不成功，可以尝试使用Scoop：

1. **安装Scoop（如果尚未安装）**：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   irm get.scoop.sh | iex
   ```

2. **添加Foundry存储桶**：
   ```powershell
   scoop bucket add forge https://github.com/foundry-rs/foundry-toolchain
   ```

3. **安装Foundry**：
   ```powershell
   scoop install foundry
   ```

### 方法3：手动安装

如果上述方法都不成功，可以手动下载安装：

1. **访问Foundry GitHub Releases**：
   打开浏览器访问 https://github.com/foundry-rs/foundry/releases

2. **下载最新版本**：
   下载适合Windows的最新版本压缩包

3. **解压文件**：
   将压缩包解压到您选择的目录，例如 `C:\foundry`

4. **添加到系统PATH**：
   - 打开"系统属性" → "高级" → "环境变量"
   - 在"系统变量"中找到"Path"，点击"编辑"
   - 点击"新建"，添加Foundry的解压路径，例如 `C:\foundry\bin`

5. **验证安装**：
   打开新的PowerShell窗口，运行：
   ```powershell
   forge --version
   ```

## 验证安装成功

安装完成后，在PowerShell中运行以下命令验证：

```powershell
# 检查Forge版本
forge --version

# 检查Cast版本
cast --version

# 检查Anvil版本
anvil --version
```

如果这些命令都能正常显示版本信息，说明安装成功。

## 继续项目安装

Foundry安装成功后，继续安装项目依赖：

```powershell
# 进入项目目录
cd "H:\Project\Blockchain Project\TSLAToken"

# 安装Node.js依赖
npm install

# 安装Foundry依赖
forge install

# 验证安装
forge build
```

## 常见问题解决

### PowerShell执行策略问题

如果遇到"无法加载文件...因为在此系统上禁止运行脚本"的错误：

```powershell
# 临时允许脚本执行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或者以管理员身份运行PowerShell后执行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### 路径问题

如果安装后仍无法识别`forge`命令：

1. 确认Foundry安装路径已添加到系统PATH
2. 重启PowerShell或计算机
3. 使用完整路径测试，例如：
   ```powershell
   C:\foundry\bin\forge --version
   ```

### 代理问题

如果您在企业网络环境中，可能需要配置代理：

```powershell
# 设置HTTP代理
$env:HTTP_PROXY = "http://proxy.company.com:port"
$env:HTTPS_PROXY = "http://proxy.company.com:port"
```

---

如果仍有问题，请参考Foundry官方文档：https://book.getfoundry.sh/getting-started/installation