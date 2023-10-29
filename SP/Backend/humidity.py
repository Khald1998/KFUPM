from app import app, mongo
from flask import jsonify, request
from bson import ObjectId  # This will be useful for updating records by their ID

@app.route('/updateHumidity', methods=['POST'])
def add_or_update_humidity():
    data = request.json
    humidity = data.get('Humidity')
    units = data.get('Units')

    document = {
        "humidity": humidity,
        "Units": units
    }

    # You may want to identify a record based on certain criteria. 
    # This example uses the units as the identifier; adjust as necessary.
    existing_humidity = mongo.db.humiditys.find_one({"Units": units})

    if existing_humidity:
        # humidity record exists, so we update it.
        updated_humidity = {
            "$set": document
        }
        mongo.db.humiditys.update_one({"_id": existing_humidity['_id']}, updated_humidity)
        print(f"Updated humidity to: {humidity} {units}")
        return jsonify({"message": "humidity updated successfully!"}), 200

    else:
        # No record exists, so we insert a new one.
        mongo.db.humiditys.insert_one(document)
        print(f"Added humidity: {humidity} {units}")
        return jsonify({"message": "humidity added successfully!"}), 200
