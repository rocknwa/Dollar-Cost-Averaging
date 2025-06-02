// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DCA.sol";
import "openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";

/// @notice Helper contract that reverts on any ETH transfer.
/// Used to test failure cases for withdraw.
contract RevertingReceiver {
    receive() external payable {
        revert("fail");
    }
}

/// @notice Forge test suite for the DollarCostAveraging contract.
/// Covers deposit, DCA logic, withdraw, parameter updates, rescue functionality, and additional edge cases.
contract DCATest is Test {
    // --- Constants from DollarCostAveraging ---
    uint256 public constant DEFAULT_INVESTMENT_AMOUNT = 500 * 10 ** 6;
    uint256 public constant SECONDS_PER_DAY = 1 days;
    uint256 public constant DEFAULT_DCA_INTERVAL = 30 * SECONDS_PER_DAY;

    /// @notice Duplicate the event signatures so `emit` in tests compiles
    event ParametersUpdated(uint256 newInvestmentAmount, uint256 newInterval);
    event FundsDeposited(address indexed sender, uint256 amount);
    event DCAExecuted(uint256 indexed amountIn, uint256 amountOut, uint256 timestamp);
    event ETHWithdrawn(address indexed to, uint256 amount);

    DollarCostAveraging public dca;
    IERC20 public usdcContract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUniswapV2Router public uniswapV2RouterContract = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public owner = address(0xABCD);
    address public alice = address(0xDEAD);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(address(this), 10 ether);
        vm.prank(owner);
        dca = new DollarCostAveraging(address(usdcContract), address(uniswapV2RouterContract));
    }

    function testDepositFunds() public {
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT;
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);
        assertEq(usdcContract.balanceOf(address(dca)), amt);
    }

    function testNotOwnerPerformDCA() public {
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT;
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL + SECONDS_PER_DAY);
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        dca.performDCA(1, block.timestamp + 1 hours);
    }

    function testPerformDCA() public {
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8;
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT;
        vm.prank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL + SECONDS_PER_DAY);
        vm.prank(owner);
        uint256 preUSDC = usdcContract.balanceOf(address(dca));
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        assertLt(usdcContract.balanceOf(address(dca)), preUSDC);
        assertEq(dca.lastInvestment(), block.timestamp);
    }

    function testPerformDCAFailsBeforeInterval() public {
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8;
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT;
        vm.prank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL + SECONDS_PER_DAY);
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.TooEarlyForDCA.selector);
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
        vm.expectRevert(DollarCostAveraging.InsufficientETHBalance.selector);
        dca.withdraw(1 ether);
    }

    function testWithdraw_RevertsOnTxFail() public {
        RevertingReceiver receiver = new RevertingReceiver();
        payable(address(dca)).transfer(1 ether);
        // Overwrite owner slot
        bytes32 slot = bytes32(uint256(0));
        vm.store(address(dca), slot, bytes32(uint256(uint160(address(receiver)))));
        vm.prank(address(receiver));
        vm.expectRevert(DollarCostAveraging.ETHTransferFailed.selector);
        dca.withdraw(1 ether);
    }

    function testUpdateParameters() public {
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit ParametersUpdated(100 * 10 ** 6, 7 * SECONDS_PER_DAY);
        dca.updateParameters(100 * 10 ** 6, 7 * SECONDS_PER_DAY);
        assertEq(dca.investmentAmount(), 100 * 10 ** 6);
        assertEq(dca.dcaInterval(), 7 * SECONDS_PER_DAY);
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
        vm.expectRevert(DollarCostAveraging.InvalidAmount.selector);
        dca.depositFunds(0);
    }

    function testRescueToZeroReverts() public {
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InvalidAddress.selector);
        dca.rescueTokens(address(usdcContract), address(0), 1);
    }

    function testUpdateParamsFailZeroAmount() public {
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InvalidAmount.selector);
        dca.updateParameters(0, SECONDS_PER_DAY);
    }

    function testUpdateParamsFailShortInterval() public {
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InvalidInterval.selector);
        dca.updateParameters(DEFAULT_INVESTMENT_AMOUNT, 0);
    }

    // --- New Test Cases ---

    /// @notice Tests that constructor reverts with invalid USDC address
    function testConstructorInvalidUSDCAddress() public {
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InvalidAddress.selector);
        new DollarCostAveraging(address(0), address(uniswapV2RouterContract));
    }

    /// @notice Tests that constructor reverts with invalid router address
    function testConstructorInvalidRouterAddress() public {
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InvalidAddress.selector);
        new DollarCostAveraging(address(usdcContract), address(0));
    }

    /// @notice Tests DCA execution with insufficient USDC balance
    function testPerformDCAInsufficientUSDC() public {
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL + SECONDS_PER_DAY);
        vm.prank(owner);
        vm.expectRevert(DollarCostAveraging.InsufficientUSDCBalance.selector);
        dca.performDCA(1, block.timestamp + 1 hours);
    }

    /// @notice Tests multiple DCA executions over time
    function testMultipleDCAExecutions() public {
        address usdcWhale = 0x55FE002aefF02F77364de339a1292923A15844B8;
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT * 3; // Enough for 3 DCAs
        vm.prank(usdcWhale);
        usdcContract.transfer(owner, amt);
        vm.prank(owner);
        usdcContract.approve(address(dca), amt);
        vm.prank(owner);
        dca.depositFunds(amt);

        // First DCA
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL + SECONDS_PER_DAY);
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        assertEq(usdcContract.balanceOf(address(dca)), amt - DEFAULT_INVESTMENT_AMOUNT);

        // Second DCA
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL);
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        assertEq(usdcContract.balanceOf(address(dca)), amt - 2 * DEFAULT_INVESTMENT_AMOUNT);

        // Third DCA
        vm.warp(block.timestamp + DEFAULT_DCA_INTERVAL);
        vm.prank(owner);
        dca.performDCA(1, block.timestamp + 1 hours);
        assertEq(usdcContract.balanceOf(address(dca)), 0);
    }

    /// @notice Tests rescueTokens with zero amount
    function testRescueTokensZeroAmount() public {
        ERC20Mock token = new ERC20Mock("T", "T", address(this), 1000);
        token.transfer(address(dca), 500);
        vm.prank(owner);
        dca.rescueTokens(address(token), alice, 0); // Should not revert, transfers nothing
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(address(dca)), 500);
    }

    /// @notice Tests updateParameters with minimum allowed interval
    function testUpdateParametersMinimumInterval() public {
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit ParametersUpdated(100 * 10 ** 6, SECONDS_PER_DAY);
        dca.updateParameters(100 * 10 ** 6, SECONDS_PER_DAY);
        assertEq(dca.investmentAmount(), 100 * 10 ** 6);
        assertEq(dca.dcaInterval(), SECONDS_PER_DAY);
    }

    /// @notice Tests withdrawing the maximum ETH balance
    function testWithdrawMaxBalance() public {
        uint256 depositAmount = 5 ether;
        payable(address(dca)).transfer(depositAmount);
        vm.prank(owner);
        uint256 ownerBalanceBefore = owner.balance;
        dca.withdraw(depositAmount);
        assertEq(address(dca).balance, 0);
        assertEq(owner.balance, ownerBalanceBefore + depositAmount);
    }

    /// @notice Tests event emission for depositFunds
    function testDepositFundsEventEmission() public {
        uint256 amt = DEFAULT_INVESTMENT_AMOUNT;
        vm.prank(alice);
        usdcContract.approve(address(dca), amt);
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit FundsDeposited(alice, amt);
        dca.depositFunds(amt);
    }

    receive() external payable {}
}
