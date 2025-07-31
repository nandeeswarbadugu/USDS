// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract USDSProxy {
    address public implementation;
    address public admin;

    event Upgraded(address indexed implementation);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "Zero address");
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
