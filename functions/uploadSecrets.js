const { SecretsManager } = require("@chainlink/functions-toolkit");

async function uploadSecrets() {
  // Configuration for Sepolia testnet
  const routerAddress = process.env.FUNCTIONS_ROUTER || "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0";
  const donId = process.env.DON_ID || "fun-ethereum-sepolia-1";
  const gatewayUrls = ["https://00.functions-gateway.testnet.chain.link/"];
  
  // Initialize secrets manager
  const secretsManager = new SecretsManager({
    routerAddress: routerAddress,
    donId: donId,
    gatewayUrls: gatewayUrls,
  });
  
  // Set authentication
  const privateKey = process.env.PRIVATE_KEY;
  const rpcUrl = process.env.SEPOLIA_RPC_URL;
  await secretsManager.initialize(privateKey, rpcUrl);
  
  // Define secrets
  const secrets = {
    alpacaKey: process.env.ALPACA_API_KEY_ID,
    alpacaSecret: process.env.ALPACA_API_SECRET_KEY,
  };
  
  // Encrypt secrets
  const encryptedSecretsObj = await secretsManager.encryptSecrets(secrets);
  
  // Upload secrets
  const slotId = process.env.DON_HOSTED_SECRETS_SLOT_ID || 0; // Slot ID for the secrets
  const expirationTimeMinutes = 1440; // 24 hours
  const uploadResult = await secretsManager.uploadEncryptedSecretsToDON({
    encryptedSecretsHexstring: encryptedSecretsObj.encryptedSecrets,
    gatewayUrls: gatewayUrls,
    slotId: slotId,
    expirationTimeMinutes: expirationTimeMinutes,
  });
  
  if (uploadResult.success) {
    console.log(`Secrets uploaded successfully to slot ${slotId}`);
    console.log(`Version: ${uploadResult.version}`);
    console.log(`Expiration: ${new Date(uploadResult.expiration * 1000).toISOString()}`);
    console.log(`Update your .env file with: DON_HOSTED_SECRETS_VERSION=${uploadResult.version}`);
  } else {
    console.error("Failed to upload secrets:", uploadResult.errorMessage);
  }
}

uploadSecrets().catch((error) => {
  console.error("Error uploading secrets:", error);
  process.exit(1);
});