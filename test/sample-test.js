const Staking = artifacts.require("./Staking");
const MyToken = artifacts.require("./MyToken");

const {
  ether,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert,
  balance,
  time, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const { expect } = require("chai");
const BN = Web3.utils.BN;

contract("Staking", async ([owner, acc2, acc3, acc4]) => {

  let instanceToken;
  let instanceStaking;

  before(async () => {
    instanceToken = await MyToken.new();
    instanceStaking = await Staking.new(instanceToken.address);
  });

  describe("SetRewards", async () => {
    it("SetRewards", async () => {
      let balanceBeforee = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBeforee.toString());
      let start = await time.latest();
      await instanceToken.approve(instanceStaking.address , ether('500000'));
      await instanceStaking.setRewards(start.add(new BN(60)),ether('500000'),ether('10'));
      let balanceBefore = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBefore.toString());
      await instanceToken.approve(acc2 , ether('200'));
      await instanceToken.transfer(acc2 , ether('200'));
      let balanceBeforeee = await instanceToken.balanceOf(acc2);
      console.log("acc2 balance",balanceBeforeee.toString());
    });
  });  
  describe("Stake", async () => {
    it("Stake", async () => {
      let balanceBefore = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBefore.toString());
      await instanceToken.approve(instanceStaking.address , ether('100'));
      await instanceStaking.stake(ether('100'));
      let balanceBeforee = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBeforee.toString());
    });
    it("Stake", async () => {
      let balanceBefore = await instanceToken.balanceOf(acc2);
      console.log("acc2",balanceBefore.toString());
      await instanceToken.approve(instanceStaking.address , ether('200'),{from:acc2});
      await instanceStaking.stake(ether('200'),{from:acc2});
      let balanceBeforee = await instanceToken.balanceOf(acc2);
      console.log("acc2",balanceBeforee.toString());
    });
  });
  describe("UnStake", async () => {
    it("UnStake", async () => {
      // await instanceToken.approve(instanceStaking.address , new BN(5000));
      await time.increase(time.duration.days(130));
      let balanceContract = await instanceToken.balanceOf(instanceStaking.address);
      console.log("SC BALANCE" , balanceContract.toString())
      let balanceBefore = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBefore.toString());
      await instanceStaking.unStake();
      let balanceBeforee = await instanceToken.balanceOf(owner);
      console.log("owner balance",balanceBeforee.toString());
    });
    it("UnStake", async () => {
      // await instanceToken.approve(instanceStaking.address , new BN(5000));
      await time.increase(time.duration.days(235));
      let balanceContract = await instanceToken.balanceOf(instanceStaking.address);
      console.log("SC BALANCE" , balanceContract.toString())
      let balanceBefore = await instanceToken.balanceOf(acc2);
      console.log("acc2 balance",balanceBefore.toString());
      await instanceStaking.unStake({from:acc2});
      let balanceBeforee = await instanceToken.balanceOf(acc2);
      console.log("acc2 balance",balanceBeforee.toString());
      let balanceContractt = await instanceToken.balanceOf(instanceStaking.address);
      console.log("SC BALANCE" , balanceContractt.toString())
    });
  });
  // 100000000000315360000
  // 100000000000105120000
  // 100000000000052704000
  // 250000001585450831187
  // 333267032693125676168000

});