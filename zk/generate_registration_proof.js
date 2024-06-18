const { groth16 } = require("snarkjs");
const fs = require("fs");
const path = require("path");

async function generateRegistrationProof(privateKey) {
    const wasmPath = path.join(__dirname, "registration.wasm");
    const zkeyPath = path.join(__dirname, "registration_final.zkey");

    const input = {
        privateKey: privateKey
    };

    const { proof, publicSignals } = await groth16.fullProve(input, wasmPath, zkeyPath);

    return { proof, publicSignals };
}

// testing
const privateKey = 12345n; 
generateRegistrationProof(privateKey)
    .then(({ proof, publicSignals }) => {
        console.log("Registration Proof:", proof);
        console.log("Public signals (nullifier hash):", publicSignals[0]); 
    })
    .catch(console.error);
