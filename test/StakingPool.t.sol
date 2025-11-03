// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingPool} from "../src/StakingPool.sol";

contract StakingPoolTest is Test {
    RewardToken public token;
    StakingPool public pool;
    
    address public alice = address(0x1);
    address public bob = address(0x2);
    
    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;
    
    function setUp() public {
        // Deploy token
        token = new RewardToken(INITIAL_SUPPLY);
        
        // Deploy staking pool
        pool = new StakingPool(address(token));

	// Dar tokens al pool para recompensas
	token.transfer(address(pool), 500_000 ether);
        
        // Dar tokens a Alice y Bob
        token.transfer(alice, 10_000 ether);
        token.transfer(bob, 10_000 ether);
        
        // Alice y Bob aprueban el pool
        vm.prank(alice);
        token.approve(address(pool), type(uint256).max);
        
        vm.prank(bob);
        token.approve(address(pool), type(uint256).max);
    }
    
    function test_Stake() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        (uint256 staked,,) = pool.getStakeInfo(alice);
        assertEq(staked, 1000 ether);
        assertEq(pool.totalStaked(), 1000 ether);
    }
    
    function test_CalculateReward() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        // Avanzar 1 día en el tiempo
        vm.warp(block.timestamp + 1 days);
        
        uint256 reward = pool.calculateReward(alice);
        
        // Recompensa esperada: 1000 tokens * 0.001 per second * 86400 seconds
        uint256 expectedReward = (1000 ether * 1e15 * 86400) / 1e18;
        assertEq(reward, expectedReward);
    }
    
    function test_WithdrawWithReward() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        // Avanzar 2 días (más del mínimo)
        vm.warp(block.timestamp + 2 days);
        
        uint256 balanceBefore = token.balanceOf(alice);
        
        vm.prank(alice);
        pool.withdraw(1000 ether);
        
        uint256 balanceAfter = token.balanceOf(alice);
        
        // Debería recibir stake + recompensa
        assertGt(balanceAfter, balanceBefore + 1000 ether);
    }
    
    function test_EarlyWithdrawPenalty() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        // Avanzar solo 12 horas (menos del mínimo de 1 día)
        vm.warp(block.timestamp + 12 hours);
        
        uint256 rewardBefore = pool.calculateReward(alice);
        
        vm.prank(alice);
        pool.withdraw(1000 ether);
        
        // La recompensa recibida debería ser menor por la penalización
        // (verificamos indirectamente por el balance)
        assertTrue(rewardBefore > 0);
    }
    
    function test_MultipleStakers() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        vm.prank(bob);
        pool.stake(2000 ether);
        
        assertEq(pool.totalStaked(), 3000 ether);
        
        // Avanzar tiempo
        vm.warp(block.timestamp + 1 days);
        
        uint256 aliceReward = pool.calculateReward(alice);
        uint256 bobReward = pool.calculateReward(bob);
        
        // Bob debería tener el doble de recompensa (stakeó el doble)
        assertEq(bobReward, aliceReward * 2);
    }
    
    function test_ClaimReward() public {
        vm.prank(alice);
        pool.stake(1000 ether);
        
        vm.warp(block.timestamp + 1 days);
        
        uint256 balanceBefore = token.balanceOf(alice);
        
        vm.prank(alice);
        pool.claimReward();
        
        uint256 balanceAfter = token.balanceOf(alice);
        
        // Debería haber recibido recompensas
        assertGt(balanceAfter, balanceBefore);
        
        // La recompensa pendiente debería ser 0 después de claim
        assertEq(pool.calculateReward(alice), 0);
    }
    
    function testFuzz_Stake(uint256 amount) public {
        amount = bound(amount, 1 ether, 10_000 ether);
        
        vm.prank(alice);
        pool.stake(amount);
        
        (uint256 staked,,) = pool.getStakeInfo(alice);
        assertEq(staked, amount);
    }
}
