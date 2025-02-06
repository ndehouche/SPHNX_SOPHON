import { Provider, Wallet, utils } from "zksync-ethers";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { HardhatRuntimeEnvironment } from "hardhat/types";

export default async function (hre: HardhatRuntimeEnvironment) {
  const provider = new Provider(hre.network.config.url);
  const wallet = new Wallet(process.env.WALLET_PRIVATE_KEY!, provider);
  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("SPHNX");
  const constructorArguments = ["2500000"];

  const params = utils.getPaymasterParams(
    "0x98546B226dbbA8230cf620635a1e4ab01F6A99B2", // Paymaster address
    {
      type: "General",
      innerInput: new Uint8Array(),
    }
  );

  const contract = await deployer.deploy(
    artifact,
    constructorArguments, // Constructor arguments
    undefined, // Deployment type (use undefined for regular contract deployment)
    {
      customData: {
        paymasterParams: params,
        gasPerPubdata: utils.DEFAULT_GAS_PER_PUBDATA_LIMIT,
      },
    }
  );

  console.log(`Contract deployed to ${contract.address}`);
}
