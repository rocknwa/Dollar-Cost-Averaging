# Uniswap DCA System

The **Uniswap DCA System** is a streamlined decentralized finance (DeFi) project demonstrating advanced Solidity smart contract development. This project implements a Dollar-Cost Averaging (DCA) strategy, enabling the owner to periodically swap a fixed amount of USDC for ETH on Uniswap V2 every 30 days. The project showcases gas optimization, security best practices, and complex integrations, positioning the developer as a skilled blockchain professional capable of building efficient DeFi solutions.

---

## Project Overview

The Uniswap DCA System is a smart contract that automates dollar-cost averaging for cryptocurrency investments. It allows users to deposit USDC, which the owner can swap for ETH on Uniswap V2 at regular intervals (every 30 days), reducing the impact of market volatility.

**Key Features:**

- **USDC Deposits:** Anyone can deposit USDC to fund the DCA strategy.
- **DCA Swaps:** The owner triggers swaps of 500 USDC for ETH, with minimum output and deadline parameters.
- **ETH Withdrawals:** The owner can withdraw accumulated ETH from swaps.
- **Uniswap Integration:** Leverages Uniswap V2 for secure, decentralized token swaps.
- **Robust Testing:** Achieves 100% test coverage using Foundry, ensuring reliability.

This project highlights the developer’s ability to create a secure, efficient, and user-friendly DeFi application, making it an ideal showcase for recruiters seeking blockchain talent.

---

## Skills Demonstrated

The Uniswap DCA System demonstrates a robust set of technical and transferable skills:

### Technical Skills

- **Solidity Development:** Proficient in writing secure, modular smart contracts using Solidity 0.8.0.
- **Gas Optimization:** Minimized state changes (e.g., single `lastInvestment` update), used immutable variables for USDC and Uniswap addresses, and optimized approvals for efficiency.
- **Security Best Practices:** Implemented strict access controls (owner-only functions), safe ETH transfers with checks, and comprehensive error handling for all failure cases.
- **Complex Integrations:** Integrated Uniswap V2 Router for token swaps and USDC (ERC20) for token interactions, handling mainnet addresses and swap paths.
- **Testing with Foundry:** Achieved 100% test coverage with comprehensive unit tests, including mainnet-fork testing and failure scenarios, ensuring contract reliability.
- **Protocol Knowledge:** Deep understanding of Uniswap V2’s swap mechanics, ERC20 standards, and mainnet-fork testing environments.

### Transferable Skills

- **Problem-Solving:** Designed a DCA mechanism to mitigate market volatility, addressing real-world investment challenges.
- **Attention to Detail:** Ensured precise USDC handling (6 decimals) and robust revert conditions for security.
- **System Design:** Architected a simple, modular contract with clear interfaces for scalability and maintenance.
- **Adaptability:** Leveraged mainnet-fork testing to simulate real-world conditions, adapting to external protocol requirements.

---

## Contracts

The project includes a single core smart contract and a comprehensive test suite, emphasizing functionality and reliability:

- **DCA:** The main contract enabling USDC deposits, owner-triggered DCA swaps (500 USDC to ETH every 30 days), and ETH withdrawals. Demonstrates secure Uniswap V2 integration, gas-efficient design with immutable variables, and robust access controls.
- **DCATest:** A Foundry test suite achieving 100% coverage, testing deposit, DCA swap, withdrawal, and revert scenarios (e.g., non-owner access, insufficient balance, premature DCA). Includes a `RevertingReceiver` helper to test ETH transfer failures. Showcases thorough testing and mainnet-fork simulation.

---

## Achievements

- **Gas Optimization:** Used immutable variables for USDC and Uniswap addresses to eliminate storage costs, minimized state updates (e.g., single `lastInvestment` write per swap), and optimized ERC20 approvals for single-use in swaps.
- **Security Best Practices:** Enforced owner-only access for critical functions (DCA, withdraw), implemented safe ETH transfers with balance checks, and tested all revert paths (e.g., non-owner, insufficient balance, failed transfers) for robustness.
- **Complex Integrations:** Seamlessly integrated Uniswap V2 Router for USDC-to-ETH swaps, handling dynamic swap paths and deadline parameters, and interfaced with USDC’s ERC20 contract for precise token transfers.
- **Comprehensive Testing:** Achieved 100% test coverage with Foundry, including mainnet-fork tests with real USDC and Uniswap V2 addresses, and simulated failure cases (e.g., ETH transfer reverts) to ensure reliability.
- **User-Friendly Design:** Simplified the DCA process with a single owner-triggered function, making the contract intuitive while maintaining security and efficiency.

---

## Technical Stack

- **Programming Language:** Solidity 0.8.0
- **Development Framework:** [Foundry](https://book.getfoundry.sh/) (for testing and deployment)
- **DeFi Integrations:**
  - Uniswap V2 (token swaps)
  - USDC (ERC20 token)
- **Standards:** ERC20, Uniswap V2 interfaces
- **Networks:** Mainnet (via fork testing), deployable to Ethereum-compatible chains
- **Tools:** Forge for testing and scripting

---

## Setup and Testing

To explore the project, note the developer’s robust development environment:

### Prerequisites

- **Install Foundry:**
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **Install dependencies:** Ensure a Solidity-compatible environment (version 0.8.0).

### Clone the Repository

```bash
git clone https://github.com/rocknwa/Dollar-Cost-Averaging.git
cd Dollar-Cost-Averaging
```

### Run Tests

Execute the test suite with 100% coverage, using a mainnet fork:

```bash
forge test --fork-url $RPC_URL -vvv
```

Replace `$RPC_URL` in your `.env` file with a valid Ethereum mainnet node URL (e.g., Infura, Alchemy).

### Check Coverage
```bash
forge coverage --fork-url $FORK_URL
```
It will show 100% coverage for DCA.sol

### Deploy Contract

Example deployment on mainnet or a testnet:

```bash
forge create src/DCA.sol:DCA --rpc-url $RPC_URL 
```

The project’s 100% test coverage ensures reliability, with tests simulating real-world mainnet conditions and edge cases.

---

## Contact Information

For further inquiries or to discuss this project, please contact the developer via:

**Email:** anitherock44@gmail.com

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.