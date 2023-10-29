from flask import jsonify
from app import app, mongo

@app.route('/getAllData', methods=['GET'])
def get_all_data():
    # Fetching all plants data
    plants = mongo.db.plants.find({}, {"_id": 0})  # Excluding '_id' from the results
    plants_data = [plant for plant in plants]

    # Fetching all humidity data
    humiditys = mongo.db.humiditys.find({}, {"_id": 0})  # Excluding '_id' from the results
    humiditys_data = [humidity for humidity in humiditys]

    # Fetching all temperature data
    temperatures = mongo.db.temperatures.find({}, {"_id": 0})  # Excluding '_id' from the results
    temperatures_data = [temperature for temperature in temperatures]

    # Constructing the response object
    data = {
        "plants": plants_data,
        "humiditys": humiditys_data,
        "temperatures": temperatures_data
    }

    # Responding with the data collected from the three collections, excluding '_id' field
    return jsonify(data)
