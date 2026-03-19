---
name: web3
description: |
  Blockchain and Web3 development skill. Activates when building, auditing, or deploying smart contracts, decentralized applications, and token systems. Covers smart contract development (Solidity, Rust/Anchor), security auditing (reentrancy, overflow, access control), token standards (ERC-20, ERC-721, ERC-1155), DApp architecture, wallet integration, gas optimization, and multi-chain deployment. Every recommendation includes concrete code and security analysis. Triggers on: /godmode:web3, "smart contract", "blockchain", "DApp", "Solidity", "token", "NFT", "DeFi", "Web3".
---

# Web3 — Blockchain & Web3 Development

## When to Activate
- User invokes `/godmode:web3`
- User says "smart contract", "blockchain", "DApp", "decentralized app"
- User mentions "Solidity", "Rust Anchor", "Hardhat", "Foundry", "Truffle"
- User mentions "ERC-20", "ERC-721", "ERC-1155", "token", "NFT"
- User mentions "DeFi", "DEX", "liquidity pool", "staking", "yield"
- When auditing contract security (reentrancy, overflow, access control)
- When optimizing gas costs or deploying to mainnet
- When integrating wallets (MetaMask, WalletConnect, Phantom)

## Workflow

### Step 1: Web3 Project Assessment
Determine the blockchain development approach:

```
WEB3 PROJECT ASSESSMENT:
Project type: <new contract | existing contract audit | DApp | token launch>
Target chain: <Ethereum | Solana | Polygon | Arbitrum | Base | multi-chain>
Contract language: <Solidity | Rust (Anchor) | Vyper | Move>

If Solidity:
  Framework: <Hardhat | Foundry | Truffle (legacy)>
  Solidity version: <e.g., ^0.8.24>
  Compiler optimizations: <enabled | disabled> (runs: <200 | 1000 | 10000>)

If Rust/Anchor:
  Anchor version: <e.g., 0.30.x>
  Cluster target: <devnet | testnet | mainnet-beta>

Contract category:
  Type: <token | NFT | DeFi | DAO | marketplace | custom>
  Upgradeability: <immutable | proxy (UUPS/Transparent) | diamond>
  External integrations: <Chainlink | Uniswap | OpenZeppelin | none>

Security requirements:
  Audit status: <unaudited | internal audit | external audit planned>
  Value at risk: <low (<$100K) | medium ($100K-$1M) | high (>$1M)>
  Formal verification: <required | optional | not needed>
```

### Step 2: Smart Contract Architecture

#### Solidity Project Structure
```
SOLIDITY PROJECT STRUCTURE (Hardhat/Foundry):
├── src/ or contracts/       # Smart contract source files
│   ├── Token.sol            # Main contract
│   ├── interfaces/          # Interface definitions
│   │   └── IToken.sol
│   ├── libraries/           # Shared libraries
│   │   └── MathLib.sol
│   └── utils/               # Utility contracts
│       └── Multicall.sol
├── test/                    # Test files
│   ├── Token.t.sol          # Foundry tests (Solidity)
│   └── Token.test.ts        # Hardhat tests (TypeScript)
├── script/                  # Deployment scripts
│   ├── Deploy.s.sol         # Foundry deploy script
│   └── deploy.ts            # Hardhat deploy script
├── lib/                     # Git submodule dependencies (Foundry)
├── node_modules/            # npm dependencies (Hardhat)
├── foundry.toml             # Foundry config
├── hardhat.config.ts        # Hardhat config
├── .env                     # Environment variables (NEVER commit)
└── .env.example             # Template for env vars

Rules:
  - One contract per file, file name matches contract name
  - Interfaces prefixed with I (IToken, IERC20)
  - Libraries are stateless — pure/view functions only
  - Constants in UPPER_SNAKE_CASE
  - Events emitted for every state change
  - NatSpec comments on all public/external functions
```

#### Anchor (Solana) Project Structure
```
ANCHOR PROJECT STRUCTURE:
├── programs/
│   └── my_program/
│       └── src/
│           ├── lib.rs           # Program entry point
│           ├── instructions/    # Instruction handlers
│           │   ├── mod.rs
│           │   ├── initialize.rs
│           │   └── transfer.rs
│           ├── state/           # Account data structures
│           │   ├── mod.rs
│           │   └── vault.rs
│           └── errors.rs        # Custom error codes
├── tests/                       # Integration tests (TypeScript)
│   └── my_program.ts
├── migrations/                  # Deployment migrations
├── Anchor.toml                  # Anchor configuration
├── Cargo.toml                   # Rust workspace config
└── package.json                 # JS/TS dependencies

Rules:
  - Separate instruction handlers into individual files
  - Account validation via Anchor constraints (#[account(...)])
  - Custom errors with descriptive codes (not magic numbers)
  - PDA derivation seeds are explicit and documented
  - All accounts are validated — never trust client-provided accounts
```

### Step 3: Token Standards Implementation

#### ERC-20 (Fungible Token)
```
ERC-20 IMPLEMENTATION CHECKLIST:
[ ] Inherit from OpenZeppelin ERC20 base
[ ] Configure name, symbol, decimals
[ ] Set initial supply and minting policy
[ ] Implement access control for privileged functions
[ ] Add permit (ERC-2612) for gasless approvals
[ ] Consider: burnable, pausable, capped supply, snapshots
[ ] Events: Transfer, Approval (inherited from base)

Security checks:
  [ ] No approve front-running vulnerability (use increaseAllowance/decreaseAllowance)
  [ ] Transfer to zero address blocked
  [ ] Overflow protection (Solidity ^0.8 built-in or SafeMath)
  [ ] Minting authority properly restricted
  [ ] Pausable only by authorized roles (not single EOA — use multisig)
```

#### ERC-721 (Non-Fungible Token)
```
ERC-721 IMPLEMENTATION CHECKLIST:
[ ] Inherit from OpenZeppelin ERC721 base
[ ] Configure name, symbol, base URI
[ ] Implement minting logic (sequential IDs, merkle allowlist, public mint)
[ ] Set max supply cap (enforced in contract, not just frontend)
[ ] Implement royalties (ERC-2981)
[ ] Metadata: on-chain or IPFS (use CID, not gateway URL)
[ ] Consider: enumerable, burnable, pausable, reveal mechanism

Security checks:
  [ ] Reentrancy guard on mint/transfer with callbacks
  [ ] Max mint per transaction to prevent gas griefing
  [ ] Max mint per wallet to prevent whale accumulation
  [ ] Merkle proof verification for allowlist minting
  [ ] Randomized token assignment to prevent sniping
  [ ] Withdrawal function uses pull pattern (not push)
```

#### ERC-1155 (Multi-Token)
```
ERC-1155 IMPLEMENTATION CHECKLIST:
[ ] Inherit from OpenZeppelin ERC1155 base
[ ] Define token IDs and their supply types (fungible, non-fungible, semi-fungible)
[ ] Implement batch minting and batch transfers
[ ] Configure URI with {id} substitution pattern
[ ] Implement supply tracking if needed (ERC1155Supply)
[ ] Consider: burnable, pausable, updatable URI

Security checks:
  [ ] Reentrancy guard on functions with callbacks
  [ ] Batch operations validate array length consistency
  [ ] Access control on minting functions
  [ ] URI updates restricted to authorized roles
```

### Step 4: Smart Contract Security Audit

```
SECURITY AUDIT CHECKLIST — CRITICAL VULNERABILITIES:

Reentrancy:
  [ ] All external calls are LAST (checks-effects-interactions pattern)
  [ ] ReentrancyGuard applied to functions with ETH transfers or callbacks
  [ ] Cross-function reentrancy checked (shared state between functions)

Access Control:
  [ ] Owner/admin functions use onlyOwner or role-based (AccessControl)
  [ ] Role hierarchy is minimal (principle of least privilege)
  [ ] Privileged operations behind timelock for high-value contracts
  [ ] Renounce ownership considered (or transfer to multisig)

Integer/Math:
  [ ] Solidity ^0.8 used (built-in overflow protection)
  [ ] Division before multiplication avoided (precision loss)
  [ ] Rounding direction explicit and correct for the use case

Oracle/Price Manipulation:
  [ ] Chainlink price feeds with staleness checks
  [ ] TWAP used instead of spot prices where applicable
  [ ] Minimum liquidity checks before trusting prices
  [ ] Fallback oracle configured

Flash Loan Attacks:
  [ ] No single-transaction price-dependent operations
  [ ] Governance votes have minimum holding period
  [ ] Liquidity checks span multiple blocks

Denial of Service:
  [ ] No unbounded loops over user-controlled arrays
  [ ] Pull over push payment pattern
  [ ] External call failures don't block contract operation
  [ ] Gas limits considered for all loops

Front-Running:
  [ ] Commit-reveal scheme for sensitive operations
  [ ] Maximum slippage parameters on trades
  [ ] Deadline parameters on time-sensitive transactions

Upgrade Safety:
  [ ] Storage layout compatible between versions
  [ ] Initializer used instead of constructor (for proxies)
  [ ] Implementation contract cannot be initialized directly
  [ ] Storage gaps reserved for future base contract upgrades
```

### Step 5: Gas Optimization

```
GAS OPTIMIZATION TECHNIQUES:

Storage:
  [ ] Pack struct fields (uint128 + uint128 fits in one slot)
  [ ] Use uint256 unless packing (smaller types cost MORE unpacked)
  [ ] Use bytes32 instead of string for short fixed-length data
  [ ] Use mappings over arrays when possible (no length tracking overhead)
  [ ] Cache storage reads in memory variables (SLOAD is 2100 gas)
  [ ] Use immutable for values set in constructor (embedded in bytecode)
  [ ] Use constant for compile-time known values (zero storage cost)
  [ ] Delete storage you no longer need (gas refund)

Function:
  [ ] Use external over public for functions not called internally
  [ ] Use calldata over memory for read-only function parameters
  [ ] Short-circuit conditions (cheapest check first in require chains)
  [ ] Use custom errors over require strings (saves ~50 bytes per error)
  [ ] Use unchecked blocks where overflow is impossible (saves ~60 gas per operation)
  [ ] Avoid redundant zero-initialization (uint256 x is already 0)

Patterns:
  [ ] Batch operations (single SSTORE for multiple logical updates)
  [ ] Bitmap instead of mapping(uint => bool) for sequential IDs
  [ ] Merkle proofs instead of on-chain allowlists
  [ ] EIP-2929: access frequently used storage slots early
  [ ] Use assembly for simple operations (be cautious, audit carefully)

Measurement:
  Foundry: forge test --gas-report
  Hardhat: npx hardhat test (with hardhat-gas-reporter)
  Compare: snapshot gas before/after every optimization
```

### Step 6: DApp Architecture & Wallet Integration

```
DAPP ARCHITECTURE:
┌──────────────────────────────────────────────┐
│  Frontend (React/Next.js/Vue)                │
│  ├── wagmi/viem (Ethereum) or               │
│  │   @solana/web3.js (Solana)               │
│  ├── Wallet connection (RainbowKit,          │
│  │   WalletConnect, Wallet Adapter)          │
│  ├── Contract interaction hooks              │
│  └── Transaction state management            │
├──────────────────────────────────────────────┤
│  Indexing Layer                               │
│  ├── The Graph (subgraph) or                │
│  ├── Custom indexer (Ponder, Envio) or      │
│  └── Direct RPC (for simple queries)         │
├──────────────────────────────────────────────┤
│  Smart Contracts (on-chain)                  │
│  ├── Core business logic                     │
│  ├── Access control                          │
│  └── Events for off-chain indexing           │
├──────────────────────────────────────────────┤
│  Infrastructure                              │
│  ├── RPC provider (Alchemy, Infura, QuickNode)│
│  ├── IPFS (Pinata, nft.storage) for metadata │
│  └── Backend API (optional, for off-chain data)│
└──────────────────────────────────────────────┘

WALLET INTEGRATION CHECKLIST:
  [ ] Multiple wallet support (MetaMask, WalletConnect, Coinbase Wallet)
  [ ] Chain switching with user-friendly prompts
  [ ] Transaction confirmation UI (pending, success, failed states)
  [ ] Gas estimation displayed before confirmation
  [ ] ENS/SNS name resolution for addresses
  [ ] Transaction history from indexed events
  [ ] Mobile wallet deep linking
  [ ] Disconnect and session management
```

### Step 7: Deployment & Verification

```
DEPLOYMENT CHECKLIST:
Pre-deployment:
  [ ] All tests passing (unit, integration, fuzz)
  [ ] Security audit complete (internal + external for high-value)
  [ ] Gas benchmarks within budget
  [ ] Deployment script tested on testnet (full rehearsal)
  [ ] Constructor arguments verified
  [ ] Proxy admin and roles assigned to multisig (not EOA)
  [ ] Timelock configured for admin operations

Deployment:
  [ ] Deploy to testnet first (Sepolia/Goerli for Ethereum, devnet for Solana)
  [ ] Verify on block explorer (Etherscan, Solscan)
  [ ] Test all functions on testnet with real wallet interactions
  [ ] Deploy to mainnet
  [ ] Verify source code on mainnet block explorer
  [ ] Transfer admin roles to multisig
  [ ] Activate timelock

Post-deployment:
  [ ] Monitor contract events for unexpected behavior
  [ ] Set up alerts for large transfers, pauses, role changes
  [ ] Document deployed addresses in version-controlled file
  [ ] Update frontend to point to mainnet contracts
  [ ] Announce deployment (if public)

Verification commands:
  Foundry: forge verify-contract <address> <contract> --chain <chain>
  Hardhat: npx hardhat verify --network <network> <address> <constructor-args>
```

### Step 8: Web3 Development Report

```
┌────────────────────────────────────────────────────────────────┐
│  WEB3 PROJECT — <project name>                                  │
├────────────────────────────────────────────────────────────────┤
│  Chain: <Ethereum | Solana | Polygon | multi-chain>             │
│  Language: <Solidity | Rust/Anchor | Vyper>                     │
│  Framework: <Hardhat | Foundry | Anchor>                        │
│                                                                  │
│  Contracts:                                                      │
│    <ContractName>: <DRAFTED | TESTED | AUDITED | DEPLOYED>      │
│    <ContractName>: <DRAFTED | TESTED | AUDITED | DEPLOYED>      │
│                                                                  │
│  Security:                                                       │
│    Audit status: <UNAUDITED | INTERNAL | EXTERNAL | VERIFIED>   │
│    Vulnerabilities found: <N critical, N high, N medium, N low> │
│    Reentrancy: <SAFE | NEEDS FIX>                                │
│    Access control: <SAFE | NEEDS FIX>                            │
│    Oracle manipulation: <N/A | SAFE | NEEDS FIX>                │
│                                                                  │
│  Gas:                                                            │
│    Deployment cost: <N gas (~$X at Y gwei)>                      │
│    Key function costs:                                           │
│      mint(): <N gas>                                             │
│      transfer(): <N gas>                                         │
│                                                                  │
│  Deployment:                                                     │
│    Testnet: <address> (<VERIFIED | UNVERIFIED>)                  │
│    Mainnet: <address> (<VERIFIED | UNVERIFIED | NOT DEPLOYED>)   │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:secure — Deep security audit                     │
│        /godmode:test — Expand test coverage (fuzz, invariant)    │
│        /godmode:ship — Deploy to mainnet                         │
└────────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Commit contract code: `"web3: <chain> — <contract> smart contract scaffold"`
2. Commit tests: `"web3: <contract> — test suite with fuzz tests"`
3. Commit audit fixes: `"web3: fix <vulnerability> — <description>"`
4. If deployment-ready: "Contract is audited and tested. Run `/godmode:ship` to deploy."
5. If not ready: "Contract drafted. Run `/godmode:secure` for security audit."

## Key Behaviors

1. **Security is non-negotiable.** Every contract recommendation includes security implications. Smart contracts are immutable and handle real value — a bug can be catastrophic.
2. **Gas costs are user costs.** Every gas optimization directly reduces what users pay. Measure gas for every public function and optimize the hot paths.
3. **Test beyond happy paths.** Fuzz testing, invariant testing, and formal verification catch bugs that unit tests miss. Smart contracts need the highest test confidence.
4. **Audit before deploy.** Internal audit is minimum. External audit is required for contracts holding significant value. Never rush to mainnet.
5. **Events are your indexing API.** Emit events for every state change. Off-chain indexers depend on them. Missing events means missing data.
6. **Upgradeability is a tradeoff.** Upgradeable contracts add complexity and trust assumptions. Use only when the benefits outweigh the risks.

## Example Usage

### Creating an ERC-721 NFT collection
```
User: /godmode:web3 Build an NFT collection with allowlist minting

Web3: Assessing requirements...

WEB3 PROJECT:
Chain: Ethereum (ERC-721)
Framework: Foundry
Contract: NFT collection with allowlist + public mint

Architecture:
  /src
    MyNFT.sol         — ERC-721 with merkle allowlist, royalties (ERC-2981)
    interfaces/IMyNFT.sol
  /test
    MyNFT.t.sol       — Unit + fuzz tests
  /script
    Deploy.s.sol      — Deployment script

Security:
  - Reentrancy guard on mint
  - Max mint per wallet (allowlist: 2, public: 5)
  - Max supply enforced in contract
  - Merkle proof for allowlist (gas-efficient)
  - Pull withdrawal pattern for funds

Gas report:
  allowlistMint(): ~85,000 gas
  publicMint(): ~78,000 gas
  deploy: ~2,100,000 gas

Next: /godmode:test to add invariant tests
      /godmode:secure for full security audit
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Web3 project assessment and setup |
| `--audit` | Security audit only (no new code) |
| `--gas` | Gas optimization analysis only |
| `--deploy` | Deployment preparation and execution |
| `--token <standard>` | Implement specific token (erc20, erc721, erc1155) |
| `--chain <name>` | Target specific chain (ethereum, solana, polygon, arbitrum) |
| `--framework <name>` | Use specific framework (hardhat, foundry, anchor) |

## Anti-Patterns

- **Do NOT deploy unaudited contracts with real value.** Even well-tested contracts can have subtle vulnerabilities. Internal audit is the absolute minimum.
- **Do NOT use tx.origin for authentication.** It is vulnerable to phishing attacks. Use msg.sender.
- **Do NOT store sensitive data on-chain.** All blockchain data is public. Use commit-reveal or off-chain computation for private data.
- **Do NOT use block.timestamp for critical randomness.** Miners can manipulate timestamps within ~15 seconds. Use Chainlink VRF for verifiable randomness.
- **Do NOT approve unlimited token spending.** Approve only the amount needed, or use permit for single-transaction approval.
- **Do NOT ignore gas costs during development.** Gas optimization after the fact is harder and riskier than designing for efficiency from the start.
- **Do NOT use floating pragma (^0.8.0) in production.** Pin to exact version (0.8.24) to ensure reproducible builds and avoid compiler bug regressions.
- **Do NOT skip testnet deployment.** Always rehearse the full deployment flow on testnet before touching mainnet. Include upgrade procedures if using proxies.
