// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GreenSustainYieldBond is Ownable {
    string public name = "GreenSustain Yield Bond";
    string public symbol = "GSYB";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public bondBalance;

    IERC20 public paymentToken; // The ERC20 token used for investments

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BondIssued(address indexed investor, uint256 value);
    event BondTransferred(address indexed from, address indexed to, uint256 value);

    constructor(address _paymentTokenAddress) {
        paymentToken = IERC20(_paymentTokenAddress);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Invalid sender address");
        require(_to != address(0), "Invalid recipient address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function issueBond(uint256 _amount) public {
        require(_amount > 0, "Invalid bond amount");
        require(paymentToken.transferFrom(msg.sender, address(this), _amount), "Bond issuance failed");
        
        bondBalance[msg.sender] += _amount;
        totalSupply += _amount;
        emit BondIssued(msg.sender, _amount);
    }

    function transferBond(address _to, uint256 _amount) public {
        require(_to != address(0), "Invalid recipient address");
        require(bondBalance[msg.sender] >= _amount, "Insufficient bond balance");
        
        bondBalance[msg.sender] -= _amount;
        bondBalance[_to] += _amount;
        emit BondTransferred(msg.sender, _to, _amount);
    }
}
