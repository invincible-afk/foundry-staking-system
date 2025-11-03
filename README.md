# 🪙 ERC20 Staking System with Time-Based Rewards

Professional staking protocol built with Foundry featuring dynamic reward calculations and early withdrawal penalties.

![Solidity](https://img.shields.io/badge/Solidity-^0.8.13-blue)
![Foundry](https://img.shields.io/badge/Foundry-Framework-red)
![Tests](https://img.shields.io/badge/Tests-9%20Passing-brightgreen)
![Coverage](https://img.shields.io/badge/Coverage-84.15%25-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🌟 Features

- ✅ **ERC20 Token Implementation** - Full standard compliance
- ✅ **Stake & Earn** - Deposit tokens to earn time-based rewards
- ✅ **Dynamic Rewards** - Calculated per-second based on stake amount
- ✅ **Early Withdrawal Penalty** - 10% fee for withdrawals before minimum time
- ✅ **Flexible Claims** - Claim rewards without unstaking
- ✅ **Multi-User Support** - Unlimited concurrent stakers
- ✅ **Gas Optimized** - Efficient storage and calculations
- ✅ **Comprehensive Tests** - 9 tests with 84% coverage

## ⚠️ Note on APY

The current reward rate (~15,768% APY) is set for **DEMONSTRATION PURPOSES ONLY** to showcase mathematical calculations and time-based mechanics.

### Production-Ready Rates:
For a real protocol, sustainable rates would be:
- **Launch Phase** (3 months): 200-500% APY
- **Growth Phase** (6 months): 100-200% APY  
- **Stable Phase**: 50-100% APY

Real rewards should come from protocol fees, treasury management, and capped emissions.

## 🏗️ Architecture
```
staking-project/
├── src/
│   ├── RewardToken.sol      # ERC20 token with standard functions
│   └── StakingPool.sol      # Staking logic with reward distribution
└── test/
    └── StakingPool.t.sol    # Comprehensive test suite
```

## 🚀 Quick Start

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation
```bash
# Clone repository
git clone https://github.com/invincible-afk/staking-project.git
cd staking-project

# Install dependencies
forge install

# Compile contracts
forge build
```

### Run Tests
```bash
# Run all tests
forge test

# Run with verbosity
forge test -vv

# Generate gas report
forge test --gas-report

# Check coverage
forge coverage
```

## 📊 Test Results
```
✅ test_Stake                     - Basic staking functionality
✅ test_CalculateReward           - Reward calculation accuracy
✅ test_ClaimReward               - Claiming without unstaking
✅ test_WithdrawWithReward        - Full withdrawal with rewards
✅ test_EarlyWithdrawPenalty      - Penalty mechanism
✅ test_MultipleStakers           - Concurrent users
✅ testFuzz_Stake                 - Fuzz testing (256 runs)

Suite result: ok. 9 passed; 0 failed
```

## 📈 Gas Report

| Contract | Function | Avg Gas | Min | Max |
|----------|----------|---------|-----|-----|
| StakingPool | stake() | 115,530 | 98,507 | 115,643 |
| StakingPool | withdraw() | 48,616 | 46,697 | 50,535 |
| StakingPool | claimReward() | 52,464 | 52,464 | 52,464 |
| StakingPool | calculateReward() | 8,155 | 8,155 | 8,155 |

## 🔧 Core Parameters
```solidity
REWARD_RATE = 1e15;              // 0.001 tokens per second
MIN_STAKE_TIME = 1 days;         // Minimum time before penalty-free withdrawal
EARLY_WITHDRAW_PENALTY = 10;     // 10% penalty for early withdrawal
```

## 💡 How It Works

### Staking Process

1. User approves StakingPool to spend RewardTokens
2. User calls `stake(amount)` to deposit tokens
3. Rewards accumulate based on: `reward = (stakeAmount × rewardRate × timeStaked) / 1e18`
4. User can:
   - **Claim rewards** without unstaking via `claimReward()`
   - **Withdraw stake** + rewards via `withdraw(amount)`

### Reward Calculation
```solidity
reward = (stakedAmount × REWARD_RATE × secondsStaked) / 1e18

Example:
- Stake: 1000 tokens
- Time: 2 days (172,800 seconds)
- Reward: (1000e18 × 1e15 × 172,800) / 1e18 = 172,800 tokens
```

### Early Withdrawal Penalty

If withdrawal occurs before `MIN_STAKE_TIME`:
- 10% penalty applied to **rewards only**
- Staked principal always returned in full

## 🧪 Testing Highlights

### Advanced Testing Techniques Used:

- **Cheatcodes**: `vm.prank()`, `vm.warp()`, `vm.deal()`
- **Time Manipulation**: Testing across different timeframes
- **Multiple Users**: Concurrent staking scenarios
- **Fuzz Testing**: 256 iterations with random values
- **Edge Cases**: Zero amounts, early withdrawals, boundaries

### Sample Test:
```solidity
function test_WithdrawWithReward() public {
    vm.prank(alice);
    pool.stake(1000 ether);
    
    // Fast forward 2 days
    vm.warp(block.timestamp + 2 days);
    
    vm.prank(alice);
    pool.withdraw(1000 ether);
    
    // Verify alice received stake + rewards
    assertGt(token.balanceOf(alice), initialBalance + 1000 ether);
}
```

## 🎓 Learning Objectives

This project demonstrates:

- ✅ **ERC20 Standard** implementation
- ✅ **Contract Interactions** between StakingPool and Token
- ✅ **Time-Based Logic** using `block.timestamp`
- ✅ **Mathematical Calculations** with proper decimal handling
- ✅ **Testing Best Practices** with Foundry
- ✅ **Gas Optimization** techniques
- ✅ **Event Emission** and tracking

## 🔐 Security Considerations

- ✅ No reentrancy vulnerabilities (CEI pattern followed)
- ✅ Overflow protection (Solidity 0.8+ built-in)
- ✅ Zero address checks
- ✅ Sufficient balance validations
- ⚠️ Note: This is a learning project, not audited for production

## 🛣️ Roadmap

Future improvements could include:

- [ ] Tiered staking (Bronze, Silver, Gold)
- [ ] Time-lock bonuses (longer lock = higher APY)
- [ ] Governance token integration
- [ ] Emergency pause mechanism
- [ ] Multi-token reward support
- [ ] Mainnet deployment with real tokenomics

## 📚 Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [ERC20 Standard](https://eips.ethereum.org/EIPS/eip-20)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 👤 Author

**invincible-afk**
- GitHub: [@invincible-afk](https://github.com/invincible-afk)
- Learning Web3 & Smart Contract Development with Foundry

---

⭐ If this project helped you learn, consider giving it a star!

Built with ❤️ using Foundry
