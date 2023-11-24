from app import app, mongo
from flask import jsonify, request

@app.route('/pinsGET', methods=['GET'])
def pinsGET():
    collection = mongo.db.pins

    # Fetch all documents from the collection
    pins = collection.find({})

    # Convert the documents into a list of dictionaries
    pins_data = [{"pin": pin["pin"], "value": pin["value"]} for pin in pins]

    # Return the data as JSON
    return jsonify(pins_data)
