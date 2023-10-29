from app import app, mongo
from flask import jsonify, request
from bson import ObjectId  # This will be useful for updating records by their ID

@app.route('/updateTemperature', methods=['POST'])
def add_or_update_temperature():
    data = request.json
    temperature = data.get('Temperature')
    units = data.get('Units')

    document = {
        "Temperature": temperature,
        "Units": units
    }

    # You may want to identify a record based on certain criteria. 
    # This example uses the units as the identifier; adjust as necessary.
    existing_temperature = mongo.db.temperatures.find_one({"Units": units})

    if existing_temperature:
        # Temperature record exists, so we update it.
        updated_temperature = {
            "$set": document
        }
        mongo.db.temperatures.update_one({"_id": existing_temperature['_id']}, updated_temperature)
        print(f"Updated temperature to: {temperature} {units}")
        return jsonify({"message": "Temperature updated successfully!"}), 200

    else:
        # No record exists, so we insert a new one.
        mongo.db.temperatures.insert_one(document)
        print(f"Added temperature: {temperature} {units}")
        return jsonify({"message": "Temperature added successfully!"}), 200
