// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MicroInvestmentPlatform is Ownable {
    IERC20 public token;  
    address public projectOwner;  

    struct SustainableProject {
        uint256 goalAmount;      
        uint256 currentAmount;   
        bool isActive;          
        mapping(address => uint256) investments; // Track individual investments
    }

    mapping(uint256 => SustainableProject) public projects;
    uint256 public projectCount;  

    event ProjectCreated(uint256 indexed projectId, uint256 goalAmount);
    event InvestmentMade(uint256 indexed projectId, address indexed investor, uint256 amount);
    event ProjectFunded(uint256 indexed projectId);
    event FundsWithdrawn(uint256 indexed projectId, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        projectOwner = msg.sender;
    }

    function createProject(uint256 _goalAmount) external onlyOwner {
        uint256 projectId = projectCount++;
        projects[projectId] = SustainableProject(_goalAmount, 0, true);
        emit ProjectCreated(projectId, _goalAmount);
    }

    function invest(uint256 _projectId, uint256 _amount) external {
        require(projects[_projectId].isActive, "Project is not active");
        require(_amount > 0, "Investment amount must be greater than 0");
        
        uint256 remainingAmount = projects[_projectId].goalAmount - projects[_projectId].currentAmount;
        uint256 actualInvestment = (_amount <= remainingAmount) ? _amount : remainingAmount;
        
        projects[_projectId].currentAmount += actualInvestment;
        projects[_projectId].investments[msg.sender] += actualInvestment;
        token.transferFrom(msg.sender, address(this), actualInvestment);
        
        emit InvestmentMade(_projectId, msg.sender, actualInvestment);

        if (projects[_projectId].currentAmount == projects[_projectId].goalAmount) {
            projects[_projectId].isActive = false;
            emit ProjectFunded(_projectId);
        }
    }

    function withdrawFunds(uint256 _projectId) external onlyOwner {
        require(!projects[_projectId].isActive, "Project is still active");
        uint256 amountToWithdraw = projects[_projectId].currentAmount;
        require(amountToWithdraw > 0, "No funds to withdraw");
        
        projects[_projectId].currentAmount = 0;
        token.transfer(projectOwner, amountToWithdraw);
        emit FundsWithdrawn(_projectId, amountToWithdraw);
    }

    // Function to check an individual's investment in a project
    function getInvestment(uint256 _projectId, address _investor) external view returns (uint256) {
        return projects[_projectId].investments[_investor];
    }
}
