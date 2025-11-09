# Tesla Price Token 使用示例

## 概述

本文档提供了Tesla Price Token (TPT)的详细使用示例，包括基本操作、高级功能和常见场景。TPT是一个超额抵押的稳定币，使用ETH作为抵押品，通过Chainlink价格预言机获取TSLA和ETH的实时价格。

## 前置条件

- 已部署TeslaPriceToken合约
- 拥有测试网ETH和USDC（用于测试）
- 已配置环境变量和RPC端点

## 基本使用示例

### 1. 使用ethers.js与合约交互

```javascript
const { ethers } = require("ethers");

// 设置提供者和签名者
const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// 合约地址和ABI（简化版）
const contractAddress = "0x..."; // 您的合约地址
const abi = [
  "function getTeslaPrice() external view returns (uint256)",
  "function getEthPrice() external view returns (uint256)",
  "function depositAndMint() external payable",
  "function redeemAndBurn(uint256 amount) external",
  "function balanceOf(address account) external view returns (uint256)",
  "function getUserCollateral(address user) external view returns (uint256)",
  "function getHealthFactor(address user) external view returns (uint256)",
  "function requestPriceUpdate() external",
  "function getCollateralizationRatio() external view returns (uint256)"
];

// 创建合约实例
const contract = new ethers.Contract(contractAddress, abi, wallet);

// 示例1：获取TSLA价格
async function getTeslaPrice() {
  try {
    const price = await contract.getTeslaPrice();
    console.log(`TSLA Price: $${ethers.utils.formatUnits(price, 8)}`);
    return price;
  } catch (error) {
    console.error("Error getting TSLA price:", error);
  }
}

// 示例2：获取ETH价格
async function getEthPrice() {
  try {
    const price = await contract.getEthPrice();
    console.log(`ETH Price: $${ethers.utils.formatUnits(price, 8)}`);
    return price;
  } catch (error) {
    console.error("Error getting ETH price:", error);
  }
}

// 示例3：存入ETH并铸造TPT代币
async function depositAndMint(ethAmount) {
  try {
    const tx = await contract.depositAndMint({
      value: ethers.utils.parseEther(ethAmount.toString())
    });
    console.log("Transaction hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);
    return receipt;
  } catch (error) {
    console.error("Error depositing and minting:", error);
  }
}

// 示例4：查询TPT代币余额
async function getTokenBalance(address) {
  try {
    const balance = await contract.balanceOf(address);
    console.log(`TPT Balance: ${ethers.utils.formatUnits(balance, 18)} TPT`);
    return balance;
  } catch (error) {
    console.error("Error getting token balance:", error);
  }
}

// 示例5：查询抵押品余额
async function getCollateralBalance(address) {
  try {
    const collateral = await contract.getUserCollateral(address);
    console.log(`Collateral Balance: ${ethers.utils.formatEther(collateral)} ETH`);
    return collateral;
  } catch (error) {
    console.error("Error getting collateral balance:", error);
  }
}

// 示例6：检查健康因子
async function checkHealthFactor(address) {
  try {
    const healthFactor = await contract.getHealthFactor(address);
    console.log(`Health Factor: ${ethers.utils.formatUnits(healthFactor, 18)}`);
    return healthFactor;
  } catch (error) {
    console.error("Error checking health factor:", error);
  }
}

// 示例7：赎回抵押品
async function redeemAndBurn(tokenAmount) {
  try {
    const tx = await contract.redeemAndBurn(
      ethers.utils.parseUnits(tokenAmount.toString(), 18)
    );
    console.log("Transaction hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);
    return receipt;
  } catch (error) {
    console.error("Error redeeming and burning:", error);
  }
}

// 示例8：请求价格更新
async function updatePrices() {
  try {
    const tx = await contract.requestPriceUpdate();
    console.log("Price update transaction hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("Price update confirmed in block:", receipt.blockNumber);
    return receipt;
  } catch (error) {
    console.error("Error updating prices:", error);
  }
}

// 执行示例
async function runExamples() {
  const userAddress = wallet.address;
  
  // 获取价格
  await getTeslaPrice();
  await getEthPrice();
  
  // 存入0.1 ETH并铸造TPT
  await depositAndMint(0.1);
  
  // 查询余额
  await getTokenBalance(userAddress);
  await getCollateralBalance(userAddress);
  
  // 检查健康因子
  await checkHealthFactor(userAddress);
  
  // 赎回50 TPT
  await redeemAndBurn(50);
  
  // 更新价格
  await updatePrices();
}

runExamples();
```

### 2. 使用Cast命令行工具

```bash
# 设置环境变量
export CONTRACT_ADDRESS="0x..."  # 您的合约地址
export RPC_URL="$SEPOLIA_RPC_URL"
export PRIVATE_KEY="your_private_key"

# 1. 获取TSLA价格
cast call $CONTRACT_ADDRESS "getTeslaPrice()" --rpc-url $RPC_URL

# 2. 获取ETH价格
cast call $CONTRACT_ADDRESS "getEthPrice()" --rpc-url $RPC_URL

# 3. 存入0.1 ETH并铸造TPT
cast send $CONTRACT_ADDRESS "depositAndMint()" --value 0.1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 4. 查询TPT余额
cast call $CONTRACT_ADDRESS "balanceOf(address)" $YOUR_ADDRESS --rpc-url $RPC_URL

# 5. 查询抵押品余额
cast call $CONTRACT_ADDRESS "getUserCollateral(address)" $YOUR_ADDRESS --rpc-url $RPC_URL

# 6. 检查健康因子
cast call $CONTRACT_ADDRESS "getHealthFactor(address)" $YOUR_ADDRESS --rpc-url $RPC_URL

# 7. 赎回50 TPT
cast send $CONTRACT_ADDRESS "redeemAndBurn(uint256)" 50000000000000000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 8. 请求价格更新
cast send $CONTRACT_ADDRESS "requestPriceUpdate()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# 9. 获取抵押率
cast call $CONTRACT_ADDRESS "getCollateralizationRatio()" --rpc-url $RPC_URL
```

## 高级使用场景

### 1. 批量操作

```javascript
// 批量铸造TPT代币
async function batchMint(users, ethAmounts) {
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const amount = ethAmounts[i];
    
    // 为每个用户创建签名者
    const userWallet = new ethers.Wallet(user.privateKey, provider);
    const userContract = new ethers.Contract(contractAddress, abi, userWallet);
    
    try {
      const tx = await userContract.depositAndMint({
        value: ethers.utils.parseEther(amount.toString())
      });
      await tx.wait();
      console.log(`Minted TPT for user ${user.address}`);
    } catch (error) {
      console.error(`Failed to mint for user ${user.address}:`, error);
    }
  }
}

// 批量赎回
async function batchRedeem(users, tokenAmounts) {
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const amount = tokenAmounts[i];
    
    const userWallet = new ethers.Wallet(user.privateKey, provider);
    const userContract = new ethers.Contract(contractAddress, abi, userWallet);
    
    try {
      const tx = await userContract.redeemAndBurn(
        ethers.utils.parseUnits(amount.toString(), 18)
      );
      await tx.wait();
      console.log(`Redeemed TPT for user ${user.address}`);
    } catch (error) {
      console.error(`Failed to redeem for user ${user.address}:`, error);
    }
  }
}
```

### 2. 价格监控和自动调整

```javascript
// 价格监控机器人
class PriceMonitor {
  constructor(contract, provider, checkInterval = 60000) { // 默认每分钟检查一次
    this.contract = contract;
    this.provider = provider;
    this.checkInterval = checkInterval;
    this.lastTslaPrice = null;
    this.lastEthPrice = null;
  }

  async start() {
    console.log("Starting price monitor...");
    this.monitorInterval = setInterval(async () => {
      await this.checkPrices();
    }, this.checkInterval);
  }

  async stop() {
    if (this.monitorInterval) {
      clearInterval(this.monitorInterval);
      console.log("Price monitor stopped.");
    }
  }

  async checkPrices() {
    try {
      const tslaPrice = await this.contract.getTeslaPrice();
      const ethPrice = await this.contract.getEthPrice();
      
      const formattedTslaPrice = parseFloat(ethers.utils.formatUnits(tslaPrice, 8));
      const formattedEthPrice = parseFloat(ethers.utils.formatUnits(ethPrice, 8));
      
      console.log(`TSLA: $${formattedTslaPrice}, ETH: $${formattedEthPrice}`);
      
      // 检查价格变化
      if (this.lastTslaPrice && this.lastEthPrice) {
        const tslaChange = ((formattedTslaPrice - this.lastTslaPrice) / this.lastTslaPrice) * 100;
        const ethChange = ((formattedEthPrice - this.lastEthPrice) / this.lastEthPrice) * 100;
        
        if (Math.abs(tslaChange) > 5 || Math.abs(ethChange) > 5) {
          console.log(`Significant price change detected! TSLA: ${tslaChange.toFixed(2)}%, ETH: ${ethChange.toFixed(2)}%`);
          
          // 这里可以添加自动调整逻辑，如发送警报、自动调整抵押品等
          await this.handlePriceChange(tslaChange, ethChange);
        }
      }
      
      this.lastTslaPrice = formattedTslaPrice;
      this.lastEthPrice = formattedEthPrice;
      
      // 检查价格是否过期
      const isPriceExpired = await this.contract.isPriceExpired();
      if (isPriceExpired) {
        console.log("Price data is expired, requesting update...");
        await this.contract.requestPriceUpdate();
      }
    } catch (error) {
      console.error("Error checking prices:", error);
    }
  }

  async handlePriceChange(tslaChange, ethChange) {
    // 实现价格变化处理逻辑
    // 例如：发送邮件通知、调整抵押品、执行交易等
    console.log("Handling significant price change...");
  }
}

// 使用价格监控
async function startPriceMonitoring() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  
  const monitor = new PriceMonitor(contract, provider);
  await monitor.start();
  
  // 运行1小时后停止
  setTimeout(async () => {
    await monitor.stop();
  }, 3600000);
}
```

### 3. 健康因子管理

```javascript
// 健康因子管理工具
class HealthFactorManager {
  constructor(contract, wallet, targetHealthFactor = 200) {
    this.contract = contract;
    this.wallet = wallet;
    this.targetHealthFactor = targetHealthFactor;
  }

  async checkHealthFactor(userAddress) {
    try {
      const healthFactor = await this.contract.getHealthFactor(userAddress);
      const formattedHF = parseFloat(ethers.utils.formatUnits(healthFactor, 18));
      return formattedHF;
    } catch (error) {
      console.error("Error checking health factor:", error);
      return null;
    }
  }

  async adjustCollateral(userAddress, targetHF) {
    const currentHF = await this.checkHealthFactor(userAddress);
    
    if (currentHF === null) {
      console.error("Could not retrieve health factor");
      return;
    }
    
    if (currentHF < targetHF) {
      console.log(`Health factor (${currentHF}) is below target (${targetHF}), adding collateral...`);
      await this.addCollateral(userAddress, targetHF);
    } else if (currentHF > targetHF * 1.5) {
      console.log(`Health factor (${currentHF}) is well above target (${targetHF}), consider reducing collateral`);
      // 这里可以添加减少抵押品的逻辑
    } else {
      console.log(`Health factor (${currentHF}) is within acceptable range`);
    }
  }

  async addCollateral(userAddress, targetHF) {
    try {
      // 计算需要添加的抵押品数量
      const userBalance = await this.contract.getUserCollateral(userAddress);
      const tokenBalance = await this.contract.balanceOf(userAddress);
      const ethPrice = await this.contract.getEthPrice();
      const collateralRatio = await this.contract.getCollateralizationRatio();
      
      // 简化计算，实际实现需要更精确的数学计算
      const currentValue = parseFloat(ethers.utils.formatEther(userBalance)) * parseFloat(ethers.utils.formatUnits(ethPrice, 8));
      const tokenValue = parseFloat(ethers.utils.formatUnits(tokenBalance, 18));
      const requiredCollateral = (tokenValue * parseFloat(collateralRatio.toString()) / 100) / parseFloat(ethers.utils.formatUnits(ethPrice, 8));
      const additionalCollateral = requiredCollateral - parseFloat(ethers.utils.formatEther(userBalance));
      
      if (additionalCollateral > 0) {
        console.log(`Adding ${additionalCollateral.toFixed(6)} ETH as collateral`);
        const tx = await this.contract.depositAndMint({
          value: ethers.utils.parseEther(additionalCollateral.toString())
        });
        await tx.wait();
        console.log("Collateral added successfully");
      } else {
        console.log("No additional collateral needed");
      }
    } catch (error) {
      console.error("Error adding collateral:", error);
    }
  }

  async monitorHealthFactor(userAddress, checkInterval = 300000) { // 默认每5分钟检查一次
    console.log(`Starting health factor monitoring for ${userAddress}...`);
    
    this.monitorInterval = setInterval(async () => {
      await this.adjustCollateral(userAddress, this.targetHealthFactor);
    }, checkInterval);
  }

  stopMonitoring() {
    if (this.monitorInterval) {
      clearInterval(this.monitorInterval);
      console.log("Health factor monitoring stopped");
    }
  }
}

// 使用健康因子管理
async function manageHealthFactor() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  
  const hfManager = new HealthFactorManager(contract, wallet);
  await hfManager.monitorHealthFactor(wallet.address);
  
  // 运行30分钟后停止
  setTimeout(() => {
    hfManager.stopMonitoring();
  }, 1800000);
}
```

## 常见使用场景

### 1. 基本抵押和铸造

```javascript
// 场景：用户想抵押0.5 ETH，铸造价值250美元的TPT
async function basicMintingScenario() {
  const ethAmount = 0.5;
  const expectedTPTValue = 250; // 美元
  
  // 1. 检查当前价格
  const ethPrice = await contract.getEthPrice();
  const formattedEthPrice = parseFloat(ethers.utils.formatUnits(ethPrice, 8));
  const ethValue = ethAmount * formattedEthPrice;
  
  console.log(`0.5 ETH is worth $${ethValue.toFixed(2)} at current price`);
  
  // 2. 检查是否可以铸造期望数量的TPT
  const collateralRatio = await contract.getCollateralizationRatio();
  const maxTPTValue = ethValue / (parseFloat(collateralRatio.toString()) / 100);
  
  console.log(`Maximum TPT value you can mint: $${maxTPTValue.toFixed(2)}`);
  
  if (expectedTPTValue <= maxTPTValue) {
    // 3. 执行抵押和铸造
    const tx = await contract.depositAndMint({
      value: ethers.utils.parseEther(ethAmount.toString())
    });
    const receipt = await tx.wait();
    console.log("Successfully minted TPT tokens");
    
    // 4. 检查余额和健康因子
    const balance = await contract.balanceOf(wallet.address);
    const healthFactor = await contract.getHealthFactor(wallet.address);
    
    console.log(`TPT Balance: ${ethers.utils.formatUnits(balance, 18)} TPT`);
    console.log(`Health Factor: ${ethers.utils.formatUnits(healthFactor, 18)}`);
  } else {
    console.log(`Cannot mint $${expectedTPTValue} worth of TPT with 0.5 ETH at current prices`);
  }
}
```

### 2. 价格波动应对

```javascript
// 场景：价格大幅下跌，用户需要增加抵押品或赎回部分TPT
async function handlePriceDrop() {
  // 1. 检查当前健康因子
  const healthFactor = await contract.getHealthFactor(wallet.address);
  const formattedHF = parseFloat(ethers.utils.formatUnits(healthFactor, 18));
  
  console.log(`Current Health Factor: ${formattedHF}`);
  
  // 2. 如果健康因子过低，采取措施
  if (formattedHF < 150) {
    console.log("Health factor is critically low, taking action...");
    
    // 选项1：增加抵押品
    const additionalEth = 0.2;
    const tx = await contract.depositAndMint({
      value: ethers.utils.parseEther(additionalEth.toString())
    });
    await tx.wait();
    console.log("Added additional collateral");
    
    // 检查更新后的健康因子
    const newHF = await contract.getHealthFactor(wallet.address);
    console.log(`New Health Factor: ${ethers.utils.formatUnits(newHF, 18)}`);
    
    // 选项2：赎回部分TPT（如果增加抵押品不可行）
    // const tokenBalance = await contract.balanceOf(wallet.address);
    // const redeemAmount = ethers.utils.formatUnits(tokenBalance, 18) * 0.3; // 赎回30%
    // await contract.redeemAndBurn(
    //   ethers.utils.parseUnits(redeemAmount.toString(), 18)
    // );
  }
}
```

### 3. 自动化投资组合管理

```javascript
// 场景：用户希望维持特定的抵押率，自动调整仓位
class PortfolioManager {
  constructor(contract, wallet, targetCollateralRatio = 250) {
    this.contract = contract;
    this.wallet = wallet;
    this.targetCollateralRatio = targetCollateralRatio;
  }

  async getCurrentCollateralRatio(userAddress) {
    const collateral = await this.contract.getUserCollateral(userAddress);
    const tokenBalance = await this.contract.balanceOf(userAddress);
    const ethPrice = await this.contract.getEthPrice();
    
    const collateralValue = parseFloat(ethers.utils.formatEther(collateral)) * 
                           parseFloat(ethers.utils.formatUnits(ethPrice, 8));
    const tokenValue = parseFloat(ethers.utils.formatUnits(tokenBalance, 18));
    
    if (tokenValue === 0) return Infinity;
    
    return (collateralValue / tokenValue) * 100;
  }

  async rebalancePortfolio(userAddress) {
    const currentRatio = await this.getCurrentCollateralRatio(userAddress);
    console.log(`Current collateral ratio: ${currentRatio.toFixed(2)}%`);
    
    if (Math.abs(currentRatio - this.targetCollateralRatio) < 10) {
      console.log("Portfolio is balanced, no action needed");
      return;
    }
    
    if (currentRatio < this.targetCollateralRatio) {
      // 需要增加抵押品或减少TPT
      console.log("Adding collateral to reach target ratio...");
      await this.addCollateral(userAddress);
    } else {
      // 可以减少抵押品或增加TPT
      console.log("Collateral ratio is high, consider minting more TPT or reducing collateral");
      // 这里可以添加减少抵押品的逻辑
    }
  }

  async addCollateral(userAddress) {
    // 计算需要添加的抵押品数量
    const currentRatio = await this.getCurrentCollateralRatio(userAddress);
    const tokenBalance = await this.contract.balanceOf(userAddress);
    const ethPrice = await this.contract.getEthPrice();
    
    const tokenValue = parseFloat(ethers.utils.formatUnits(tokenBalance, 18));
    const requiredCollateral = (tokenValue * this.targetCollateralRatio / 100) / 
                              parseFloat(ethers.utils.formatUnits(ethPrice, 8));
    
    const currentCollateral = await this.contract.getUserCollateral(userAddress);
    const currentCollateralValue = parseFloat(ethers.utils.formatEther(currentCollateral)) * 
                                  parseFloat(ethers.utils.formatUnits(ethPrice, 8));
    
    const additionalCollateral = requiredCollateral - (currentCollateralValue / parseFloat(ethers.utils.formatUnits(ethPrice, 8)));
    
    if (additionalCollateral > 0) {
      console.log(`Adding ${additionalCollateral.toFixed(6)} ETH as collateral`);
      const tx = await this.contract.depositAndMint({
        value: ethers.utils.parseEther(additionalCollateral.toString())
      });
      await tx.wait();
      console.log("Collateral added successfully");
    }
  }

  async startMonitoring(userAddress, checkInterval = 600000) { // 默认每10分钟检查一次
    console.log(`Starting portfolio monitoring for ${userAddress}...`);
    
    this.monitorInterval = setInterval(async () => {
      await this.rebalancePortfolio(userAddress);
    }, checkInterval);
  }

  stopMonitoring() {
    if (this.monitorInterval) {
      clearInterval(this.monitorInterval);
      console.log("Portfolio monitoring stopped");
    }
  }
}

// 使用投资组合管理
async function managePortfolio() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(contractAddress, abi, wallet);
  
  const portfolioManager = new PortfolioManager(contract, wallet);
  await portfolioManager.startMonitoring(wallet.address);
  
  // 运行1小时后停止
  setTimeout(() => {
    portfolioManager.stopMonitoring();
  }, 3600000);
}
```

## 错误处理和最佳实践

### 1. 交易重试机制

```javascript
// 带重试机制的交易执行
async function executeWithRetry(transactionFunction, maxRetries = 3) {
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const result = await transactionFunction();
      return result;
    } catch (error) {
      retries++;
      console.error(`Attempt ${retries} failed:`, error.message);
      
      if (retries >= maxRetries) {
        throw new Error(`Transaction failed after ${maxRetries} attempts: ${error.message}`);
      }
      
      // 指数退避
      const delay = 1000 * Math.pow(2, retries);
      console.log(`Retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

// 使用示例
async function safeDepositAndMint(ethAmount) {
  return executeWithRetry(async () => {
    const gasPrice = await provider.getGasPrice();
    const gasLimit = 500000; // 估算的Gas限制
    
    const tx = await contract.depositAndMint({
      value: ethers.utils.parseEther(ethAmount.toString()),
      gasPrice: gasPrice.mul(110).div(100), // 增加10%的Gas价格
      gasLimit: gasLimit
    });
    
    const receipt = await tx.wait();
    console.log("Transaction successful:", receipt.transactionHash);
    return receipt;
  });
}
```

### 2. Gas优化

```javascript
// Gas优化的批量操作
async function optimizedBatchOperations(operations) {
  // 按类型分组操作
  const deposits = [];
  const redeems = [];
  
  operations.forEach(op => {
    if (op.type === 'deposit') {
      deposits.push(op);
    } else if (op.type === 'redeem') {
      redeems.push(op);
    }
  });
  
  // 批量执行存款
  if (deposits.length > 0) {
    const totalEthAmount = deposits.reduce((sum, op) => sum + op.amount, 0);
    await executeWithRetry(() => 
      contract.depositAndMint({
        value: ethers.utils.parseEther(totalEthAmount.toString())
      })
    );
  }
  
  // 批量执行赎回
  for (const redeem of redeems) {
    await executeWithRetry(() => 
      contract.redeemAndBurn(
        ethers.utils.parseUnits(redeem.amount.toString(), 18)
      )
    );
  }
}
```

### 3. 事件监听

```javascript
// 监听合约事件
async function setupEventListeners() {
  // 监听存款事件
  contract.on("Deposit", (user, amount, event) => {
    console.log(`Deposit event: User ${user} deposited ${ethers.utils.formatEther(amount)} ETH`);
  });
  
  // 监听铸造事件
  contract.on("Mint", (user, amount, event) => {
    console.log(`Mint event: User ${user} minted ${ethers.utils.formatUnits(amount, 18)} TPT`);
  });
  
  // 监听赎回事件
  contract.on("Redeem", (user, amount, event) => {
    console.log(`Redeem event: User ${user} redeemed ${ethers.utils.formatUnits(amount, 18)} TPT`);
  });
  
  // 监听价格更新事件
  contract.on("PriceUpdated", (asset, price, timestamp, event) => {
    console.log(`Price updated: ${asset} price is now $${ethers.utils.formatUnits(price, 8)} at ${new Date(timestamp.toNumber() * 1000)}`);
  });
  
  // 监听健康因子警告事件
  contract.on("HealthFactorWarning", (user, healthFactor, event) => {
    console.log(`Health factor warning: User ${user} has health factor ${ethers.utils.formatUnits(healthFactor, 18)}`);
  });
}
```

## 总结

本文档提供了Tesla Price Token的详细使用示例，包括：

1. **基本操作**：获取价格、存款、铸造、赎回等
2. **高级功能**：批量操作、价格监控、健康因子管理
3. **常见场景**：基本抵押、价格波动应对、投资组合管理
4. **最佳实践**：错误处理、Gas优化、事件监听

通过这些示例，您可以更好地理解和使用Tesla Price Token合约，实现您的DeFi策略。

如需更多信息，请参考：
- [README.md](README.md)
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- [QUICK_START.md](QUICK_START.md)