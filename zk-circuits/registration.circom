pragma circom 2.1.9;

include "circomlib/poseidon.circom";

template RegistrationCircuit() {
    // Private inputs
    signal private input privateKey;

    // Output the nullifier hash
    signal output nullifierHash;

    // Poseidon hash
    component hasher = Poseidon(1);
    hasher.inputs[0] <== privateKey;

    // Assign the hash output
    nullifierHash <== hasher.out;
}

component main = RegistrationCircuit();
