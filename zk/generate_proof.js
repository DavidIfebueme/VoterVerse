const snarkjs = require('snarkjs');
const fs = require('fs');

async function generateProof(input) {
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(input, 'zk/circuit.wasm', 'zk/circuit_final.zkey');
    fs.writeFileSync('zk/proof.json', JSON.stringify(proof));
    fs.writeFileSync('zk/public.json', JSON.stringify(publicSignals));
    console.log("Proof and public signals generated and saved.");
}

const input = JSON.parse(fs.readFileSync('zk/input.json'));
generateProof(input);
