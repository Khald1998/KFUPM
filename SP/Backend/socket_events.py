from app import socketio, mongo

@socketio.on('connect')
def on_connect():
    print('Client connected')

@socketio.on('disconnect')
def on_disconnect():
    print('Client disconnected')

@socketio.on('request_data')
def request_data(data):
    print("Sensor data are being updated/inserted in the database")
    update_sensor_data(data)
    print("All sensor data were processed successfully")

    print("Fetch the pins data from the database")
    pins_data = fetch_pins_data()
    print("Send the pins data to client")
    socketio.emit('response_data', pins_data)

def update_sensor_data(sensor_data):
    collection = mongo.db.sensors
    nested_sensor_data = {key.lower().replace("temp", "_temp").replace("volume", "_volume"): value for key, value in sensor_data.items()}
    collection.update_one({"_id": "sensor_states"}, {"$set": nested_sensor_data}, upsert=True)




def fetch_pins_data():
    # Fetching pin data from the MongoDB database
    collection = mongo.db.pins
    pin_states_doc = collection.find_one({"_id": "pin_states"})
    if pin_states_doc:
        return pin_states_doc.get("pins", {})
    else:
        return {}
    
# def fetch_phone_data():
#     # Fetching pin data from the MongoDB database
#     collection = mongo.db.sensors
#     sensor_states_doc = collection.find_one({"_id": "sensor_states"})
#     if sensor_states_doc:
#         return sensor_states_doc.get("sensors", {})
#     else:
#         return {}

# @socketio.on('request_phone_data')
# def request_phone_data():
#     print("Fetch the Sensor data from the database")
#     pins_data = fetch_pins_data()
#     print("Send the pins data to client")
#     socketio.emit('response_data', pins_data)
