// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DCA.sol";

contract UpdateParams is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        address raw = vm.envAddress("DCA_ADDRESS");
        DCA dca = DCA(payable(raw));
        dca.updateParameters(100 * 10 ** 6, 7 days);

        vm.stopBroadcast();
    }
}
