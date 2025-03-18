// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Voting {
    IERC20 public token;
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 deadline;
        bool executed;
    }

    struct Voter {
        uint256 weight;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    //mapping(uint256=>mapping(address=>bool)) public voted;
    uint256 public proposalCount;
    uint256 public votingPeriod = 7 days;

    event ProposalCreated(
        uint256 proposalId,
        string description,
        uint256 deadline
    );
    event Voted(uint256 proposalId, address voter, uint256 weight);
    event ProposalExecuted(uint256 proposalId);

    constructor(address _token) {
        token = IERC20(_token);
    }
    modifier onlyTokenHolders() {
        require(token.balanceOf(msg.sender) > 0, "Not a token holder");
        _;
    }

    modifier onlyActiveProposals(uint256 _proposalId) {
        require(
            proposals[_proposalId].deadline > block.timestamp,
            "Voting period expired"
        );
        _;
    }

    modifier onlyNonVoters(uint256 _proposalId) {
        require(
            !hasVoted[msg.sender][_proposalId],
            "Already voted on this proposal"
        );
    }

    function createProposal(
        string memory _description
    ) external onylTokenHolders {
        proposalCount++;
        proposals[proposalCount] = Proposal(
            proposalCount,
            _description,
            0,
            block.timestamp + votingPeriod,
            false
        );

        emit ProposalCreated(
            proposalCount,
            _description,
            block.timestamp + votingPeriod
        );
    }
    function voteOnProposal(
        uint256 _proposalId
    )
        external
        onlyTokenHolders
        onlyActiveProposals(_proposalId)
        onlyNonVoters(_proposalId)
    {
        uint256 votePower = token.balanceOf(msg.sender);
        voters[msg.sender].weight = votePower;

        hasVoted[msg.sender][_proposalId] = true;
        proposals[_proposalId].voteCount += votePower;

        emit Voted(_proposalId, msg.sender, votePower);
    }
}
