
from app import app, mongo
from flask import jsonify, request

@app.route('/GET', methods=['GET'])
def GET():
    collection = mongo.db.pins
    all_pins = collection.find({})
    transformed_data = {}
    for document in all_pins:
        for key, value in document.items():
            if key != '_id':
                transformed_data[key] = value
    return jsonify(transformed_data), 200

@app.route('/POST', methods=['POST'])
def POST():
    req = request.json

    for sensor_type, sensor_value in req.items():
        existing_document = mongo.db.sensors.find_one({"sensorType": sensor_type})
        if existing_document:
            mongo.db.sensors.update_one({"_id": existing_document["_id"]}, {"$set": {"sensorValue": sensor_value}})
            message = f"{sensor_type} updated successfully!"
        else:
            mongo.db.sensors.insert_one({"sensorType": sensor_type, "sensorValue": sensor_value})
            message = f"{sensor_type} added successfully!"
        print(f"Processed {sensor_type}: {sensor_value}")
    return jsonify({"message": "All sensors processed successfully"}), 200