# Tesla Price Token 使用示例

本文档提供了如何使用Tesla Price Token (TPT)的示例代码和说明。

## 前置条件

- 已部署TeslaPriceToken合约
- 已在Sepolia测试网上获取一些ETH
- 已获取一些USDC（Sepolia测试网）

## 基本使用流程

### 1. 请求TSLA价格

首先，您需要请求最新的TSLA价格：

```javascript
// 使用ethers.js
const { ethers } = require("ethers");

// 设置提供者和签名者
const provider = new ethers.providers.JsonRpcProvider("YOUR_SEPOLIA_RPC_URL");
const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);

// 合约地址和ABI
const contractAddress = "YOUR_CONTRACT_ADDRESS";
const abi = [
    "function requestTeslaPrice() external",
    "function getTeslaPrice() public view returns (uint256)",
    "function getLastResponse() external view returns (string memory)",
    "function getLastError() external view returns (string memory)"
];

// 创建合约实例
const contract = new ethers.Contract(contractAddress, abi, wallet);

// 请求TSLA价格
async function requestPrice() {
    try {
        const tx = await contract.requestTeslaPrice();
        console.log("Transaction hash:", tx.hash);
        await tx.wait();
        console.log("Price request successful!");
    } catch (error) {
        console.error("Error requesting price:", error);
    }
}

requestPrice();
```

### 2. 获取TSLA价格

```javascript
// 获取当前TSLA价格
async function getCurrentPrice() {
    try {
        const price = await contract.getTeslaPrice();
        // 价格以18位小数返回，转换为美元价格
        const priceInUSD = ethers.utils.formatUnits(price, 18);
        console.log(`Current TSLA price: $${priceInUSD}`);
        return priceInUSD;
    } catch (error) {
        console.error("Error getting price:", error);
    }
}

getCurrentPrice();
```

### 3. 铸造TPT代币

```javascript
// 铸造TPT代币（需要发送USDC）
async function mintTokens(amountInUSD) {
    try {
        // 将USD转换为wei（18位小数）
        const amountInWei = ethers.utils.parseUnits(amountInUSD.toString(), 18);
        
        // 调用mintTokens函数并发送USDC
        const tx = await contract.mintTokens(amountInWei, {
            value: amountInWei
        });
        
        console.log("Transaction hash:", tx.hash);
        const receipt = await tx.wait();
        
        // 从事件中获取铸造的代币数量
        const mintEvent = receipt.events.find(e => e.event === "TokensMinted");
        const tokensMinted = ethers.utils.formatUnits(mintEvent.args.amount, 18);
        
        console.log(`Successfully minted ${tokensMinted} TPT tokens`);
        return tokensMinted;
    } catch (error) {
        console.error("Error minting tokens:", error);
    }
}

// 示例：铸造价值100美元的TPT代币
mintTokens(100);
```

### 4. 查询代币余额

```javascript
// 查询TPT代币余额
async function getTokenBalance(address) {
    try {
        const balance = await contract.balanceOf(address);
        const formattedBalance = ethers.utils.formatUnits(balance, 18);
        console.log(`TPT balance: ${formattedBalance}`);
        return formattedBalance;
    } catch (error) {
        console.error("Error getting balance:", error);
    }
}

// 查询自己的余额
getTokenBalance(wallet.address);
```

### 5. 赎回TPT代币

```javascript
// 赎回TPT代币换取USDC
async function redeemTokens(tokenAmount) {
    try {
        // 将代币数量转换为wei
        const amountInWei = ethers.utils.parseUnits(tokenAmount.toString(), 18);
        
        // 调用redeemTokens函数
        const tx = await contract.redeemTokens(amountInWei);
        
        console.log("Transaction hash:", tx.hash);
        const receipt = await tx.wait();
        
        // 从事件中获取赎回的USD金额
        const redeemEvent = receipt.events.find(e => e.event === "TokensRedeemed");
        const usdAmount = ethers.utils.formatUnits(redeemEvent.args.amount, 18);
        
        console.log(`Successfully redeemed ${tokenAmount} TPT for $${usdAmount}`);
        return usdAmount;
    } catch (error) {
        console.error("Error redeeming tokens:", error);
    }
}

// 示例：赎回5个TPT代币
redeemTokens(5);
```

## 完整示例

以下是一个完整的示例，展示了如何使用Tesla Price Token：

```javascript
const { ethers } = require("ethers");

async function main() {
    // 设置提供者和签名者
    const provider = new ethers.providers.JsonRpcProvider("YOUR_SEPOLIA_RPC_URL");
    const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);
    
    // 合约地址和ABI
    const contractAddress = "YOUR_CONTRACT_ADDRESS";
    const abi = [
        "function requestTeslaPrice() external",
        "function getTeslaPrice() public view returns (uint256)",
        "function mintTokens(uint256 amountInUSD) external payable",
        "function redeemTokens(uint256 tokenAmount) external",
        "function balanceOf(address) public view returns (uint256)",
        "event TokensMinted(address indexed to, uint256 amount)",
        "event TokensRedeemed(address indexed from, uint256 amount)"
    ];
    
    // 创建合约实例
    const contract = new ethers.Contract(contractAddress, abi, wallet);
    
    try {
        // 1. 请求TSLA价格
        console.log("Requesting TSLA price...");
        const requestTx = await contract.requestTeslaPrice();
        await requestTx.wait();
        console.log("Price request sent successfully!");
        
        // 等待一段时间让预言机响应
        await new Promise(resolve => setTimeout(resolve, 30000));
        
        // 2. 获取当前TSLA价格
        const price = await contract.getTeslaPrice();
        const priceInUSD = ethers.utils.formatUnits(price, 18);
        console.log(`Current TSLA price: $${priceInUSD}`);
        
        // 3. 铸造TPT代币
        console.log("Minting TPT tokens...");
        const mintAmount = 100; // 100 USD
        const mintTx = await contract.mintTokens(
            ethers.utils.parseUnits(mintAmount.toString(), 18),
            { value: ethers.utils.parseUnits(mintAmount.toString(), 18) }
        );
        const mintReceipt = await mintTx.wait();
        
        const mintEvent = mintReceipt.events.find(e => e.event === "TokensMinted");
        const tokensMinted = ethers.utils.formatUnits(mintEvent.args.amount, 18);
        console.log(`Successfully minted ${tokensMinted} TPT tokens`);
        
        // 4. 查询代币余额
        const balance = await contract.balanceOf(wallet.address);
        const formattedBalance = ethers.utils.formatUnits(balance, 18);
        console.log(`Current TPT balance: ${formattedBalance}`);
        
        // 5. 赎回部分代币
        console.log("Redeeming TPT tokens...");
        const redeemAmount = parseFloat(tokensMinted) / 2; // 赎回一半
        const redeemTx = await contract.redeemTokens(
            ethers.utils.parseUnits(redeemAmount.toString(), 18)
        );
        const redeemReceipt = await redeemTx.wait();
        
        const redeemEvent = redeemReceipt.events.find(e => e.event === "TokensRedeemed");
        const usdAmount = ethers.utils.formatUnits(redeemEvent.args.amount, 18);
        console.log(`Successfully redeemed ${redeemAmount} TPT for $${usdAmount}`);
        
        // 6. 查询最终余额
        const finalBalance = await contract.balanceOf(wallet.address);
        const formattedFinalBalance = ethers.utils.formatUnits(finalBalance, 18);
        console.log(`Final TPT balance: ${formattedFinalBalance}`);
        
    } catch (error) {
        console.error("Error:", error);
    }
}

main();
```

## 使用Cast命令行工具

如果您更喜欢使用命令行工具，可以使用Cast：

```bash
# 1. 请求TSLA价格
cast send <CONTRACT_ADDRESS> "requestTeslaPrice()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# 2. 获取当前TSLA价格
cast call <CONTRACT_ADDRESS> "getTeslaPrice()" --rpc-url $SEPOLIA_RPC_URL

# 3. 铸造TPT代币（铸造价值100美元的代币）
cast send <CONTRACT_ADDRESS> "mintTokens(uint256)" 100000000000000000000 --value 100000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# 4. 查询代币余额
cast call <CONTRACT_ADDRESS> "balanceOf(address)" <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL

# 5. 赎回TPT代币（赎回5个代币）
cast send <CONTRACT_ADDRESS> "redeemTokens(uint256)" 5000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

## 注意事项

1. **价格更新限制**：合约限制每小时只能更新一次价格
2. **最小铸造金额**：每次铸造至少需要10 USD
3. **最大供应量**：合约最大供应量为100万枚代币
4. **Sequencer检查**：如果Sequencer宕机，某些操作可能会失败
5. **Gas费用**：所有操作都需要支付Gas费用

## 错误处理

常见错误及解决方法：

1. **RateLimited**：价格更新过于频繁，请等待一小时后再试
2. **InvalidAmount**：铸造金额小于最小限制或赎回金额为0
3. **ExceedsMaxSupply**：铸造会导致总供应量超过最大限制
4. **SequencerDown**：Sequencer当前宕机，请稍后再试

## 高级用法

### 监听价格更新

```javascript
// 监听RequestFulfilled事件
contract.on("RequestFulfilled", (requestId, response, error) => {
    if (error) {
        console.error("Price request failed:", error);
    } else {
        console.log("Price request fulfilled:", response);
        // 解析响应中的价格数据
        const price = ethers.BigNumber.from(response);
        const priceInUSD = ethers.utils.formatUnits(price, 18);
        console.log(`New TSLA price: $${priceInUSD}`);
    }
});
```

### 批量操作

```javascript
// 批量铸造代币
async function batchMint(amounts) {
    for (let i = 0; i < amounts.length; i++) {
        try {
            const amountInWei = ethers.utils.parseUnits(amounts[i].toString(), 18);
            const tx = await contract.mintTokens(amountInWei, {
                value: amountInWei
            });
            await tx.wait();
            console.log(`Minted ${amounts[i]} USD worth of tokens`);
        } catch (error) {
            console.error(`Error minting ${amounts[i]} USD:`, error);
        }
    }
}

// 示例：批量铸造不同金额的代币
batchMint([50, 100, 150]);
```