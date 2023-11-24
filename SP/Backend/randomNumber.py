from app import app
from flask import jsonify
import random  

@app.route('/random', methods=['GET'])

def random_number():
    random_number_one = random.randint(0, 1)
    random_number_two = random.randint(0, 1)
    random_number_three = random.randint(0, 1)

    data = {
        "number_one": random_number_one,
        "number_two": random_number_two,
        "number_three": random_number_three,
    }

    return jsonify(data)
