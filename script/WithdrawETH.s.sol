// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
import "forge-std/Script.sol";
import "../src/DCA.sol";

contract WithdrawETH is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        address raw = vm.envAddress("DCA_ADDRESS");
        DollarCostAveraging dca = DollarCostAveraging(payable(raw));
        payable(address(dca)).transfer(1 ether);
        uint256 bal = address(dca).balance;
        if (bal > 0) {
            dca.withdraw(bal);
        }

        vm.stopBroadcast();
    }
}
*/