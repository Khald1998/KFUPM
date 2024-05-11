import socketio
import serial
import time
from arduino_communication import read_data_from_arduino, send_data_to_arduino

# Serial connection setup
ser = serial.Serial("COM5", 115200, timeout=1)

# SocketIO setup
ip = "15.185.215.59"
# ip = "15.185.215.59" 
port = 8080
sio = socketio.Client()
sio.connect(f'http://{ip}:{port}')

# Global variables for storing data received from server and flag
pin_data = None
new_data_available = False

# Event handler for receiving pins data
@sio.on('response_data')
def on_response_data(data):
    global pin_data, new_data_available
    pin_data = data
    new_data_available = True
    print("Received pins data from server:", pin_data)

# Event handler for receiving pins data
@sio.on('response_phone_data')
def on_response_phone_data(data):
    global pin_data, new_data_available
    pin_data = data
    new_data_available = True
    # print("Received pins data from server:", pin_data)

ser.setDTR(False)
time.sleep(1)
ser.flushInput()
ser.setDTR(True)
time.sleep(2)

def exchange_data_with_server(sensor_data):
    """
    Function to send sensor data to the server and request pins data.
    """
    sio.emit('request_data', {'sensor_data': sensor_data})
    print("Exchanged data with server")

while True:
    sensor_data = read_data_from_arduino(ser)
    if sensor_data:
        exchange_data_with_server(sensor_data)

    if new_data_available:  
        send_data_to_arduino(ser, pin_data,sensor_data)
        new_data_available = False
    time.sleep(0.01)

