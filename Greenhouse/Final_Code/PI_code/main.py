import serial
import time
import requests
import json


# Serial connection setup
ser = serial.Serial("COM3", 115200, timeout=1)

# Common base for the URLs
ip = "157.175.168.108"
base_url = "http://"+ip
port = ":8080"
socket = base_url+port

# Specific endpoints
endpoint_random = "/random"
endpoint_pins_get = "/pinsGET"
endpoint_micro_POST = "/microPOST"

# Constructing the full URLs
url_random = socket + endpoint_random
url_pins_get = socket + endpoint_pins_get
url_sensors_post = socket + endpoint_micro_POST


send_count = 0
read_count = 0

ser.setDTR(False)
time.sleep(1)
ser.flushInput()
ser.setDTR(True)
time.sleep(2)
timey = 0.5


def get_data_from_server(url):
    """
    Function to get data from the server.
    """
    response = requests.get(url)
    data = response.json()
    print(f'Server said: {data}')
    return data

def send_data_to_arduino(serial_connection, data):
    """
    Function to send data to the Arduino.
    """
    serial_connection.write(b'POST\n')
    print("Sending POST Command")

    print("Waiting Arduino to response for POST Command")
    while True:


        if serial_connection.in_waiting > 0:
            raw = serial_connection.readline().decode('utf-8')
            raw = raw.replace('\x00', '').strip()  # This will remove the null character
            print(f"Arduino response for POST Command with: {raw}")
            if (raw=="READY"): 
                break

    json_data = json.dumps(data)
    print(f'Sending data to the Arduino: {json_data}')
    serial_connection.write(json_data.encode())
    serial_connection.write("\n".encode())

    print("Waiting for Arduino DONE response....") 
    while True:


        if serial_connection.in_waiting > 0:
            raw = serial_connection.readline().decode('utf-8')
            raw = raw.replace('\x00', '').strip()  # This will remove the null character
            print(f"Arduino response with: {raw}")
            if (raw=="DONE"): 
                break
             

def read_data_from_arduino(serial_connection):
    """
    Function to read sensor data from the Arduino and send acknowledgment.
    """
    data = None
    # Clearing the buffer before sending the GET command
    serial_connection.reset_input_buffer()
    serial_connection.reset_output_buffer()
    serial_connection.write(b'GET\n')
    print("Sending GET Command")
    print("No data from Arduino, still waiting")
    while True:


        if serial_connection.in_waiting > 0:
            print("Reading data from Arduino...")
            raw = serial_connection.readline().decode('utf-8')
            raw = raw.replace('\x00', '').strip()  
            serial_connection.reset_input_buffer()
            serial_connection.reset_output_buffer()

            if raw:
                try:
                    data = json.loads(raw)
                    print(f"Received data from Arduino: {data}")
                    break
                except json.JSONDecodeError as e:
                    print(f"JSON decoding error: {e}\nRaw data before JSON decoding: {raw}")
                    # Continue waiting for data
                    break
    print("Sending DONE Command")
    serial_connection.reset_input_buffer()
    serial_connection.reset_output_buffer()
    serial_connection.write(b'DONE\n')               
    return data


def post_sensor_data(url, sensor_data_dict):
    """
    Function to send sensor data to a server via POST request.
    """
    headers = {'Content-Type': 'application/json'}

    # The sensor_data_dict is already a Python dictionary, so no need to parse it
    payload = sensor_data_dict
    try:
        response = requests.post(url, json=payload, headers=headers)
        if response.status_code == 200:
            print("Data successfully sent to server")
        else:
            print(f"Failed to send data. Status code: {response.status_code}")
    except requests.RequestException as e:
        print(f"Error sending data: {e}")



while True:
    data = get_data_from_server(url_pins_get)
    sensor_data = read_data_from_arduino(ser)
    # time.sleep(0.5)

    send_data_to_arduino(ser, data)
    if sensor_data:
        post_sensor_data(url_sensors_post, sensor_data)

    # time.sleep(0.5)
