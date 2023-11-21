from app import app
from flask import jsonify
import random  

@app.route('/random', methods=['GET'])

def random_number():
    # Generate a random number, for example between 1 and 100
    random_number = random.randint(1, 100)

    data = {
        "number": random_number,
    }

    return jsonify(data)
