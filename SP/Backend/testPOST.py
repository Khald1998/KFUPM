from app import app, mongo
from flask import jsonify, request

@app.route('/POST', methods=['POST'])
def testPOST():
    req = request.json
    raw_data = req.get('data')

    # Query to find if a document with 'test_data' exists
    existing_document = mongo.db.test.find_one({"test_data": {"$exists": True}})

    if existing_document:
        # Update the existing document
        mongo.db.test.update_one({"_id": existing_document["_id"]}, {"$set": {"test_data": raw_data}})
        message = "test_data updated successfully!"
    else:
        # Insert a new document
        mongo.db.test.insert_one({"test_data": raw_data})
        message = "test_data added successfully!"

    print(f"Processed test_data: {raw_data}")
    return jsonify({"message": message}), 200
