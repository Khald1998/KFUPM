from app import app, mongo
from flask import jsonify, request

@app.route('/fertilizerPOST', methods=['POST'])
def fertilizerPOST():
    data = request.json
    collection = mongo.db.fertilizer

    # Assuming a single document structure with a known identifier, for example, "fertilizer_data"
    document_id = "fertilizer_data"
    query = {'_id': document_id}
    
    # Check if the document already exists
    existing_document = collection.find_one(query)
    
    if existing_document:
        # Update the existing document
        new_values = {"$set": data}
        collection.update_one(query, new_values)
    else:
        # Create a new document with the provided data and a specific identifier
        data['_id'] = document_id
        collection.insert_one(data)

    return jsonify({"message": "Data processed successfully"}), 200

# 1 - for all the data.
@app.route('/fertilizerGET', methods=['GET'])
def fertilizerGET():
    collection = mongo.db.fertilizer
    data = collection.find_one({"_id": "fertilizer_data"})
    return jsonify(data), 200

# 2- for all products.
@app.route('/products', methods=['GET'])
def products():
    collection = mongo.db.fertilizer
    data = collection.find_one({"_id": "fertilizer_data"})
    products = list(data.keys()) if data else []
    return jsonify(products), 200

# 3- for a specific product {all plants}.
@app.route('/plants/<product_name>', methods=['GET'])
def getProductPlants(product_name):
    collection = mongo.db.fertilizer
    data = collection.find_one({"_id": "fertilizer_data"})
    plants_with_values = data.get(product_name, {}) if data else {}
    return jsonify(plants_with_values), 200

# 4- for a specific product {a specific plant}.
@app.route('/plant/<product_name>/<plant_name>', methods=['GET'])
def getSpecificPlant(product_name, plant_name):
    collection = mongo.db.fertilizer
    data = collection.find_one({"_id": "fertilizer_data"})
    if data and product_name in data and plant_name in data[product_name]:
        plant_value = data[product_name][plant_name]
        return jsonify({plant_name: plant_value}), 200
    else:
        return jsonify({"error": "Plant or product not found"}), 404

