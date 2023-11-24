from app import app, mongo
from flask import jsonify

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
        
        return jsonify({"sensors": sensor_values}), 200
    else:
        # Return an error message if no data is found
        return jsonify({"error": "No sensor data found"}), 404
