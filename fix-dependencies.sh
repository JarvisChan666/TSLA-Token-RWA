#!/bin/bash

# 解决Foundry nightly版本依赖问题的脚本

echo "正在解决Foundry nightly版本依赖问题..."

# 1. 清理现有依赖
echo "1. 清理现有依赖..."
rm -rf lib/
rm -rf out/
rm -rf cache/

# 2. 重新安装依赖
echo "2. 重新安装依赖..."
forge install

# 3. 尝试构建
echo "3. 尝试构建项目..."
forge build

# 4. 如果构建失败，尝试安装特定版本的依赖
if [ $? -ne 0 ]; then
    echo "4. 构建失败，尝试安装特定版本的依赖..."
    
    # 安装chainlink-contracts
    forge install smartcontractkit/chainlink-brownie-contracts --no-commit
    
    # 安装openzeppelin-contracts
    forge install OpenZeppelin/openzeppelin-contracts --no-commit
    
    # 安装forge-std
    forge install foundry-rs/forge-std --no-commit
    
    # 再次尝试构建
    echo "5. 再次尝试构建..."
    forge build
fi

echo "完成！"