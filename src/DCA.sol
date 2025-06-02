// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

interface IUniswapV2Router {
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external view returns (address);
}

/**
 * @title DollarCostAveraging
 * @author Therock Ani
 * @notice This contract enables periodic dollar-cost averaging (DCA) from USDC to ETH via Uniswap V2.
 * @dev Inherits from OpenZeppelin's Ownable and ReentrancyGuard for access control and security.
 */
contract DollarCostAveraging is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // --- Constants ---
    /// @notice Number of seconds in one day
    uint256 private constant SECONDS_PER_DAY = 1 days;
    /// @notice Default interval for DCA (30 days in seconds)
    uint256 private constant DEFAULT_DCA_INTERVAL = 30 * SECONDS_PER_DAY;
    /// @notice Default USDC amount per DCA investment (500 USDC with 6 decimals)
    uint256 private constant DEFAULT_INVESTMENT_AMOUNT = 500 * 10 ** 6;
    /// @notice Number of tokens in the Uniswap swap path (USDC -> WETH)
    uint256 private constant SWAP_PATH_LENGTH = 2;

    // --- Custom Errors ---
    /// @notice Thrown when an invalid address (zero address) is provided
    error InvalidAddress();
    /// @notice Thrown when an amount is zero or negative
    error InvalidAmount();
    /// @notice Thrown when the interval is less than one day
    error InvalidInterval();
    /// @notice Thrown when the contract has insufficient ETH balance
    error InsufficientETHBalance();
    /// @notice Thrown when the contract has insufficient USDC balance
    error InsufficientUSDCBalance();
    /// @notice Thrown when the DCA is executed too early
    error TooEarlyForDCA();
    /// @notice Thrown when an ETH transfer fails
    error ETHTransferFailed();

    // --- State Variables ---
    /// @notice Timestamp of the last DCA execution
    uint256 public lastInvestment;
    /// @notice Amount of USDC to invest per DCA (in USDC smallest unit)
    uint256 public investmentAmount = DEFAULT_INVESTMENT_AMOUNT;
    /// @notice Interval between DCA executions in seconds
    uint256 public dcaInterval = DEFAULT_DCA_INTERVAL;
    /// @notice USDC token contract
    IERC20 public immutable usdc;
    /// @notice Uniswap V2 router contract
    IUniswapV2Router public immutable router;

    // --- Events ---
    /// @notice Emitted when USDC is deposited
    event FundsDeposited(address indexed sender, uint256 amount);
    /// @notice Emitted when a DCA swap is executed
    event DCAExecuted(uint256 indexed amountIn, uint256 amountOut, uint256 timestamp);
    /// @notice Emitted when ETH is withdrawn
    event ETHWithdrawn(address indexed to, uint256 amount);
    /// @notice Emitted when DCA parameters are updated
    event ParametersUpdated(uint256 newInvestmentAmount, uint256 newInterval);

    // --- Constructor ---
    /**
     * @notice Initializes the contract with USDC and Uniswap V2 router addresses
     * @param _usdc Address of the USDC token contract
     * @param _router Address of the Uniswap V2 router contract
     */
    constructor(address _usdc, address _router) {
        if (_usdc == address(0) || _router == address(0)) {
            revert InvalidAddress();
        }
        usdc = IERC20(_usdc);
        router = IUniswapV2Router(_router);
        lastInvestment = block.timestamp;
    }

    // --- Receive ETH ---
    receive() external payable {}
    fallback() external payable {}

    // --- Owner Functions ---
    /**
     * @notice Allows the owner to withdraw ETH profits
     * @param amount Amount of ETH (in wei) to withdraw
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (address(this).balance < amount) {
            revert InsufficientETHBalance();
        }

        (bool success, ) = owner().call{value: amount}("");
        if (!success) {
            revert ETHTransferFailed();
        }

        emit ETHWithdrawn(owner(), amount);
    }

    /**
     * @notice Updates the DCA parameters
     * @param _investmentAmount New USDC amount per DCA
     * @param _interval New interval in seconds between DCAs
     */
    function updateParameters(uint256 _investmentAmount, uint256 _interval) external onlyOwner {
        if (_investmentAmount == 0) {
            revert InvalidAmount();
        }
        if (_interval < SECONDS_PER_DAY) {
            revert InvalidInterval();
        }

        investmentAmount = _investmentAmount;
        dcaInterval = _interval;
        emit ParametersUpdated(_investmentAmount, _interval);
    }

    // --- Public Functions ---
    /**
     * @notice Deposits USDC to fund future DCAs
     * @param _amount Amount of USDC (in smallest unit) to deposit
     */
    function depositFunds(uint256 _amount) external nonReentrant {
        if (_amount == 0) {
            revert InvalidAmount();
        }
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        emit FundsDeposited(msg.sender, _amount);
    }

    /**
     * @notice Executes a DCA swap of USDC for ETH via Uniswap V2
     * @param etherMin Minimum ETH to receive from the swap
     * @param deadline Unix timestamp after which the swap will revert
     */
    function performDCA(uint256 etherMin, uint256 deadline) external onlyOwner nonReentrant {
        if (block.timestamp < lastInvestment + dcaInterval) {
            revert TooEarlyForDCA();
        }
        if (usdc.balanceOf(address(this)) < investmentAmount) {
            revert InsufficientUSDCBalance();
        }

        // Approve and execute swap
        usdc.safeApprove(address(router), investmentAmount);
        address[] memory path = new address[](SWAP_PATH_LENGTH);
        path[0] = address(usdc);
        path[1] = router.WETH();

        uint256 preBalance = address(this).balance;
        router.swapExactTokensForETH(investmentAmount, etherMin, path, address(this), deadline);
        uint256 received = address(this).balance - preBalance;

        lastInvestment = block.timestamp;
        emit DCAExecuted(investmentAmount, received, block.timestamp);
    }

    // --- Emergency Functions ---
    /**
     * @notice Rescues ERC20 tokens mistakenly sent to this contract
     * @param token Address of the token to rescue
     * @param to Recipient address
     * @param amount Amount of tokens to rescue
     */
    function rescueTokens(address token, address to, uint256 amount) external onlyOwner nonReentrant {
        if (to == address(0)) {
            revert InvalidAddress();
        }
        IERC20(token).safeTransfer(to, amount);
    }
}