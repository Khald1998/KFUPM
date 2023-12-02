from app import socketio, mongo

@socketio.on('connect')
def on_connect():
    print('Client connected')

@socketio.on('disconnect')
def on_disconnect():
    print('Client disconnected')

@socketio.on('request_phone_data')
def handle_request_phone_data():
    collection = mongo.db.sensors
    sensor_states = collection.find_one({"_id": "sensor_states"})
    
    # Extracting additional data fields
    air_temp = sensor_states['sensor_data']['air_temp']
    humidity = sensor_states['sensor_data']['humidity']
    outer_tank_volume = sensor_states['sensor_data']['outer_tank_volume']
    inner_tank_volume = sensor_states['sensor_data']['inner_tank_volume']
    inner_water_temp = sensor_states['sensor_data']['inner_water_temp']
    outer_water_temp = sensor_states['sensor_data']['outer_water_temp']
    soil_tank_volume = sensor_states['sensor_data']['soil_tank_volume']

    # Emitting all data to the client
    socketio.emit('phone_data', {
        'air_temp': air_temp,
        'humidity': humidity,
        'outer_tank_volume': outer_tank_volume,
        'inner_tank_volume': inner_tank_volume,
        'inner_water_temp': inner_water_temp,
        'outer_water_temp': outer_water_temp,
        'soil_tank_volume' : soil_tank_volume
    })





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
    




