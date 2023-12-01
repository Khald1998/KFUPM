from app import app, mongo
from flask import jsonify, request


@app.route('/pinsPOST', methods=['POST'])
def pinsPOST():
    data = request.json
    collection = mongo.db.pins

    update_data = {"pins." + pin: value for pin, value in data.items()}
    collection.update_one({"_id": "pin_states"}, {"$set": update_data}, upsert=True)

    return jsonify({"message": "Data updated successfully"}), 200

@app.route('/pinsGET', methods=['GET'])
def pinsGET():
    collection = mongo.db.pins

    pin_states_doc = collection.find_one({"_id": "pin_states"})
    if pin_states_doc:
        pin_states = pin_states_doc.get("pins", {})
    else:
        pin_states = {}

    return jsonify(pin_states), 200
