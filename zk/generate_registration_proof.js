import { groth16 } from "snarkjs";
import { ethers } from "ethers";

// Function to generate proof
async function generateRegistrationProof(signedMessageHash) {
    const wasmPath = "registration.wasm";  // Path to the wasm file
    const zkeyPath = "registration_final.zkey";  // Path to the zkey file

    const input = {
        signedMessageHash: signedMessageHash
    };

    const { proof, publicSignals } = await groth16.fullProve(input, wasmPath, zkeyPath);

    return { proof, publicSignals };
}

// Function to handle user registration
async function handleRegistration() {
    const universityId = document.getElementById("universityId").value;
    const electionId = document.getElementById("electionId").value;
    
    // Connect to the user's wallet using ethers.js
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const userAddress = await signer.getAddress();

    // Create a unique message with nonce (timestamp)
    const nonce = Date.now();
    const message = `I am registering to vote at ${nonce}`;
    const signedMessage = await signer.signMessage(message);

    // Convert the signed message to a format suitable for circom
    const signedMessageHash = ethers.utils.keccak256(signedMessage);

    // Generate zk-SNARK proof
    const { proof, publicSignals } = await generateRegistrationProof(signedMessageHash);

    console.log("Registration Proof:", proof);
    console.log("Public signals (nullifier hash):", publicSignals[0]); // This will be the nullifier hash

    // Convert proof to the format required by the smart contract
    const proofArray = [
        proof.pi_a[0], proof.pi_a[1],
        proof.pi_b[0][0], proof.pi_b[0][1],
        proof.pi_b[1][0], proof.pi_b[1][1],
        proof.pi_c[0], proof.pi_c[1]
    ];

    // Submit the proof and nullifier hash to the blockchain
    const contractAddress = "0x34690B1B9a3bfb38c785c36Fd08936878273343e"; 
    const abi = [/* YOUR_ABI_HERE */];  // Replace with your contract's ABI
    const contract = new ethers.Contract(contractAddress, abi, signer);
    await contract.registerVoter(universityId, electionId, userAddress, publicSignals[0], proofArray);
}

// Add event listener to the registration button
document.getElementById("registerButton").addEventListener("click", handleRegistration);
