# from flask import render_template
# from . import db
# from flask import current_app as app
from flask import Blueprint, render_template

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/register', methods=['POST'])
def register():
    pass

@main.route('/results', methods=['POST'])
def results():
    pass

@main.route('/profile', methods=['POST'])
def profile():
    pass

@main.route('/generate_proof', methods=['POST'])
def generate_proof_route():
    data = request.get_json()
    vote = data['vote']
    nullifier = data['nullifier']

    proof_data = generate_proof(vote, nullifier)
    if proof_data is None or '':
        return jsonify({'error': 'proof generation failed'}), 500

    return jsonify(proof_data)


# script to call nodejs script that generates the proof and 
# then passes proof to flask for submition with vote to blockchain
def generate_proof(vote, nullifier):
    input_data = {
        'vote': vote,
        'nullifier': nullifier
    }

    with open("app/zk/input.json", "w") as f:
        json.dump(input_data, f)

    result = subprocess.run(["node", "app/zk/generate_proof.js"], capture_output=True, text=True)

    if result.returncode != 0:
        print("Error generating proof", result.stderr)
        return None

    with open("app/zk/proof.json", "r") as f:
        proof_data = json.load(f)

    return proof_data    




