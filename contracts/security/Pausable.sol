// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/Ownable.sol";
// import { Ownable } from "../access/Ownable.sol";

abstract contract Pausable is Ownable {
    bool public paused;

    event Pause();
    event Unpause();

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Not paused");
        _;
    }

    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}
