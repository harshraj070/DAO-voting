// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable{

    IERC20 public token;
    struct Proposal{
        uint256 id;
        string description;
        uint256 deadline;
        uint256 voteCount;
        bool executed;
    }
    struct voter{
        uint256 votePower;
    }

     constructor(address _token) Ownable(msg.sender){
        token = IERC20(_token);
    }

    uint256 public proposalCount;
    uint256 public votingPeriod = 7 days;
    uint256 public quorum = 1000;

    mapping(uint256=>Proposal) public proposals;
    mapping(address=>voter) public voters;
    mapping(address=>mapping(uint256=>bool)) public hasVoted;

    modifier onlyTokenHolder(){
        require(token.balanceOf(msg.sender)>0,"you dont have the token");
        _;
    }
    modifier withinDeadline(uint256 _proposalId){
        require(proposals[_proposalId].deadline > block.timestamp,"Deadline finished");
        _;
    }

    modifier hasAlreadyVoted(uint256 _proposalId){
        require(!hasVoted[msg.sender][_proposalId],"already voted for this proposal");
        _;
    }

   

    function createProposal(string _description){
        proposalCount+=1;
        proposals[proposalCount] = Proposal(
            proposalCount,
            _description,
            block.timestamp + votingPeriod,
            0,
            false
        );
    }
 
    function vote(uint256 _proposalId) external onlyTokenHolder() withinDeadline(_proposalId) (uint256 _proposalId){
        uint256 votePower = token.balanceOf(msg.sender);
        voters[msg.sender].weight = votePower;

        hasVoted[msg.sender][_proposalId] = true;

        proposals[_proposalId].voteCount += votePower;

    }

    function executeProposal(uint256 _proposalId) external{
        Proposal storage proposal = proposals[_proposalId];

        require(proposal.deadline <= block.timestamp, "Voting period still active");
        require(!proposal.executed,"Proposal already executed");
        require(proposal.voteCount >= quorum,"Quorum not met");

        proposal.executed = true;
    }

    function setQuoram(uint256 _newQuorum) external onlyOwner{
        require(_newQuorum>0,"cant be zero");
        quorum = _newQuorum;
    }

    function getProposal(uint256 _proposalId) external view returns(
        string memory description,
        uint256 votreCount,
        bool executed,
        uint256 deadline
    )
    {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.voteCount,
            proposal.executed,
            proposal.deadline
        );
    }

    function getVoter(address _voter) 
        external 
        view 
        returns (
            uint256 weight
        ) 
    {
        Voter memory voter = voters[_voter];
        return (
            voter.weight
        );
    }
    
    function hasVotedForProposal(address _voter, uint256 _proposalId) 
        external 
        view 
        returns (bool) 
    {
        return hasVoted[_voter][_proposalId];
    }
}
