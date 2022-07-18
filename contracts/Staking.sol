//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IStaking.sol";

contract Staking is Ownable {
    using SafeERC20 for IERC20;

    struct Investor {
        uint256 startDate;
        uint256 finishDate;
        uint256 stakingAmount;
        uint256 userRewardPerTokens; // равняется rewardPerTokensTotal
        uint256 rewardPaid;
    }
    struct StakingParams {
        uint256 stakingStartDate;
        uint256 stakingPeriod;
        uint256 feePercent;
        uint256 cooldownPeriod;
    }

    mapping(address => Investor) public investorList;
    StakingParams public stakingParams;
    uint256 public constant MAX_STAKING_POOL = 5000000 ether;
    uint256 public lastTimeUpdate; // last time when someone call staking or unstaking
    uint256 public apr; //minting tokens per 1 second
    uint256 public constant MAX_REWARD = 500_000 ether;
    uint256 public rewardPerTokenStored;
    uint256 public stakingTotalAmount;
    uint256 public maxStakingCap;

    IERC20 public token;

    constructor(address token_) {
        require(
            Address.isContract(token_),
            "Error : Incorrect address , only contract address"
        );
        token = IERC20(token_);
        stakingParams.stakingPeriod = 365 days;
        stakingParams.feePercent = 40;
        stakingParams.cooldownPeriod = 10 days;
    }

    function  updateReward(address caller) internal {
        rewardPerTokenStored = rewardPerToken();
        lastTimeUpdate = block.timestamp;
        investorList[caller].rewardPaid = earned(caller);
        investorList[caller].userRewardPerTokens = rewardPerTokenStored;
    }

    function setRewards(
        uint256 start_,
        uint256 rewardsAmount_,
        uint256 apr_
    ) external onlyOwner {
        require(rewardsAmount_ <= MAX_REWARD, "1");
        require(start_ >= block.timestamp, "12");
        // require(finish_ > start_,"13");
        require(rewardsAmount_ > 0 && start_ > 0 && apr_ > 0, "31");
        stakingParams.stakingStartDate = start_;
        apr = apr_;
        maxStakingCap = rewardsAmount_ * 100 ether / apr;
        token.safeTransferFrom(msg.sender, address(this), rewardsAmount_);
    }

    function stake(uint256 amount_) external {
        updateReward(msg.sender);
        investorList[msg.sender].stakingAmount += amount_;
        stakingTotalAmount += amount_;
        investorList[msg.sender].startDate = block.timestamp;
        token.safeTransferFrom(msg.sender, address(this), amount_);
        // rewardPerTokensTotal += amount_;
    }

    function unStake() external {
        updateReward(msg.sender);
        uint256 amount = investorList[msg.sender].stakingAmount + investorList[msg.sender].rewardPaid;
        stakingTotalAmount -= investorList[msg.sender].stakingAmount;
        investorList[msg.sender].startDate = 0;
        investorList[msg.sender].finishDate = block.timestamp;
        investorList[msg.sender].stakingAmount = 0;
        investorList[msg.sender].rewardPaid = 0;
        token.safeTransfer(msg.sender, amount);
    }

    function rewardPerToken() internal returns (uint256) {
        uint256 rr = ((stakingTotalAmount * apr) / 100 ether) / 365 days ;
        if (stakingTotalAmount == 0) {
            return 0;
        }
        else {
             // return rewardPerTokenStored + ((((block.timestamp - lastTimeUpdate)) * rr));
            return rewardPerTokenStored + ((rr * (block.timestamp - lastTimeUpdate) * 1e18)) / stakingTotalAmount;
        }
    }

    // сколько токенов уже заработал юзер
    function earned(address caller) internal returns (uint256) {
        uint256 total = (investorList[caller].stakingAmount * (rewardPerToken() - investorList[caller].userRewardPerTokens)) / 1e18;
        return total;
    }
}