
# from app import app, mongo
# from flask import jsonify, request

# @app.route('/GET', methods=['GET'])
# def GET():
#     collection = mongo.db.pins
#     all_pins = collection.find({})
#     transformed_data = {}
#     for document in all_pins:
#         for key, value in document.items():
#             if key != '_id':
#                 transformed_data[key] = value
#     return jsonify(transformed_data), 200

# @app.route('/POST', methods=['POST'])
# def POST():
#     req = request.json

#     for sensor_type, sensor_value in req.items():
#         existing_document = mongo.db.sensors.find_one({"sensorType": sensor_type})
#         if existing_document:
#             mongo.db.sensors.update_one({"_id": existing_document["_id"]}, {"$set": {"sensorValue": sensor_value}})
#             message = f"{sensor_type} updated successfully!"
#         else:
#             mongo.db.sensors.insert_one({"sensorType": sensor_type, "sensorValue": sensor_value})
#             message = f"{sensor_type} added successfully!"
#         print(f"Processed {sensor_type}: {sensor_value}")
#     return jsonify({"message": "All sensors processed successfully"}), 200


from app import app, mongo  # Importing app and mongo from app.py
from flask_socketio import SocketIO, emit
import json

socketio = SocketIO(app, cors_allowed_origins="*")



@socketio.on('connect')
def test_connect():
    print("Client connected")

@socketio.on('disconnect')
def test_disconnect():
    print("Client disconnected")

@socketio.on('message')
def handle_message(message):
    print(f"Received message: {message}")
    data = json.loads(message)
    process_sensor_data(data)
    emit('response', {'status': 'received'})

def process_sensor_data(data):
    for sensor_type, sensor_value in data.items():
        existing_document = mongo.db.sensors.find_one({"sensorType": sensor_type})
        if existing_document:
            mongo.db.sensors.update_one({"_id": existing_document["_id"]}, {"$set": {"sensorValue": sensor_value}})
            print(f"{sensor_type} updated successfully!")
        else:
            mongo.db.sensors.insert_one({"sensorType": sensor_type, "sensorValue": sensor_value})
            print(f"{sensor_type} added successfully!")

