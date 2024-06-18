// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegistrationVerifier.sol";
import "./VotingVerifier.sol";

contract VoterVerse {
    struct Candidate {
        uint256 candidateID;
        string name;
    }

    struct Election {
        uint256 universityID;
        uint256 electionID;
        bool isVotingOpen;
        mapping(uint256 => Candidate) candidates;
        uint256 candidateCount;
        mapping(address => bool) hasVoted;
        mapping(bytes32 => bool) registeredVoters;
    }

    RegistrationVerifier public registrationVerifier;
    VotingVerifier public votingVerifier;
    mapping(uint256 => mapping(uint256 => Election)) public elections;
    mapping(uint256 => bool) public universities;

    event UniversityAdded(uint256 universityID);
    event ElectionCreated(uint256 universityID, uint256 electionID);
    event CandidateAdded(uint256 universityID, uint256 electionID, uint256 candidateID, string name);
    event VotingStarted(uint256 universityID, uint256 electionID);
    event VotingEnded(uint256 universityID, uint256 electionID);
    event VoterRegistered(uint256 universityID, uint256 electionID, bytes32 nullifierHash);
    event VoteCast(uint256 universityID, uint256 electionID, bytes32 nullifierHash, uint256 candidateID);

    constructor(address _registrationVerifier, address _votingVerifier) {
        registrationVerifier = RegistrationVerifier(_registrationVerifier);
        votingVerifier = VotingVerifier(_votingVerifier);
    }

    modifier onlyUniversity(uint256 universityID) {
        require(universities[universityID], "University not registered");
        _;
    }

    function addUniversity(uint256 universityID) external {
        universities[universityID] = true;
        emit UniversityAdded(universityID);
    }

    function createElection(uint256 universityID, uint256 electionID) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID == 0, "Election already exists");
        election.universityID = universityID;
        election.electionID = electionID;
        emit ElectionCreated(universityID, electionID);
    }

    function addCandidate(uint256 universityID, uint256 electionID, uint256 candidateID, string memory name) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID != 0, "Election does not exist");
        require(bytes(name).length > 0, "Candidate name cannot be empty");

        election.candidates[candidateID] = Candidate(candidateID, name);
        election.candidateCount++;
        emit CandidateAdded(universityID, electionID, candidateID, name);
    }

    function startVoting(uint256 universityID, uint256 electionID) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID != 0, "Election does not exist");
        require(!election.isVotingOpen, "Voting already started");
        election.isVotingOpen = true;
        emit VotingStarted(universityID, electionID);
    }

    function endVoting(uint256 universityID, uint256 electionID) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID != 0, "Election does not exist");
        require(election.isVotingOpen, "Voting not started yet");
        election.isVotingOpen = false;
        emit VotingEnded(universityID, electionID);
    }

    function registerVoter(
        uint256 universityID,
        uint256 electionID,
        bytes32 nullifierHash,
        uint256[8] calldata proof
    ) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID != 0, "Election does not exist");
        require(!election.registeredVoters[nullifierHash], "Voter already registered");

        bool isValidProof = registrationVerifier.verifyProof(
            [proof[0], proof[1]],
            [[proof[2], proof[3]], [proof[4], proof[5]]],
            [proof[6], proof[7]],
            [uint256(nullifierHash)]
        );

        require(isValidProof, "Invalid registration proof");

        election.registeredVoters[nullifierHash] = true;
        emit VoterRegistered(universityID, electionID, nullifierHash);
    }

    function castVote(
        uint256 universityID,
        uint256 electionID,
        uint256 candidateID,
        bytes32 nullifierHash,
        uint256[8] calldata proof
    ) external onlyUniversity(universityID) {
        Election storage election = elections[universityID][electionID];
        require(election.universityID != 0, "Election does not exist");
        require(election.isVotingOpen, "Voting is not open");
        require(!election.hasVoted[msg.sender], "You have already voted");
        require(election.candidates[candidateID].candidateID != 0, "Invalid candidate");

        bool isValidProof = votingVerifier.verifyProof(
            [proof[0], proof[1]],
            [[proof[2], proof[3]], [proof[4], proof[5]]],
            [proof[6], proof[7]],
            [uint256(nullifierHash), candidateID]
        );

        require(isValidProof, "Invalid vote proof");

        require(election.registeredVoters[nullifierHash], "Voter not registered");

        election.hasVoted[msg.sender] = true;
        emit VoteCast(universityID, electionID, nullifierHash, candidateID);
    }
}
