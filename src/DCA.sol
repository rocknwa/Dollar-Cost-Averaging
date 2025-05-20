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
 * @title DCA
 * @author Therock Ani
 * @notice This contract allows periodic dollar-cost averaging (DCA) from USDC into ETH via Uniswap.
 */
contract DCA is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // --- State ---
    /// @notice Timestamp of last DCA execution
    uint256 public lastInvestment;
    /// @notice Amount of USDC to invest each period (in USDC smallest unit)
    uint256 public amountOfInvestment = 500 * 10 ** 6;
    /// @notice DCA interval in seconds (default 30 days)
    uint256 public interval;

    /// @notice USDC token contract
    IERC20 public immutable usdc;
    /// @notice Uniswap V2 router contract
    IUniswapV2Router public immutable router;

    // --- Events ---
    /// @notice Emitted when USDC is deposited
    event FundsDeposited(address indexed sender, uint256 amount);
    /// @notice Emitted when DCA swap is executed
    event DCAExecuted(uint256 indexed amountIn, uint256 amountOut, uint256 timestamp);
    /// @notice Emitted when ETH is withdrawn
    event ETHWithdrawn(address indexed to, uint256 amount);
    /// @notice Emitted when investment parameters are updated
    event ParametersUpdated(uint256 newAmountOfInvestment, uint256 newInterval);

    // --- Constructor ---
    constructor(address _usdc, address _router) {
        require(_usdc != address(0) && _router != address(0), "Invalid addresses");
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
        require(amount > 0, "Amount > 0");
        require(address(this).balance >= amount, "Insufficient ETH");

        (bool success,) = owner().call{value: amount}("");
        require(success, "Transfer failed");
        // Emit event after successful transfer
        emit ETHWithdrawn(owner(), amount);
    }

    /**
     * @notice Updates the DCA parameters
     * @param _amountOfInvestment New USDC amount per DCA
     * @param _interval New interval in seconds between DCAs
     */
    function updateParameters(uint256 _amountOfInvestment, uint256 _interval) external onlyOwner {
        require(_amountOfInvestment > 0, "Amount > 0");
        require(_interval >= 1 days, "Interval >= 1 day");

        amountOfInvestment = _amountOfInvestment;
        interval = _interval;
        emit ParametersUpdated(_amountOfInvestment, _interval);
    }

    // --- Public Functions ---
    /**
     * @notice Deposits USDC into the contract to fund future DCAs
     * @param _amount Amount of USDC (smallest unit) to deposit
     */
    function depositFunds(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount > 0");
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        emit FundsDeposited(msg.sender, _amount);
    }

    /**
     * @notice Executes a DCA swap of USDC for ETH via Uniswap
     * @param etherMin Minimum ETH out
     * @param deadline Unix timestamp after which the swap will revert
     */
    function performDCA(uint256 etherMin, uint256 deadline) external onlyOwner nonReentrant {
        require(block.timestamp >= lastInvestment + interval, "Too early");
        require(usdc.balanceOf(address(this)) >= amountOfInvestment, "Insufficient USDC");

        // Approve and execute swap
        usdc.safeApprove(address(router), amountOfInvestment);
        address[] memory path = new address[](2);
        path[0] = address(usdc);
        path[1] = router.WETH();

        uint256 preBalance = address(this).balance;
        router.swapExactTokensForETH(amountOfInvestment, etherMin, path, address(this), deadline);
        uint256 received = address(this).balance - preBalance;

        lastInvestment = block.timestamp;
        interval = 30 days;
        emit DCAExecuted(amountOfInvestment, received, block.timestamp);
    }

    // --- Emergency ---
    /**
     * @notice Rescue any ERC20 tokens mistakenly sent to this contract
     * @param token Address of the token to rescue
     * @param to Recipient address
     * @param amount Amount to rescue
     */
    function rescueTokens(address token, address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid recipient");
        IERC20(token).safeTransfer(to, amount);
    }
}
