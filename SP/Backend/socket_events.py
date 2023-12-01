from app import socketio, mongo

@socketio.on('connect')
def on_connect():
    print('Client connected')

@socketio.on('disconnect')
def on_disconnect():
    print('Client disconnected')
    
@socketio.on('request_data')
def request_data(data):
    print("Sensor data are being Updated/inserted in the database")
    # mongo.db.sensors
    print("All sensor data were processed successfully")

    print("Fetch the pins data from the database")
    # collection = mongo.db.pins
    pins_data = "..."  
    print("Send the pins data to client")

    socketio.emit('response_data', pins_data)



