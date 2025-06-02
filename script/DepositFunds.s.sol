// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DCA.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
/*
// @title DepositFunds
// @notice This script deposits funds into the DCA contract.
contract DepositFunds is Script {
     function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY__WHALE"); // Load private key from env
        vm.startBroadcast(key); // Start broadcasting with the private key
        
        uint256 amountOfInvestment = 500 * 10 ** 6;
        address usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address raw = vm.envAddress("DCA_ADDRESS");
        DollarCostAveraging dca = DollarCostAveraging(payable(raw));

        IERC20(usdcAddr).approve(address(dca), amountOfInvestment);
        dca.depositFunds(amountOfInvestment);

        vm.stopBroadcast();
    }
}
*/
