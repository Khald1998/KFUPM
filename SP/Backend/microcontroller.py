from app import app, mongo
from flask import jsonify, request

@app.route('/microPOST', methods=['POST'])
def microcontrollerPOST():
    req = request.json
    collection = mongo.db.sensors

    update_data = {"sensors." + sensor_type: sensor_value for sensor_type, sensor_value in req.items()}
    collection.update_one({"_id": "sensor_states"}, {"$set": update_data}, upsert=True)

    print("Processed sensors:", req)
    return jsonify({"message": "All sensors processed successfully"}), 200




@app.route('/microGET', methods=['GET'])
def microcontrollerGET():
    collection = mongo.db.sensors

    sensor_states_doc = collection.find_one({"_id": "sensor_states"})
    if sensor_states_doc:
        sensor_states = sensor_states_doc.get("sensors", {})
    else:
        sensor_states = {}

    return jsonify(sensor_states), 200



