pragma circom 2.1.9;

include "poseidon.circom";

template RegistrationCircuit() {
    // Private inputs
    signal input signedMessage;

    // Output the nullifier hash
    signal output nullifierHash;

    // Poseidon hash
    component hasher = Poseidon(1);
    hasher.inputs[0] <== signedMessage;

    // Assign the hash output
    nullifierHash <== hasher.out;
}

component main = RegistrationCircuit();

