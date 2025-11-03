// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RewardToken.sol";

contract StakingPool {
    RewardToken public rewardToken;
    
    // Recompensa por segundo: 0.001 tokens = 1000000000000000 wei
    uint256 public constant REWARD_RATE = 1e15; // 0.001 tokens por segundo
    uint256 public constant MIN_STAKE_TIME = 1 days;
    uint256 public constant EARLY_WITHDRAW_PENALTY = 10; // 10% de penalización
    
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt;
    }
    
    mapping(address => Stake) public stakes;
    uint256 public totalStaked;
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    
    constructor(address _rewardToken) {
        rewardToken = RewardToken(_rewardToken);
    }
    
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        
        // Si ya tiene stake, reclamar recompensas primero
        if (stakes[msg.sender].amount > 0) {
            _claimReward();
        }
        
        // Transferir tokens del usuario al contrato
        rewardToken.transferFrom(msg.sender, address(this), amount);
        
        stakes[msg.sender].amount += amount;
        stakes[msg.sender].startTime = block.timestamp;
        totalStaked += amount;
        
        emit Staked(msg.sender, amount);
    }
    
    function withdraw(uint256 amount) external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "Insufficient staked amount");
        
        uint256 reward = calculateReward(msg.sender);
        
        // Aplicar penalización si retira antes de tiempo
        if (block.timestamp < userStake.startTime + MIN_STAKE_TIME) {
            uint256 penalty = (reward * EARLY_WITHDRAW_PENALTY) / 100;
            reward -= penalty;
        }
        
        userStake.amount -= amount;
        totalStaked -= amount;
        
        // Transferir stake + recompensa
        rewardToken.transfer(msg.sender, amount + reward);
        
        // Resetear tiempo si sigue con stake
        if (userStake.amount > 0) {
            userStake.startTime = block.timestamp;
        }
        
        emit Withdrawn(msg.sender, amount, reward);
    }
    
    function claimReward() external {
        _claimReward();
    }
    
    function _claimReward() internal {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");
        
        stakes[msg.sender].startTime = block.timestamp;
        rewardToken.transfer(msg.sender, reward); // Transferir desde el pool
        
        emit RewardClaimed(msg.sender, reward);
    }
    
    function calculateReward(address user) public view returns (uint256) {
        Stake memory userStake = stakes[user];
        if (userStake.amount == 0) {
            return 0;
        }
        
        uint256 timeStaked = block.timestamp - userStake.startTime;
        uint256 reward = (userStake.amount * REWARD_RATE * timeStaked) / 1e18;
        
        return reward;
    }
    
    function getStakeInfo(address user) external view returns (
        uint256 stakedAmount,
        uint256 stakingTime,
        uint256 pendingReward
    ) {
        Stake memory userStake = stakes[user];
        return (
            userStake.amount,
            block.timestamp - userStake.startTime,
            calculateReward(user)
        );
    }
}
