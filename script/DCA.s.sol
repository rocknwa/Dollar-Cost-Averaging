 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "forge-std/Script.sol";
import "../src/DCA.sol";

/// @notice Deployment script for the DCA contract using Foundry Script 
contract DeployDCA is Script {
    function run() external {
        // Fetch the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions with the deployer's key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the DCA contract
        DCA dca = new DCA();

        // Log the deployed address for verification
        console.log("DCA deployed at:", address(dca));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}