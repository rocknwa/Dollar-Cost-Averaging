// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DCA.sol";

/// @notice Script to Perform a Dollar-Cost Averaging (DCA) operation
/// @dev This script interacts with the DCA contract to perform a DCA operation
/// @dev It requires the private key of the deployer and the address of the DCA contract
contract PerformDCA is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        address raw = vm.envAddress("DCA_ADDRESS");
        DCA dca = DCA(payable(raw));

        // You must wait ≥ interval off-chain before running this
        dca.performDCA(1 wei, block.timestamp + 1 hours);

        vm.stopBroadcast();
    }
}
