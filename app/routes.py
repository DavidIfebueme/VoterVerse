from flask import Blueprint, render_template, request, redirect, url_for
from web3 import Web3
import json
import os
import subprocess

main = Blueprint('main', __name__)

# Configure Web3
w3 = Web3(Web3.HTTPProvider(os.getenv('WEB3_PROVIDER')))
with open('contracts/VoterVerse.json') as f:
    contract_data = json.load(f)
contract_address = Web3.toChecksumAddress(os.getenv('CONTRACT_ADDRESS'))
contract = w3.eth.contract(address=contract_address, abi=contract_data['abi'])

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/create_election', methods=['POST'])
def create_election():
    university_id = int(request.form['university_id'])
    tx_hash = contract.functions.createElection(university_id).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/start_voting', methods=['POST'])
def start_voting():
    university_id = int(request.form['university_id'])
    election_id = int(request.form['election_id'])
    tx_hash = contract.functions.startVoting(university_id, election_id).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/end_election', methods=['POST'])
def end_election():
    university_id = int(request.form['university_id'])
    election_id = int(request.form['election_id'])
    tx_hash = contract.functions.endElection(university_id, election_id).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/register_voter', methods=['POST'])
def register_voter():
    university_id = int(request.form['university_id'])
    election_id = int(request.form['election_id'])
    voter_address = request.form['voter_address']
    nullifier_hash = int(request.form['nullifier_hash'])
    tx_hash = contract.functions.registerVoter(university_id, election_id, voter_address, nullifier_hash).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/generate_proof', methods=['POST'])
def generate_proof():
    input_data = {
        "nullifierHash": request.form['nullifier_hash']
    }
    with open('zk/input.json', 'w') as f:
        json.dump(input_data, f)

    subprocess.run(['node', 'zk/generate_proof.js'])

    with open('zk/proof.json') as f:
        proof = json.load(f)
    with open('zk/public.json') as f:
        public_signals = json.load(f)

    return {
        'proof': proof,
        'public_signals': public_signals
    }

@main.route('/cast_vote', methods=['POST'])
def cast_vote():
    university_id = int(request.form['university_id'])
    election_id = int(request.form['election_id'])
    nullifier_hash = int(request.form['nullifier_hash'])
    proof = json.loads(request.form['proof'])
    tx_hash = contract.functions.castVote(university_id, election_id, nullifier_hash, proof).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))
