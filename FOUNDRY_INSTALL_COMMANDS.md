# Foundry 预编译二进制文件安装命令 (Windows/WSL)

## 步骤1：创建安装目录
```bash
# 创建一个目录来存放Foundry二进制文件
mkdir -p ~/foundry-manual
cd ~/foundry-manual
```

## 步骤2：下载最新版本的Foundry
```bash
# 获取最新版本号 (可选，用于确认最新版本)
curl -s https://api.github.com/repos/foundry-rs/foundry/releases/latest | grep "tag_name" | cut -d '"' -f 4

# 下载适用于Linux的预编译二进制文件 (适用于WSL)
wget https://github.com/foundry-rs/foundry/releases/latest/download/foundry_nightly_linux_amd64.tar.gz

# 或者使用curl下载
# curl -L https://github.com/foundry-rs/foundry/releases/latest/download/foundry_nightly_linux_amd64.tar.gz -o foundry_nightly_linux_amd64.tar.gz
```

## 步骤3：解压下载的文件
```bash
# 解压下载的压缩文件
tar -xzf foundry_nightly_linux_amd64.tar.gz

# 查看解压后的内容
ls -la
```

## 步骤4：将二进制文件移动到系统PATH
```bash
# 创建一个系统级的二进制目录 (如果不存在)
sudo mkdir -p /usr/local/bin

# 将二进制文件复制到系统PATH
sudo cp foundry_nightly_linux_amd64/forge /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/cast /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/anvil /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/chisel /usr/local/bin/

# 或者，如果您想安装在用户目录下
# mkdir -p ~/bin
# cp foundry_nightly_linux_amd64/forge ~/bin/
# cp foundry_nightly_linux_amd64/cast ~/bin/
# cp foundry_nightly_linux_amd64/anvil ~/bin/
# cp foundry_nightly_linux_amd64/chisel ~/bin/
```

## 步骤5：设置可执行权限
```bash
# 为二进制文件添加可执行权限
sudo chmod +x /usr/local/bin/forge
sudo chmod +x /usr/local/bin/cast
sudo chmod +x /usr/local/bin/anvil
sudo chmod +x /usr/local/bin/chisel

# 如果安装在用户目录下
# chmod +x ~/bin/forge
# chmod +x ~/bin/cast
# chmod +x ~/bin/anvil
# chmod +x ~/bin/chisel
```

## 步骤6：更新PATH环境变量
```bash
# 如果~//bin不在PATH中，添加到PATH (仅适用于用户目录安装)
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc

# 重新加载shell配置
source ~/.bashrc

# 或者，如果您使用zsh
# echo 'export PATH="$PATH:$HOME/bin"' >> ~/.zshrc
# source ~/.zshrc
```

## 步骤7：验证安装
```bash
# 验证forge是否安装成功
forge --version

# 验证cast是否安装成功
cast --version

# 验证anvil是否安装成功
anvil --version

# 验证chisel是否安装成功
chisel --version
```

## 完整一键安装脚本
```bash
#!/bin/bash

# 创建安装目录
mkdir -p ~/foundry-manual
cd ~/foundry-manual

# 下载最新版本
echo "下载Foundry最新版本..."
wget https://github.com/foundry-rs/foundry/releases/latest/download/foundry_nightly_linux_amd64.tar.gz

# 解压文件
echo "解压文件..."
tar -xzf foundry_nightly_linux_amd64.tar.gz

# 创建系统二进制目录
sudo mkdir -p /usr/local/bin

# 复制二进制文件到系统PATH
echo "安装二进制文件到系统PATH..."
sudo cp foundry_nightly_linux_amd64/forge /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/cast /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/anvil /usr/local/bin/
sudo cp foundry_nightly_linux_amd64/chisel /usr/local/bin/

# 设置可执行权限
echo "设置可执行权限..."
sudo chmod +x /usr/local/bin/forge
sudo chmod +x /usr/local/bin/cast
sudo chmod +x /usr/local/bin/anvil
sudo chmod +x /usr/local/bin/chisel

# 验证安装
echo "验证安装..."
forge --version
cast --version
anvil --version
chisel --version

echo "Foundry安装完成！"
```

## 注意事项

1. **权限问题**：如果在执行sudo命令时遇到权限问题，请确保您有sudo权限。

2. **PATH更新**：如果您将二进制文件安装到/usr/local/bin，通常不需要手动更新PATH，因为这个目录通常已经在系统PATH中。

3. **版本选择**：上述命令下载的是nightly版本。如果您想下载稳定版本，请访问GitHub Releases页面选择特定版本。

4. **Windows PowerShell**：如果您在Windows PowerShell中工作，可以使用以下PowerShell命令：

```powershell
# 创建目录
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\foundry-manual"
Set-Location "$env:USERPROFILE\foundry-manual"

# 下载文件
Invoke-WebRequest -Uri "https://github.com/foundry-rs/foundry/releases/latest/download/foundry_nightly_windows_amd64.zip" -OutFile "foundry_nightly_windows_amd64.zip"

# 解压文件
Expand-Archive -Path "foundry_nightly_windows_amd64.zip" -DestinationPath .

# 添加到PATH (临时)
$env:PATH += ";$PWD\foundry_nightly_windows_amd64"

# 永久添加到PATH (需要管理员权限)
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$env:USERPROFILE\foundry-manual\foundry_nightly_windows_amd64", "User")
```

5. **更新Foundry**：要更新Foundry，只需重复上述下载和安装步骤，新版本将覆盖旧版本。