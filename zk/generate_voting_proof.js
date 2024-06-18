const { groth16 } = require("snarkjs");
const fs = require("fs");
const path = require("path");

async function generateVotingProof(privateKey, candidateChoice) {
    const wasmPath = path.join(__dirname, "voting.wasm");
    const zkeyPath = path.join(__dirname, "voting_final.zkey");

    const input = {
        privateKey: privateKey,
        candidateChoice: candidateChoice
    };

    const { proof, publicSignals } = await groth16.fullProve(input, wasmPath, zkeyPath);

    return { proof, publicSignals };
}

// testing
const privateKey = 12345n; 
const candidateChoice = 1; 
generateVotingProof(privateKey, candidateChoice)
    .then(({ proof, publicSignals }) => {
        console.log("Voting Proof:", proof);
        console.log("Public signals:", publicSignals); 
    })
    .catch(console.error);
