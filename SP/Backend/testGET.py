from app import app, mongo
from flask import jsonify

@app.route('/GET', methods=['GET'])
def testGET():
    # Query to find a document with 'test_data'
    document = mongo.db.test.find_one({"test_data": {"$exists": True}}, {"_id": 0, "test_data": 1})

    # Check if a document was found
    if document:
        # Return the 'test_data' part of the document
        return jsonify({"test_data": document["test_data"]}), 200
    else:
        # Handle the case where 'test_data' does not exist
        return jsonify({"error": "No test data found"}), 404
