// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function WETH() external returns (address);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract DCA {
    address public owner;
    uint256 public lastInvestment;
    uint256 public amountOfInvestment = 500 * 10 ** 6;

    IERC20 immutable usdcContract =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IUniswapV2Router immutable uniswapV2RouterContract =
        IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor() {
        owner = msg.sender;
        lastInvestment = block.timestamp; // initialize to avoid unintended early swaps
    }

    // Allow contract to receive ETH from Uniswap and deposits
    receive() external payable {}

    fallback() external payable {}
    /// @notice Withdraws ETH from the contract to the owner.
    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "you are not the owner");
        require(amount <= address(this).balance, "not enough balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "tx failed");
    
    }
     /// @notice depositFunds allows anyone to deposit USDC into the contract.
    function depositFunds(uint256 _amount) external {
        usdcContract.transferFrom(msg.sender, address(this), _amount);
    }
    /// @notice performDCA swaps USDC for ETH using Uniswap.
    /// @param _etherMin Minimum amount of ETH to receive from the swap.
    /// @param _deadline Deadline for the swap transaction.
    /// @dev Only the owner can call this function.
    /// @dev Requires at least 30 days since the last investment.
    /// @dev Approves the Uniswap router to spend USDC.
    /// @dev Swaps USDC for ETH using Uniswap.
    /// @dev Updates the lastInvestment timestamp.
    function performDCA(uint256 _etherMin, uint256 _deadline) external {
        require(msg.sender == owner, "you are not the owner");
        require(block.timestamp > lastInvestment + 30 days, "try again");

        address[] memory path = new address[](2);
        path[0] = address(usdcContract);
        path[1] = uniswapV2RouterContract.WETH();

        usdcContract.approve(
            address(uniswapV2RouterContract),
            amountOfInvestment
        );
        uniswapV2RouterContract.swapExactTokensForETH(
            amountOfInvestment,
            _etherMin,
            path,
            address(this),
            _deadline
        );

        lastInvestment = block.timestamp;
    }
}
