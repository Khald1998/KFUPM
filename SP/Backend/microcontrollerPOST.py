from app import app, mongo
from flask import jsonify, request

@app.route('/microPOST', methods=['POST'])
def microcontrollerPOST():
    req = request.json

    for sensor_type, sensor_value in req.items():
        # Find the document for the current sensor type
        existing_document = mongo.db.sensors.find_one({"sensorType": sensor_type})

        if existing_document:
            # Update the document if it exists
            mongo.db.sensors.update_one({"_id": existing_document["_id"]}, {"$set": {"sensorValue": sensor_value}})
            message = f"{sensor_type} updated successfully!"
        else:
            # Create a new document if it doesn't exist
            mongo.db.sensors.insert_one({"sensorType": sensor_type, "sensorValue": sensor_value})
            message = f"{sensor_type} added successfully!"

        print(f"Processed {sensor_type}: {sensor_value}")

    return jsonify({"message": "All sensors processed successfully"}), 200

# {
#     "airTemp":25,
#     "outerWaterTemp":50,
#     "innerWaterTemp":50,
#     "outerTankVolume":50,
#     "innerTankVolume":50,
#     "soilTankVolume":50,
#     "humidity":0
# }