from app import app, mongo
from flask import jsonify, request

@app.route('/disease/<plantId>', methods=['POST'])
def update_disease(plantId):
    data = request.json
    disease_status = data.get('Disease')

    # You might want to validate if disease_status is a boolean or not here.
    if not isinstance(disease_status, bool):
        return jsonify({"message": "Invalid data format!"}), 400

    # Check if a record with the given plantId exists
    existing_plant = mongo.db.plants.find_one({"plantId": plantId})

    if existing_plant:
        # If the plant exists, update its disease status
        updated_data = {
            "$set": {"Disease": disease_status}
        }
        mongo.db.plants.update_one({"plantId": plantId}, updated_data)
        return jsonify({"message": f"Disease status of plant {plantId} updated successfully!"}), 200
    else:
        # If the plant doesn't exist, create a new record with the plantId and disease status
        new_plant = {
            "plantId": plantId,
            "Disease": disease_status
        }
        mongo.db.plants.insert_one(new_plant)
        return jsonify({"message": f"Plant {plantId} with disease status added successfully!"}), 200
