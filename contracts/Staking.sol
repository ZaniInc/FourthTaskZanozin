//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IVesting.sol";

contract Staking {
    using SafeERC20 for IERC20;

    IERC20 public token;
    
    constructor(address token_){
         require(
            isContract(token_),
            "Error : Incorrect address , only contract address"
        );
        token = IERC20(token_);
    }
}
