# /godmode:web3

Blockchain and Web3 development — smart contract development (Solidity, Rust/Anchor), security auditing (reentrancy, overflow, access control), token standards (ERC-20, ERC-721, ERC-1155), DApp architecture, wallet integration, gas optimization, and multi-chain deployment.

## Usage

```
/godmode:web3                              # Full Web3 project assessment
/godmode:web3 --audit                      # Security audit only
/godmode:web3 --gas                        # Gas optimization analysis
/godmode:web3 --deploy                     # Deployment preparation
/godmode:web3 --token erc721               # Implement ERC-721 token
/godmode:web3 --chain solana               # Target Solana chain
/godmode:web3 --framework foundry          # Use Foundry framework
```

## What It Does

1. Assesses Web3 project requirements (chain, language, contract type, upgradeability)
2. Sets up smart contract architecture (Solidity/Hardhat, Solidity/Foundry, or Rust/Anchor)
3. Implements token standards (ERC-20, ERC-721, ERC-1155) with OpenZeppelin bases
4. Conducts security audit against critical vulnerability checklist:
   - Reentrancy, access control, integer math, oracle manipulation
   - Flash loan attacks, denial of service, front-running, upgrade safety
5. Optimizes gas consumption (storage packing, calldata, custom errors, unchecked blocks)
6. Designs DApp architecture with wallet integration (wagmi/viem, RainbowKit, WalletConnect)
7. Manages deployment flow (testnet rehearsal, verification, multisig transfer, monitoring)

## Output
- Smart contract scaffold with chosen architecture
- Security audit report with vulnerability findings and severity
- Gas benchmark report for all public functions
- Deployment checklist with testnet and mainnet steps
- Commit: `"web3: <chain> — <description>"`

## Next Step
After scaffold: `/godmode:test` to add fuzz and invariant tests.
After testing: `/godmode:secure` for comprehensive security audit.
When ready: `/godmode:ship` to deploy to mainnet.

## Examples

```
/godmode:web3                              # Full project assessment and setup
/godmode:web3 --audit                      # Security audit existing contracts
/godmode:web3 --token erc721               # Build an NFT contract
/godmode:web3 --gas                        # Optimize gas consumption
/godmode:web3 --deploy                     # Prepare and execute deployment
```
