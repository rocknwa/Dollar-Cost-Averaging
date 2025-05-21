# DCA

A secure and efficient **Solidity smart contract** for automating **Dollar-Cost Averaging (DCA)** investments from USDC to ETH on Uniswap V2. Built with **OpenZeppelin**, **Foundry**, and optimized for gas efficiency, this project demonstrates advanced proficiency in **smart contract development**, **DeFi protocol integration**, and **secure blockchain automation**. The Uniswap DCA System is designed for Ethereum mainnet, enabling periodic investments to mitigate market volatility, with comprehensive testing and deployment scripts.

---

## 📋 Project Overview

The **DCA** automates a Dollar-Cost Averaging strategy, allowing users to deposit USDC, which the contract owner swaps for ETH on Uniswap V2 every 30 days (configurable). The project includes a core smart contract, Foundry deployment/interaction scripts, and a robust test suite, showcasing secure DeFi automation and modern blockchain development practices.

**Key Components:**
1. **DCA.sol**: The core contract for depositing USDC, executing DCA swaps, withdrawing ETH profits, and rescuing misplaced tokens, with secure Uniswap V2 integration.
2. **Foundry Scripts**: Scripts for deploying the contract, depositing funds, updating parameters, performing DCA, withdrawing ETH, and rescuing tokens.
3. **Test Suite**: Comprehensive Foundry tests with 100% coverage, validating all functionality and edge cases, including mainnet-fork simulations.

This project highlights my ability to build **production-ready DeFi solutions**, making it an ideal showcase for recruiters and clients seeking blockchain talent.

---

## 🚀 Features

- **Dollar-Cost Averaging**:
  - Automates periodic swaps of USDC to ETH (default: 500 USDC every 30 days) via Uniswap V2.
  - Configurable investment amount and interval (minimum 1 day) by the owner.
  - Supports slippage protection with minimum ETH output and swap deadlines.

- **Secure Fund Management**:
  - Allows anyone to deposit USDC to fund DCA swaps.
  - Enables owner-only ETH withdrawals for accumulated profits.
  - Includes an emergency token rescue function for recovering misplaced ERC20 tokens.

- **Security and Optimization**:
  - Uses OpenZeppelin’s `Ownable` for access control and `ReentrancyGuard` for protection against reentrancy attacks.
  - Employs immutable variables for USDC and Uniswap V2 Router addresses to reduce gas costs.
  - Includes comprehensive error handling and event emission for transparency (`FundsDeposited`, `DCAExecuted`, `ETHWithdrawn`, `ParametersUpdated`).

- **Comprehensive Testing**:
  - Foundry test suite with 100% coverage, testing deposits, DCA swaps, withdrawals, parameter updates, and edge cases (e.g., non-owner access, insufficient funds).
  - Simulates mainnet conditions using USDC whale accounts and mock tokens.
  - Validates failure scenarios like premature DCA attempts and failed ETH transfers.

- **Deployment and Interaction**:
  - Foundry scripts for deploying the contract and performing actions (deposit, withdraw, update parameters, rescue tokens).
  - Environment variable integration for secure private key and contract address management.

---

## 💡 Achievements

- **Gas Optimization**: Utilized immutable variables for USDC and Uniswap V2 Router addresses to eliminate storage costs and minimized state updates (e.g., single `lastInvestment` write per swap).
- **Security Best Practices**: Enforced owner-only access for critical functions, implemented safe ETH transfers with balance checks, and used OpenZeppelin’s `SafeERC20` for secure token handling.
- **Complex Integrations**: Seamlessly integrated Uniswap V2 for USDC-to-ETH swaps and USDC’s ERC20 contract for precise token transfers, handling 6-decimal precision and dynamic swap paths.
- **Comprehensive Testing**: Achieved 100% test coverage with Foundry, including mainnet-fork tests with real USDC and Uniswap V2 addresses, and simulated edge cases (e.g., reentrancy, failed transfers).
- **User-Friendly Design**: Simplified the DCA process with a single owner-triggered function, making the contract intuitive while maintaining robust security.

---

## 🛠️ Technical Stack

- **Languages and Frameworks**:
  - Solidity (^0.8.20)
  - Foundry (Forge) for testing and deployment
  - OpenZeppelin Contracts (`Ownable`, `ReentrancyGuard`, `SafeERC20`)

- **DeFi Protocols**:
  - Uniswap V2 (Router for token swaps)
  - USDC (ERC20 token)

- **Standards**:
  - ERC20 (for USDC interactions)
  - Uniswap V2 interfaces

- **Tools and Services**:
  - Forge (Foundry’s testing and scripting tool)
  - dotenv (for secure environment variable management)
  - Mainnet fork testing (via Alchemy or Infura RPC)

---

## 📦 Installation and Setup

### Prerequisites

- Foundry (Forge) installed
- Ethereum private key for deployment and interaction
- RPC URL (e.g., Alchemy, Infura) for mainnet or testnet
- USDC (`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`) and Uniswap V2 Router (`0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D`) addresses

### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/rocknwa/Dollar-Cost-Averaging.git
   cd Dollar-Cost-Averaging
   ```

2. **Install Dependencies**:
   ```bash
   forge install
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the root directory:
   ```env
   PRIVATE_KEY=your-ethereum-private-key
   PRIVATE_KEY_WHALE=your-usdc-whale-private-key
   DCA_ADDRESS=deployed-dca-contract-address
   TOKEN_TO_RESCUE=token-address-to-rescue
   RESCUE_TO=recipient-address-for-rescued-tokens
   RESCUE_AMOUNT=amount-to-rescue
   RPC_URL=your-alchemy-or-infura-url
   ```

4. **Compile the Contract**:
   ```bash
   forge build
   ```

5. **Deploy the Contract**:
   ```bash
   forge script script/DeployDCA.s.sol --rpc-url $RPC_URL --broadcast
   ```

6. **Run Interaction Scripts (e.g., deposit funds)**:
   ```bash
   forge script script/DepositFunds.s.sol --rpc-url $RPC_URL --broadcast
   ```

7. **Run Tests**:
   ```bash
   forge test --fork-url $RPC_URL -vvv
   ```

8. **Check Test Coverage**:
   ```bash
   forge coverage --fork-url $RPC_URL
   ```

---

## 🔍 Usage

### DCA.sol

The core contract supports:

- **Depositing USDC**: Fund the contract for DCA swaps (e.g., 500 USDC).
- **Performing DCA**: Swap USDC to ETH via Uniswap V2 at specified intervals (default: 30 days).
- **Withdrawing ETH**: Transfer accumulated ETH profits to the owner.
- **Updating Parameters**: Adjust investment amount and interval (minimum 1 day).
- **Rescuing Tokens**: Recover misplaced ERC20 tokens to a specified address.

### Foundry Scripts

- **DeployDCA.s.sol**: Deploys the DCA contract with USDC and Uniswap V2 Router addresses.
- **DepositFunds.s.sol**: Deposits 500 USDC to the contract.
- **PerformDCA.s.sol**: Executes a DCA swap (requires sufficient interval and USDC balance).
- **WithdrawETH.s.sol**: Withdraws ETH profits to the owner.
- **UpdateParams.s.sol**: Updates DCA parameters (e.g., 100 USDC, 7-day interval).
- **RescueTokens.s.sol**: Rescues specified ERC20 tokens to a recipient address.

**Run scripts with:**
```bash
forge script script/[ScriptName].s.sol --rpc-url $RPC_URL --broadcast
```

### Test Suite

The test suite (`DCATest.sol`) validates:

- Successful USDC deposits and balance updates.
- DCA execution with sufficient interval and funds.
- Owner-only restrictions for sensitive functions (e.g., performDCA, withdraw).
- Failure cases (e.g., premature DCA, insufficient balance, non-owner access).
- Token rescue functionality with mock ERC20 tokens.
- Edge cases like failed ETH transfers using a RevertingReceiver contract.

**Run with:**
```bash
forge test --fork-url $RPC_URL -vvv
```

---

## 📈 Why This Project Stands Out

- **Production-Ready Security:** Leverages OpenZeppelin’s battle-tested libraries (SafeERC20, Ownable, ReentrancyGuard) and enforces strict access controls, ensuring robust protection.
- **Gas Efficiency:** Uses immutable variables and minimal state changes to reduce gas costs, optimized for mainnet deployment.
- **Real-World DeFi Application:** Automates DCA to mitigate market volatility, suitable for retail or institutional investors.
- **Comprehensive Testing:** Achieves 100% test coverage with Foundry, including mainnet-fork tests and edge cases, ensuring reliability.
- **Modular Design:** Easily adaptable for other token pairs (e.g., DAI, WBTC) or AMMs (e.g., Uniswap V3, Curve).
- **Modern Tooling:** Demonstrates proficiency with Foundry, showcasing cutting-edge blockchain development practices.

---

## 🌟 Potential Applications

- **Personal Investment Automation:** Enables retail investors to automate DCA strategies on Ethereum.
- **Institutional DeFi Tools:** Provides scalable DCA solutions for crypto funds or portfolios.
- **Protocol Extension:** Adaptable for other DeFi protocols, token pairs, or AMMs.
- **Client Solutions:** Offers customizable smart contracts for DeFi automation to blockchain-focused clients.

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

_Built with 💻 and ☕ by Therock Ani._

**Email:** anitherock44@gmail.com

I am a passionate blockchain developer with expertise in Solidity, DeFi protocols, and smart contract security. This project showcases my ability to build secure, efficient, and practical DeFi solutions using modern tools like Foundry. I’m eager to contribute to innovative blockchain projects or develop tailored solutions for clients.
