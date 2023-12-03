from app import app, mongo
from flask import jsonify, request

@app.route('/fertilizerPOST', methods=['POST'])
def fertilizerPOST():
    data = request.json
    if not data:
        return jsonify({"error": "Invalid JSON data"}), 400
    collection = mongo.db.fertilizer
    existing_data = collection.find_one({"plant_name": data.get("plant_name")})
    if existing_data:
        collection.update_one(
            {"plant_name": data.get("plant_name")},
            {"$set": data}
        )
        return jsonify({"message": "Data updated successfully"}), 200
    else:
        collection.insert_one(data)
        return jsonify({"message": "Data inserted successfully"}), 201
