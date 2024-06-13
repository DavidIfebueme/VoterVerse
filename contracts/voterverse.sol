// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoterVerse{
    struct Candidate{
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter{
        bool authorized;
        bool voted;
        uint256 vote;
    }

    address public owner;
    string public electionName;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    uint256 public totalVotes;

    modifier ownerOnly(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor(string memory _name){
        owner= msg.sender;
        electionName = _name;
    }

    function addCandidates(string memeory name) ownerOnly public {
        candidates.push(Candidate(candidates.length, name, 0));
    }

    function authorize(address person) ownerOnly public{
        voters[person].authorized = true;
    }

    function vote(uint candidateID) public{
        require(!voters[msg.sender].voted, "You have already voted");
        require(voter[msg.sender].authorized, "You are not eligible to vote");

        voters[msg.sender].vote = candidateID;
        voters[msg.sender].voted = true;

        candidates[candidateID].voteCount += 1;
        totalVotes += 1;

    }

    function end() ownerOnly public {
        selfdestruct(payable(owner));
    }
}