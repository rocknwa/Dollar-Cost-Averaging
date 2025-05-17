// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DCA.sol";

/// @notice Helper contract that reverts on any ETH transfer.
/// Used to test failure cases for withdraw.
contract RevertingReceiver {
    // Fallback function reverts on any call with data.
    fallback() external payable {
        revert("fail");
    }

    // Receive function reverts on plain ETH transfer.
    receive() external payable {
        revert("fail");
    }
}

/// @notice Forge test suite for the DCA contract.
/// Covers deposit, DCA logic, withdraw, and all revert paths.
contract DCATest is Test {
    // Amount to use for DCA investment (USDC 6 decimals)
    uint256 public amountOfInvestment = 500 * 10 ** 6;

    DCA public dca;
    // Mainnet USDC and UniswapV2 addresses (useful for mainnet-fork tests)
    IERC20 public usdcContract =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUniswapV2Router public uniswapV2RouterContract =
        IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public owner = address(0xABCD);
    address public alice = address(0xDEAD);

    /// @notice Setup runs before each test.
    /// Funds accounts and deploys the DCA contract.
    function setUp() public {
        // Fund owner and this contract with Ether
        vm.deal(owner, 10 ether);
        vm.deal(address(this), 10 ether);

        // Deploy DCA contract as owner
        vm.prank(owner);
        dca = new DCA();
    }

    /// @notice Test that depositFunds works and updates DCA USDC balance.
    function testDepositFunds() public {
        uint256 amt = 500 * 10 ** 6;
        // Alice approves and deposits USDC to DCA contract
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);
        assertEq(usdcContract.balanceOf(address(dca)), amt);
    }
    
    /// @notice Test that performDCA fails if not called by the owner.
    function testNotOwnerPerformDCA() public {
        uint256 amt = 500 * 10 ** 6;

        // Alice approves and deposits USDC (allowed for anyone)
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);

        // Fast-forward 31 days
        vm.warp(block.timestamp + 31 days);

        // Alice tries to perform DCA, should revert with "you are not the owner"
        vm.prank(alice);
        vm.expectRevert("you are not the owner");
        // This line will revert.
        dca.performDCA(1, block.timestamp + 1 hours);
    }

    /// @notice Test DCA performs a swap after 30 days and updates lastInvestment and balances.
    /// @notice Test owner can perform DCA (should succeed)
    function testPerformDCA() public {
        // Fund owner with USDC from a whale account (for mainnet-fork tests)
        // Replace with a real whale address and amount for mainnet testing
        // Example: 0x55FE002aefF02F77364de339a1292923A15844B8
        // Example: 500 * 10**6 (500 USDC)
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8; // Example USDC rich account
        uint256 amt = 500 * 10 ** 6;

        // Impersonate whale to fund owner
        vm.startPrank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.stopPrank();

        // Owner approves and deposits USDC
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);

        // Fast-forward 31 days
        vm.warp(block.timestamp + 31 days);

        // Owner performs DCA, should succeed
        vm.prank(owner);
        // Perform DCA swap
        uint256 minEth = 1;
        uint256 deadline = block.timestamp + 1 hours;
        dca.performDCA(minEth, deadline);
        // Assert state
        assertLt(
            usdcContract.balanceOf(address(dca)),
            amt,
            "Swap did not occur"
        );
        assertEq(dca.lastInvestment(), block.timestamp);
    }

    /// @notice Test DCA cannot be performed before 30 days have elapsed.
    function testPerformDCAFailsBefore30Days() public {
        vm.prank(owner);
        vm.expectRevert("try again");
        dca.performDCA(1, block.timestamp + 1);
    }

    /// @notice Test owner can withdraw ETH and contract balance is updated.
    function testWithdraw() public {
        // Deposit 1 ETH to DCA contract
        payable(address(dca)).transfer(1 ether);

        // Owner withdraws
        vm.prank(owner);
        dca.withdraw(1 ether);

        // Contract balance should now be 0
        assertEq(address(dca).balance, 0);
    }

    /// @notice Test withdraw fails if called by non-owner.
    function testWithdrawNotOwner() public {
        // Deposit 1 ETH to DCA contract
        payable(address(dca)).transfer(1 ether);
        // Alice tries to withdraw, should revert
        vm.prank(alice);
        vm.expectRevert("you are not the owner");
        dca.withdraw(1 ether);
    }

    /// @notice Test withdraw fails if contract does not have enough ETH balance.
    function testWithdrawInsufficientBalance() public {
        // Owner tries to withdraw more than contract balance, should revert
        vm.prank(owner);
        vm.expectRevert("not enough balance");
        dca.withdraw(1 ether);
    }

    /// @notice Test withdraw fails with "tx failed" if ETH transfer to owner fails.
    function testWithdraw_RevertsWithTxFailed() public {
        // Deploy a contract that will revert on receiving ETH
        RevertingReceiver revertingOwner = new RevertingReceiver();

        // Fund DCA contract with ETH
        payable(address(dca)).transfer(1 ether);

        // Forcibly set DCA.owner to the reverting contract (first storage slot)
        bytes32 slot = bytes32(uint256(0));
        vm.store(
            address(dca),
            slot,
            bytes32(uint256(uint160(address(revertingOwner))))
        );

        // Prank as the new owner and try to withdraw -- should fail with "tx failed"
        vm.prank(address(revertingOwner));
        vm.expectRevert(bytes("tx failed"));
        dca.withdraw(1 ether);
    }

    /// @notice Allow test contract to receive ETH.
    receive() external payable {}
}
