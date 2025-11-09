# Tesla Price Token (TPT) 常见问题解答

## 目录

1. [基础问题](#基础问题)
2. [安装与设置](#安装与设置)
3. [部署相关](#部署相关)
4. [使用与交互](#使用与交互)
5. [安全与风险](#安全与风险)
6. [技术问题](#技术问题)
7. [故障排除](#故障排除)

---

## 基础问题

### Q1: 什么是Tesla Price Token (TPT)？

**A:** Tesla Price Token (TPT) 是一个超额抵押的稳定币项目，使用ETH作为抵押品，通过Chainlink价格预言机获取TSLA和ETH的实时价格。用户可以存入ETH作为抵押品，铸造与TSLA价格挂钩的TPT代币，也可以随时赎回TPT代币换取抵押品。

### Q2: TPT与直接购买TSLA股票有什么区别？

**A:** TPT提供了以下优势：
- **去中心化**: 无需传统金融中介
- **全天候交易**: 不受股市开盘时间限制
- **低门槛**: 无需最低投资金额
- **全球访问**: 任何人都可以参与
- **程序化交易**: 可以与其他DeFi协议组合使用

### Q3: TPT的价值如何确定？

**A:** TPT的价值与特斯拉(TSLA)股票价格1:1挂钩。价格通过Chainlink去中心化预言机网络获取，确保价格数据的可靠性和抗操纵性。

### Q4: 为什么需要超额抵押？

**A:** 超额抵押机制（200%抵押率）是为了：
- **抵御价格波动**: 当ETH价格下跌时，仍有足够抵押品覆盖TPT价值
- **保护系统稳定**: 防止因抵押品不足导致的系统性风险
- **增强用户信心**: 确保TPT始终有足够价值支撑

---

## 安装与设置

### Q5: 安装项目时遇到"Foundry not found"错误怎么办？

**A:** 请按照以下步骤安装Foundry：

1. **Windows系统**:
   ```bash
   # 使用PowerShell
   irm https://foundry.paradigm.xyz | iex
   foundryup
   ```

2. **macOS/Linux系统**:
   ```bash
   # 使用curl
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **验证安装**:
   ```bash
   forge --version
   cast --version
   ```

如果仍然遇到问题，请尝试重启终端或手动添加Foundry到系统PATH。

### Q6: Node.js版本兼容性问题如何解决？

**A:** 项目要求Node.js v16或更高版本：

1. **检查当前版本**:
   ```bash
   node --version
   ```

2. **升级Node.js**:
   - **使用nvm** (推荐):
     ```bash
     nvm install 18
     nvm use 18
     ```
   - **从官网下载**: [Node.js官网](https://nodejs.org/)

3. **更新npm**:
   ```bash
   npm install -g npm@latest
   ```

### Q7: 依赖安装失败怎么办？

**A:** 如果遇到依赖安装问题，请尝试：

1. **清除npm缓存**:
   ```bash
   npm cache clean --force
   ```

2. **删除node_modules和package-lock.json**:
   ```bash
   rm -rf node_modules package-lock.json
   ```

3. **重新安装**:
   ```bash
   npm install
   ```

4. **如果仍有问题，尝试使用yarn**:
   ```bash
   yarn install
   ```

---

## 部署相关

### Q8: 如何获取测试网ETH？

**A:** 获取测试网ETH的方法：

1. **Sepolia测试网**:
   - 访问 [Sepolia Faucet](https://sepoliafaucet.com/)
   - 使用 [Alchemy Faucet](https://sepoliafaucet.com/)
   - 使用 [Chainlink Faucet](https://faucets.chain.link/)

2. **Goerli测试网**:
   - 访问 [Goerli Faucet](https://goerlifaucet.com/)
   - 使用 [Alchemy Goerli Faucet](https://goerlifaucet.alchemy.com/)

3. **其他方法**:
   - 在社交媒体上请求测试网ETH
   - 参与测试网社区活动

### Q9: 部署合约时Gas费用不足怎么办？

**A:** 解决Gas费用不足的方法：

1. **增加Gas限制**:
   ```bash
   forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast --gas-limit 3000000
   ```

2. **调整Gas价格**:
   ```bash
   forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast --gas-price 20 gwei
   ```

3. **使用Gas估算器**:
   ```bash
   forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --dry-run
   ```

### Q10: 合约部署失败如何排查？

**A:** 合约部署失败的排查步骤：

1. **检查环境变量**:
   ```bash
   cat .env
   ```

2. **验证网络连接**:
   ```bash
   cast block-number --rpc-url <RPC_URL>
   ```

3. **检查账户余额**:
   ```bash
   cast balance <ADDRESS> --rpc-url <RPC_URL>
   ```

4. **查看详细错误信息**:
   ```bash
   forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast --verbose
   ```

5. **常见错误及解决方案**:
   - **"nonce too low"**: 等待待处理交易确认或增加nonce
   - **"insufficient funds"**: 确保账户有足够ETH支付Gas
   - **"revert"**: 检查合约构造函数参数是否正确

---

## 使用与交互

### Q11: 如何存入ETH并铸造TPT？

**A:** 存入ETH并铸造TPT的步骤：

1. **使用ethers.js**:
   ```javascript
   const depositAmount = ethers.utils.parseEther("1.0"); // 1 ETH
   
   const tx = await teslaPriceToken.depositAndMint(depositAmount, {
     value: depositAmount
   });
   
   await tx.wait();
   ```

2. **使用Cast命令行**:
   ```bash
   cast send <CONTRACT_ADDRESS> "depositAndMint(uint256)" "1000000000000000000" \
     --value 1ether --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
   ```

3. **注意事项**:
   - 确保有足够ETH支付Gas费用
   - 存入的ETH将作为抵押品锁定
   - 铸造的TPT数量基于当前TSLA价格计算

### Q12: 如何检查我的健康因子？

**A:** 检查健康因子的方法：

1. **使用ethers.js**:
   ```javascript
   const healthFactor = await teslaPriceToken.getHealthFactor(userAddress);
   console.log("健康因子:", healthFactor.toString());
   ```

2. **使用Cast命令行**:
   ```bash
   cast call <CONTRACT_ADDRESS> "getHealthFactor(address)" <USER_ADDRESS> \
     --rpc-url <RPC_URL>
   ```

3. **健康因子解读**:
   - **> 2**: 安全状态
   - **1.5 - 2**: 警告状态
   - **< 1.5**: 危险状态，建议追加抵押品或赎回部分TPT

### Q13: 如何赎回TPT并取回ETH？

**A:** 赎回TPT并取回ETH的步骤：

1. **使用ethers.js**:
   ```javascript
   const redeemAmount = ethers.utils.parseUnits("100", 18); // 100 TPT
   
   const tx = await teslaPriceToken.redeemAndBurn(redeemAmount);
   await tx.wait();
   ```

2. **使用Cast命令行**:
   ```bash
   cast send <CONTRACT_ADDRESS> "redeemAndBurn(uint256)" "100000000000000000000" \
     --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
   ```

3. **注意事项**:
   - 赎回后健康因子必须保持在1.5以上
   - 赎回的ETH数量基于当前TSLA价格计算
   - 确保有足够TPT余额进行赎回

### Q14: 价格多久更新一次？

**A:** 价格更新机制：

1. **自动更新**:
   - 价格数据每小时自动检查
   - 如果价格超过3小时未更新，合约将暂停操作

2. **手动更新**:
   ```javascript
   const tx = await teslaPriceToken.updatePrices();
   await tx.wait();
   ```

3. **价格过期处理**:
   - 价格过期时，所有铸造和赎回操作将被暂停
   - 只有价格更新后才能恢复操作

---

## 安全与风险

### Q15: 我的资金安全吗？

**A:** TPT项目实施了多层安全措施：

1. **智能合约安全**:
   - 经过全面测试和审计
   - 实施了访问控制机制
   - 包含紧急暂停功能

2. **超额抵押机制**:
   - 200%抵押率要求
   - 实时健康因子监控
   - 自动清算保护

3. **预言机安全**:
   - 使用Chainlink去中心化预言机
   - 多个独立数据源
   - 价格异常检测

4. **用户责任**:
   - 保护好私钥
   - 定期监控健康因子
   - 了解市场风险

### Q16: 如果ETH价格大幅下跌会发生什么？

**A:** ETH价格下跌的处理机制：

1. **健康因子下降**:
   - 当ETH价格下跌，健康因子会降低
   - 用户会收到风险警告

2. **清算保护**:
   - 健康因子低于1.5时，无法进行赎回操作
   - 用户需要追加抵押品或赎回TPT

3. **极端情况**:
   - 在极端市场条件下，系统可能暂停操作
   - 管理员可以采取紧急措施保护用户资金

### Q17: 合约是否可以升级？

**A:** 合约升级策略：

1. **不可变核心逻辑**:
   - 核心合约逻辑不可更改
   - 确保规则的一致性和可预测性

2. **可升级组件**:
   - 部分辅助合约可能支持升级
   - 通过治理机制决定升级

3. **迁移计划**:
   - 如需重大升级，将制定平滑迁移计划
   - 确保用户资产安全转移

---

## 技术问题

### Q18: 交易失败并显示"gas required exceeds allowance"怎么办？

**A:** 解决Gas不足问题：

1. **增加Gas限制**:
   ```javascript
   const tx = await contract.method({
     gasLimit: 500000
   });
   ```

2. **调整Gas价格**:
   ```javascript
   const tx = await contract.method({
     gasPrice: ethers.utils.parseUnits("20", "gwei")
   });
   ```

3. **使用EIP-1559**:
   ```javascript
   const tx = await contract.method({
     maxFeePerGas: ethers.utils.parseUnits("30", "gwei"),
     maxPriorityFeePerGas: ethers.utils.parseUnits("2", "gwei")
   });
   ```

### Q19: 如何获取合约事件？

**A:** 获取合约事件的方法：

1. **使用ethers.js**:
   ```javascript
   // 监听新事件
   contract.on("Deposit", (user, amount, event) => {
     console.log(`用户 ${user} 存入 ${ethers.utils.formatEther(amount)} ETH`);
   });
   
   // 查询历史事件
   const filter = contract.filters.Deposit(userAddress);
   const events = await contract.queryFilter(filter, fromBlock, toBlock);
   ```

2. **使用Cast命令行**:
   ```bash
   cast logs --from-block <START_BLOCK> --address <CONTRACT_ADDRESS> \
     "Deposit(address,uint256)" --rpc-url <RPC_URL>
   ```

### Q20: 如何与合约进行批量交互？

**A:** 批量交互的方法：

1. **使用Multicall**:
   ```javascript
   const multicall = await ethers.getContractAt("IMulticall", MULTICALL_ADDRESS);
   
   const calls = [
     [teslaPriceTokenAddress, teslaPriceToken.interface.encodeFunctionData("balanceOf", [userAddress])],
     [teslaPriceTokenAddress, teslaPriceToken.interface.encodeFunctionData("getHealthFactor", [userAddress])]
   ];
   
   const results = await multicall.aggregate(calls);
   ```

2. **使用Promise.all**:
   ```javascript
   const [balance, healthFactor] = await Promise.all([
     teslaPriceToken.balanceOf(userAddress),
     teslaPriceToken.getHealthFactor(userAddress)
   ]);
   ```

---

## 故障排除

### Q21: 交易一直处于pending状态怎么办？

**A:** 解决pending交易问题：

1. **检查交易状态**:
   ```bash
   cast tx <TRANSACTION_HASH> --rpc-url <RPC_URL>
   ```

2. **替换交易**:
   ```javascript
   const tx = await signer.sendTransaction({
     to: contract.address,
     data: contract.interface.encodeFunctionData("methodName", [params]),
     gasLimit: 300000,
     gasPrice: ethers.utils.parseUnits("25", "gwei"),
     nonce: await signer.getTransactionCount()
   });
   ```

3. **取消交易**:
   ```javascript
   const tx = await signer.sendTransaction({
     to: signer.address,
     value: 0,
     gasPrice: ethers.utils.parseUnits("25", "gwei"),
     nonce: await signer.getTransactionCount()
   });
   ```

### Q22: 如何重置本地开发环境？

**A:** 重置开发环境的步骤：

1. **清理编译缓存**:
   ```bash
   forge clean
   ```

2. **重新安装依赖**:
   ```bash
   rm -rf lib
   forge install
   ```

3. **重新编译**:
   ```bash
   forge build
   ```

4. **重置测试链**:
   ```bash
   anvil --reset
   ```

### Q23: 如何获取更多帮助？

**A:** 获取帮助的渠道：

1. **文档资源**:
   - [项目README](./README.md)
   - [安装指南](./INSTALLATION_GUIDE.md)
   - [部署指南](./DEPLOYMENT_GUIDE.md)
   - [使用示例](./USAGE_EXAMPLES.md)

2. **社区支持**:
   - [GitHub Issues](https://github.com/your-repo/issues)
   - [Discord社区](https://discord.gg/your-invite)
   - [Telegram群组](https://t.me/your-channel)

3. **技术支持**:
   - 邮件: support@teslapricetoken.com
   - 技术文档: docs.teslapricetoken.com

---

## 其他常见问题

### Q24: 项目是否有代币？

**A:** TPT项目本身没有治理代币或投资代币。TPT是与TSLA价格挂钩的稳定币，完全由ETH抵押品支持。

### Q25: 如何参与项目贡献？

**A:** 参与项目贡献的方式：

1. **代码贡献**:
   - Fork项目仓库
   - 创建功能分支
   - 提交Pull Request

2. **文档改进**:
   - 完善现有文档
   - 翻译文档
   - 添加使用示例

3. **测试反馈**:
   - 报告Bug
   - 提出改进建议
   - 参与测试网测试

4. **社区建设**:
   - 帮助新用户
   - 分享使用经验
   - 推广项目

### Q26: 项目未来有什么计划？

**A:** 项目未来计划：

1. **短期目标**:
   - 完成安全审计
   - 主网部署
   - 前端界面开发

2. **中期目标**:
   - 添加更多抵押资产
   - 实施治理机制
   - 集成更多DeFi协议

3. **长期目标**:
   - 跨链部署
   - 机构合作
   - 生态系统扩展

---

## 联系我们

如果您有任何其他问题，请通过以下方式联系我们：

- **技术问题**: [GitHub Issues](https://github.com/your-repo/issues)
- **社区讨论**: [Discord](https://discord.gg/your-invite)
- **商业合作**: [business@teslapricetoken.com](mailto:business@teslapricetoken.com)
- **安全问题**: [security@teslapricetoken.com](mailto:security@teslapricetoken.com)

---

**最后更新**: 2025年4月

**注意**: 本文档会随着项目发展持续更新。如需了解最新信息，请查看项目的官方文档或联系项目团队。