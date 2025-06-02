// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
import "forge-std/Script.sol";
import "../src/DCA.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// @title RescueTokens
// @notice This script rescues tokens from the DCA contract.
// @dev It transfers a specified amount of tokens from the DCA contract to a specified address.
contract RescueTokens is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        address raw = vm.envAddress("DCA_ADDRESS");
        DollarCostAveraging dca = DollarCostAveraging(payable(raw));

        address token = vm.envAddress("TOKEN_TO_RESCUE");
        address to    = vm.envAddress("RESCUE_TO");
        uint256 amt   = vm.envUint("RESCUE_AMOUNT");
        dca.rescueTokens(token, to, amt);

        vm.stopBroadcast();
    }
}*/
