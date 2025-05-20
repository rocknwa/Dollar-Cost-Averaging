// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DCA.sol";
import "openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";

/// @notice Helper contract that reverts on any ETH transfer.
/// Used to test failure cases for withdraw.
contract RevertingReceiver {
    fallback() external payable {
        revert("fail");
    }

    receive() external payable {
        revert("fail");
    }
}

/// @notice Forge test suite for the DCA contract.
/// Covers deposit, DCA logic, withdraw, parameter updates, and rescue functionality.
contract DCATest is Test {
    uint256 public amountOfInvestment = 500 * 10 ** 6;
    /// @notice duplicate the event signature so `emit` in test compiles

    event ParametersUpdated(uint256 newAmountOfInvestment, uint256 newInterval);

    DCA public dca;
    IERC20 public usdcContract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUniswapV2Router public uniswapV2RouterContract = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public owner = address(0xABCD);
    address public alice = address(0xDEAD);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(address(this), 10 ether);
        vm.prank(owner);
        dca = new DCA(address(usdcContract), address(uniswapV2RouterContract));
    }

    function testDepositFunds() public {
        uint256 amt = amountOfInvestment;
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);
        assertEq(usdcContract.balanceOf(address(dca)), amt);
    }

    function testNotOwnerPerformDCA() public {
        uint256 amt = amountOfInvestment;
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + 31 days);
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        dca.performDCA(1, block.timestamp + 1 hours);
    }

    function testPerformDCA() public {
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8;
        uint256 amt = amountOfInvestment;
        vm.prank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + 31 days);
        vm.prank(owner);
        uint256 preUSDC = usdcContract.balanceOf(address(dca));
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        assertLt(usdcContract.balanceOf(address(dca)), preUSDC);
        assertEq(dca.lastInvestment(), block.timestamp);
    }

    function testPerformDCAFailsBeforeInterval() public {
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8;
        uint256 amt = amountOfInvestment;
        vm.prank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + 31 days);
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        vm.prank(owner);
        vm.expectRevert("Too early");
        dca.performDCA(1, block.timestamp + 1);
    }

    function testWithdraw() public {
        payable(address(dca)).transfer(1 ether);
        vm.prank(owner);
        dca.withdraw(1 ether);
        assertEq(address(dca).balance, 0);
    }

    function testWithdrawNotOwner() public {
        payable(address(dca)).transfer(1 ether);
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        dca.withdraw(1 ether);
    }

    function testWithdrawInsufficientBalance() public {
        vm.prank(owner);
        vm.expectRevert("Insufficient ETH");
        dca.withdraw(1 ether);
    }

    function testWithdraw_RevertsOnTxFail() public {
        RevertingReceiver receiver = new RevertingReceiver();
        payable(address(dca)).transfer(1 ether);
        // overwrite owner slot
        bytes32 slot = bytes32(uint256(0));
        vm.store(address(dca), slot, bytes32(uint256(uint160(address(receiver)))));
        vm.prank(address(receiver));
        vm.expectRevert("Transfer failed");
        dca.withdraw(1 ether);
    }

    function testUpdateParameters() public {
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit ParametersUpdated(100 * 10 ** 6, 7 days); // step 2: emit signature:contentReference[oaicite:1]{index=1}
        dca.updateParameters(100 * 10 ** 6, 7 days); // step 3: actual call
        assertEq(dca.amountOfInvestment(), 100 * 10 ** 6);
        assertEq(dca.interval(), 7 days);
    }

    function testRescueTokens() public {
        // Deploy a dummy token
        ERC20Mock token = new ERC20Mock("T", "T", address(this), 1000);
        // Transfer tokens to DCA
        token.transfer(address(dca), 500);
        assertEq(token.balanceOf(address(dca)), 500);
        vm.prank(owner);
        dca.rescueTokens(address(token), alice, 500);
        assertEq(token.balanceOf(alice), 500);
        assertEq(token.balanceOf(address(dca)), 0);
    }

    function testDepositZeroReverts() public {
        vm.prank(alice);
        vm.expectRevert("Amount > 0");
        dca.depositFunds(0);
    }

    function testRescueToZeroReverts() public {
        // mint or transfer some dummy token in setup
        vm.prank(owner);
        vm.expectRevert("Invalid recipient");
        dca.rescueTokens(address(usdcContract), address(0), 1);
    }

function testUpdateParamsFailZeroAmount() public {
    vm.prank(owner);
    vm.expectRevert("Amount > 0");
    dca.updateParameters(0, 1 days);
}

function testUpdateParamsFailShortInterval() public {
    vm.prank(owner);
    vm.expectRevert("Interval >= 1 day");
    dca.updateParameters(amountOfInvestment, 0);
}
    receive() external payable {}
}
