from app import app, mongo
from flask import jsonify, request

@app.route('/microPOST', methods=['POST'])
def microcontrollerPOST():
    req = request.json
    collection = mongo.db.sensors

    # Prepare the update data with the correct key transformation and path
    nested_sensor_data = {"sensor_data." + key.lower().replace("tank", "_tank").replace("water", "_water").replace("temp", "_temp").replace("volume", "_volume"): value for key, value in req.items()}
    # Update the document with the nested structure
    collection.update_one({"_id": "sensor_states"}, {"$set": nested_sensor_data}, upsert=True)

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



