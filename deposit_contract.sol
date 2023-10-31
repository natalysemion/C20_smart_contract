// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositContract {
    address public owner;
    uint256 public depositAmount;
    uint256 public depositEndTime;
    bool public isDeposited;

    event DepositMade(address indexed user, uint256 amount, uint256 endTime);
    event DepositWithdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyAfter(uint256 _time) {
        require(block.timestamp >= _time, "Action can only be performed after a certain time.");
        _;
    }

    function makeDeposit(uint256 _durationInDays) external payable {
        require(!isDeposited, "A deposit has already been made.");
        require(msg.value > 0, "Deposit amount should be greater than zero.");

        depositAmount = msg.value;
        depositEndTime = block.timestamp + (_durationInDays * 1 days);
        isDeposited = true;

        emit DepositMade(msg.sender, msg.value, depositEndTime);
    }

    function withdrawDeposit() external onlyOwner onlyAfter(depositEndTime) {
        require(isDeposited, "No deposit has been made.");
        
        uint256 amountToWithdraw = depositAmount;
        depositAmount = 0;
        isDeposited = false;

        payable(msg.sender).transfer(amountToWithdraw);

        emit DepositWithdrawn(msg.sender, amountToWithdraw);
    }

    function checkDepositStatus() external view returns (bool, uint256, uint256) {
        return (isDeposited, depositAmount, depositEndTime);
    }
}
