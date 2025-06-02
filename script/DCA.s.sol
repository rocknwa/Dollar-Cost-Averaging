// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
import "forge-std/Script.sol";
import "../src/DCA.sol";

/// forge script script/DCA.s.sol --rpc-url $RPC_URL --broadcast
/// @notice Deployment script for the DCA contract using Foundry Script
contract DeployDCA is Script {
  IERC20 public usdcContract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUniswapV2Router public uniswapV2RouterContract = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function run() external {
        // Fetch the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions with the deployer's key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the DCA contract
        DollarCostAveraging dca = new DollarCostAveraging(address(usdcContract), address(uniswapV2RouterContract));

        // Log the deployed address for verification
        console.log("DCA deployed at:", address(dca));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
*/
