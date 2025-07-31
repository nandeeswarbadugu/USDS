// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";
// import { IERC20 } from "./interfaces/IERC20.sol";
import "./access/Ownable.sol";
import "./security/Pausable.sol";
import "./features/Blacklistable.sol";

contract USDSV1 is IERC20, Ownable, Pausable, Blacklistable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public override totalSupply;

    bool public deprecated;
    address public upgradedAddress;

    uint public basisPointsRate = 0;
    uint public maximumFee = 0;
    bool private initialized;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;

    event Issue(uint amount);
    event Redeem(uint amount);
    event Deprecate(address newAddress);
    event Params(uint feeBasisPoints, uint maxFee);

    modifier onlyOnce() {
        require(!initialized, "Already initialized");
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _initialSupply
    ) external onlyOnce {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
        owner = msg.sender;
        initialized = true;
    }

    function transfer(address to, uint amount) external override whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "Sender blacklisted");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external override whenNotPaused returns (bool) {
        require(!isBlackListed[from], "Sender blacklisted");
        uint currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "Allowance exceeded");
        allowances[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint amount) internal {
        require(to != address(0), "Invalid to");
        require(balances[from] >= amount, "Insufficient balance");

        uint fee = (amount * basisPointsRate) / 10000;
        if (fee > maximumFee) {
            fee = maximumFee;
        }

        uint sendAmount = amount - fee;

        balances[from] -= amount;
        balances[to] += sendAmount;
        emit Transfer(from, to, sendAmount);

        if (fee > 0) {
            balances[owner] += fee;
            emit Transfer(from, owner, fee);
        }
    }

    function balanceOf(address account) public view override returns (uint) {
        return balances[account];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address account, address spender) external view override returns (uint) {
        return allowances[account][spender];
    }

    function issue(uint amount) external onlyOwner {
        balances[owner] += amount;
        totalSupply += amount;
        emit Issue(amount);
        emit Transfer(address(0), owner, amount);
    }

    function redeem(uint amount) external onlyOwner {
        require(balances[owner] >= amount, "Insufficient");
        balances[owner] -= amount;
        totalSupply -= amount;
        emit Redeem(amount);
        emit Transfer(owner, address(0), amount);
    }

    function destroyBlackFunds(address user) external onlyOwner {
        totalSupply = _destroyBlackFunds(user, balances, totalSupply);
    }

    function setParams(uint newBasisPoints, uint newMaxFee) external onlyOwner {
        require(newBasisPoints < 20, "Max 0.2%");
        require(newMaxFee < 50, "Max fee too high");
        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee * 10 ** decimals;
        emit Params(basisPointsRate, maximumFee);
    }

    function deprecate(address newAddress) external onlyOwner {
        deprecated = true;
        upgradedAddress = newAddress;
        emit Deprecate(newAddress);
    }
}
