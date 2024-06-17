// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoterVerse {
    enum ElectionPhase { NotStarted, Registration, Voting, Ended }

    struct Voter {
        bool registered;
        bool voted;
        uint256 nullifierHash;
    }

    struct Election {
        ElectionPhase phase;
        uint256 totalVotes;
        mapping(address => Voter) voters;
    }

    struct University {
        bool exists;
        mapping(uint256 => Election) elections;
        uint256 electionCount;
    }

    mapping(uint256 => University) public universities;

    event ElectionCreated(uint256 universityId, uint256 electionId);
    event UniversityAdded(uint256 universityId);
    event VoterRegistered(uint256 universityId, uint256 electionId, address voter);
    event VoteCast(uint256 universityId, uint256 electionId, uint256 nullifierHash);

    function addUniversity(uint256 universityId) external {
        require(!universities[universityId].exists, "University already exists");
        universities[universityId].exists = true;
        emit UniversityAdded(universityId);
    }

    function createElection(uint256 universityId) external {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        uint256 electionId = university.electionCount;
        university.elections[electionId].phase = ElectionPhase.Registration;
        university.electionCount++;
        emit ElectionCreated(universityId, electionId);
    }

    function startVoting(uint256 universityId, uint256 electionId) external {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        require(university.elections[electionId].phase == ElectionPhase.Registration, "Registration phase must be active to start voting");
        university.elections[electionId].phase = ElectionPhase.Voting;
    }

    function endElection(uint256 universityId, uint256 electionId) external {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        require(university.elections[electionId].phase == ElectionPhase.Voting, "Voting phase must be active to end election");
        university.elections[electionId].phase = ElectionPhase.Ended;
    }

    function registerVoter(uint256 universityId, uint256 electionId, address _voter, uint256 _nullifierHash) external {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        Election storage election = university.elections[electionId];
        require(election.phase == ElectionPhase.Registration, "Registration phase is not active");
        require(!election.voters[_voter].registered, "Voter already registered");
        election.voters[_voter] = Voter(true, false, _nullifierHash);
        emit VoterRegistered(universityId, electionId, _voter);
    }

    function castVote(uint256 universityId, uint256 electionId, uint256 _nullifierHash) external {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        Election storage election = university.elections[electionId];
        Voter storage voter = election.voters[msg.sender];
        require(election.phase == ElectionPhase.Voting, "Voting phase is not active");
        require(voter.registered, "Voter not registered");
        require(!voter.voted, "Voter has already voted");
        require(voter.nullifierHash == _nullifierHash, "Invalid nullifier hash");

        voter.voted = true;
        election.totalVotes += 1;
        emit VoteCast(universityId, electionId, _nullifierHash);
    }

    function hasVoted(uint256 universityId, uint256 electionId, address _voter) external view returns (bool) {
        require(universities[universityId].exists, "University does not exist");
        University storage university = universities[universityId];
        Election storage election = university.elections[electionId];
        return election.voters[_voter].voted;
    }
}