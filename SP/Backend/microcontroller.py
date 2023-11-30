from app import app, mongo
from flask import jsonify, request

@app.route('/microPOST', methods=['POST'])
def microcontrollerPOST():
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



@app.route('/microGET', methods=['GET'])
def microcontrollerGET():
    # Query the MongoDB database for all sensor documents
    sensors_cursor = mongo.db.sensors.find({})

    # Initialize an empty dictionary to store sensor data
    sensor_values = {}

    # Use count_documents to check if any documents are found
    if mongo.db.sensors.count_documents({}) > 0:
        for sensor in sensors_cursor:
            # Add each sensor's data to the dictionary
            sensor_type = sensor.get('sensorType')
            sensor_value = sensor.get('sensorValue')
            sensor_values[sensor_type] = sensor_value
        
        # Return the sensor_values dictionary directly
        return jsonify(sensor_values), 200
    else:
        # Return an error message if no data is found
        return jsonify({"error": "No sensor data found"}), 404


# {
#     "airTemp":25,
#     "outerWaterTemp":50,
#     "innerWaterTemp":50,
#     "outerTankVolume":50,
#     "innerTankVolume":50,
#     "soilTankVolume":50,
#     "humidity":0
# }