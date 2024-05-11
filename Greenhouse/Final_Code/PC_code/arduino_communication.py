import json
import serial

def read_data_from_arduino(serial_connection):
    """
    Function to read sensor data from the Arduino and send acknowledgment.
    """
    data = None
    serial_connection.reset_input_buffer()
    serial_connection.reset_output_buffer()
    serial_connection.write(b'GET\n')
    print("Sending GET Command\n")
    while True:
        if serial_connection.in_waiting > 0:
            print("Reading data from Arduino...\n")
            raw = serial_connection.readline().decode('utf-8').strip()
            serial_connection.reset_input_buffer()
            serial_connection.reset_output_buffer()
            if raw:
                try:
                    data = json.loads(raw)
                    print(f"Received data from Arduino:\n{data}")
                    break
                except json.JSONDecodeError as e:
                    print(f"JSON decoding error: {e}\nRaw data before JSON decoding:\n{raw}")
                    break
    serial_connection.write(b'DONE\n')               
    return data

def wait_for_arduino_response(serial_connection, expected_response):
    """
    Wait for a specific response from the Arduino.
    """
    while True:
        if serial_connection.in_waiting > 0:
            raw = serial_connection.readline().decode('utf-8').strip()
            print(f"Arduino response:\n{raw}")
            if raw == expected_response:
                break

def send_data_to_arduino(serial_connection, pin_data,sensor_data):
    """
    Function to send data to the Arduino.
    """
    # new_pin_data = update_pin_data(pin_data,sensor_data)
    serial_connection.write(b'POST\n')
    print("Sending POST Command\n")
    wait_for_arduino_response(serial_connection, "READY")

    json_data = json.dumps(pin_data)
    print(f'Sending data to the Arduino:\n{json_data}')
    serial_connection.write(json_data.encode())
    serial_connection.write("\n".encode())
    wait_for_arduino_response(serial_connection, "DONE")




###    
###-------------------------------------------------------------------
###
def lightTrigger(sensor_data):
    global_light_level = sensor_data.get("light_level")
    # print(f'\n\nLight Level: {global_light_level}')
    pin_D5 = 1 if global_light_level == 1 else 0
    return pin_D5  # This will return the value of pin_D5

def fanTrigger(sensor_data):
    # Fan logic with linear increase in value
    air_temp = sensor_data.get("air_temp")
    if air_temp > 50:
        return 255
    elif air_temp > 30:
        # Linear interpolation from air_temp 30 (value 50) to air_temp 50 (value 255)
        return int(50 + (air_temp - 30) * (205 / (50 - 30)))
    else:
        return 0  # Fan is off if air_temp is 30 or less

def heaterTrigger(sensor_data):
    # Heater logic with linear increase in value
    air_temp = sensor_data.get("air_temp")
    if air_temp < 0:
        return 255
    elif air_temp < 20:
        # Linear interpolation from air_temp 20 (value 50) to air_temp 0 (value 255)
        return int(50 + (20 - air_temp) * (205 / (20 - 0)))
    else:
        return 0  # Heater is off if air_temp is 20 or more


def update_pin_data(pin_data, sensor_data):
    pin_D5_state = lightTrigger(sensor_data)
    pin_D11_state = fanTrigger(sensor_data)
    # if sensor_data.get("inner_water_temp")<50.0:
    #     pin_D12_state = heaterTrigger(sensor_data)
    #     if sensor_data.get("inner_tank_volume")>0.01:
    #         pin_D2_state=1
    #         pin_D24_state=0
    #     else:
    #         pin_D2_state=0
    #         pin_D24_state=0
    # else:
    #     pin_D12_state = 0
    #     if sensor_data.get("inner_tank_volume")<230:
    #         pin_D2_state=0
    #         pin_D24_state=1
    #     else:
    #         pin_D2_state=0
    #         pin_D24_state=0


    pin_data['pin_D5'] = pin_D5_state
    pin_data['pin_D11'] = pin_D11_state
    # pin_data['pin_D12'] = pin_D12_state
    # pin_data['pin_D2'] = pin_D2_state
    # pin_data['pin_D24'] = pin_D24_state
    print(f'pin_D5:{pin_D5_state}\npin_D11:{pin_D11_state}\n\n')
    return pin_data  


###
###-------------------------------------------------------------------
###