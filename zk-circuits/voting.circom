pragma circom 2.1.9;

include "poseidon.circom";

template VotingCircuit() {
    // Public inputs
    signal input nullifierHash;
    signal input candidateChoice;
    
    // Private inputs
    signal private input privateKey;

    // Output the computed nullifier hash
    signal output computedNullifierHash;

    // Poseidon hash
    component hasher = Poseidon(1);
    hasher.inputs[0] <== privateKey;

    // Assign the hash output
    computedNullifierHash <== hasher.out;
    
    // Ensure the computed hash matches the provided nullifier hash
    nullifierHash === computedNullifierHash;
}

component main = VotingCircuit();
