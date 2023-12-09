from app import socketio, mongo
from flask import jsonify, request
import threading
import time
sensor_data_global = {}

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
    # update_pin_data()
    print("Fetch the pins data from the database")
    pins_data = fetch_pins_data()
    print("Send the pins data to client")
    socketio.emit('response_data', pins_data)

def update_sensor_data(sensor_data):
    global sensor_data_global
    collection = mongo.db.sensors
    nested_sensor_data = {key.lower().replace("temp", "_temp").replace("volume", "_volume"): value for key, value in sensor_data.items()}
    collection.update_one({"_id": "sensor_states"}, {"$set": nested_sensor_data}, upsert=True)
    sensor_data_global = sensor_data



def fetch_pins_data():
    # Fetching pin data from the MongoDB database
    collection = mongo.db.pins
    pin_states_doc = collection.find_one({"_id": "pin_states"})
    if pin_states_doc:
        return pin_states_doc.get("pins", {})
    else:
        return {}
    


def lightTrigger(sensor_data):
    # Debugging line to print out the sensor_data structure
    print("Sensor data received in lightTrigger:", sensor_data)
    # Accessing light_level from the nested sensor_data
    global_light_level = sensor_data.get('sensor_data', {}).get("light_level")
    print(f'Light Level from Global: {global_light_level}')
    collection = mongo.db.pins
    # Assuming that light level 1 means light is ON and 0 means OFF
    pin_state = 1 if global_light_level == 1 else 0
    collection.update_one({"_id": "pin_states"}, {"$set": {"pins.pin_D5": pin_state}}, upsert=True)

# def update_pin_data():
#     global sensor_data_global
#     while True:  # Loop to keep this running
#         lightTrigger(sensor_data_global)
#         time.sleep(1)  # Wait for one second before running again

# # Starting the thread that will update the pin data every second
# thread = threading.Thread(target=update_pin_data, daemon=True)
# thread.start()






@socketio.on('request_phone_data')
def handle_request_phone_data():
    collection = mongo.db.sensors
    sensor_states = collection.find_one({"_id": "sensor_states"})
    air_temp = sensor_states['sensor_data']['air_temp']
    humidity = sensor_states['sensor_data']['humidity']
    outer_tank_volume = sensor_states['sensor_data']['outer_tank_volume']
    inner_tank_volume = sensor_states['sensor_data']['inner_tank_volume']
    inner_water_temp = sensor_states['sensor_data']['inner_water_temp']
    outer_water_temp = sensor_states['sensor_data']['outer_water_temp']
    soil_tank_volume = sensor_states['sensor_data']['soil_tank_volume']
    socketio.emit('phone_data', {
        'air_temp': air_temp,
        'humidity': humidity,
        'outer_tank_volume': outer_tank_volume,
        'inner_tank_volume': inner_tank_volume,
        'inner_water_temp': inner_water_temp,
        'outer_water_temp': outer_water_temp,
        'soil_tank_volume' : soil_tank_volume
    })