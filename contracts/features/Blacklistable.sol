// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/Ownable.sol";
// import {}

abstract contract Blacklistable is Ownable {
    mapping(address => bool) public isBlackListed;

    event DestroyedBlackFunds(address indexed user, uint balance);
    event AddedBlackList(address indexed user);
    event RemovedBlackList(address indexed user);

    function addBlackList(address user) external onlyOwner {
        isBlackListed[user] = true;
        emit AddedBlackList(user);
    }

    function removeBlackList(address user) external onlyOwner {
        isBlackListed[user] = false;
        emit RemovedBlackList(user);
    }

    function _destroyBlackFunds(address user, mapping(address => uint) storage balances, uint256 totalSupply_) internal returns (uint256) {
        require(isBlackListed[user], "User not blacklisted");
        uint dirtyFunds = balances[user];
        balances[user] = 0;
        emit DestroyedBlackFunds(user, dirtyFunds);
        return totalSupply_ - dirtyFunds;
    }
}
