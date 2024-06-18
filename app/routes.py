from flask import Blueprint, render_template, request, redirect, url_for
#from web3 import Web3
import json
import os
import subprocess

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/create_election', methods=['POST'])
def create_election():
    university_id = int(request.form['university_id'])
    tx_hash = contract.functions.createElection(university_id).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/end_election', methods=['POST'])
def end_election():
    university_id = int(request.form['university_id'])
    election_id = int(request.form['election_id'])
    tx_hash = contract.functions.endElection(university_id, election_id).transact({'from': w3.eth.accounts[0]})
    w3.eth.wait_for_transaction_receipt(tx_hash)
    return redirect(url_for('main.index'))

@main.route('/register_voter', methods=['GET'])
def register_voter():
    return render_template('register.html')

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

@main.route('/cast_vote', methods=['GET', 'POST'])
def cast_vote():
    return render_template('vote.html')

@main.route('/results', methods=['GET'])
def results():
    return render_template('results.html')