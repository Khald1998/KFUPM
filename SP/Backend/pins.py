from app import app, mongo
from flask import jsonify, request
from flask_socketio import SocketIO

socketio = SocketIO(app)

@app.route('/pinsPOST', methods=['POST'])
def pinsPOST():
    data = request.json
    collection = mongo.db.pins
    for pin, value in data.items():
        query = {pin: {"$exists": True}}  
        new_data = {pin: value}  
        print(f"pin: {pin} \nquery: {query} \nnew_data: {new_data} \nif?: {collection.find_one(query)}")
        if collection.find_one(query):
            collection.update_one(query, {"$set": new_data})
        else:
            collection.insert_one(new_data)
    return jsonify({"message": "Data updated successfully"}), 200


@app.route('/pinsGET', methods=['GET'])
def pinsGET():
    collection = mongo.db.pins
    all_pins = collection.find({})
    transformed_data = {}
    for document in all_pins:
        for key, value in document.items():
            if key != '_id':
                transformed_data[key] = value
    return jsonify(transformed_data), 200



