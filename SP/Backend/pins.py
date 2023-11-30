from app import app, mongo
from flask import jsonify, request

@app.route('/pinsPOST', methods=['POST'])
def pinsPOST():
    data = request.json
    collection = mongo.db.pins
    for pin, value in data.items():
        query = {pin: {"$exists": True}}  
        new_data = {pin: value}  
        print(f"pin: {pin} \nquery: {query} \nnew_data: {new_data} \nif?: {collection.find_one(query)}")
        if collection.find_one(query):
            collection.update_one(query, {"$set": new_data})
        else:
            collection.insert_one(new_data)
    return jsonify({"message": "Data updated successfully"}), 200


@app.route('/pinsGET', methods=['GET'])
def pinsGET():
    collection = mongo.db.pins
    all_pins = collection.find({})
    transformed_data = {}
    for document in all_pins:
        for key, value in document.items():
            if key != '_id':
                transformed_data[key] = value
    return jsonify(transformed_data), 200


# {
#     "pin_D22": 0,  // Value for pin D22
#     "pin_D24": 1,  // Value for pin D24
#     "pin_D26": 1,  // Value for pin D26
#     "pin_D28": 1,  // Value for pin D28
#     "pin_D2": 1,   // Value for pin D2
#     "pin_D3": 1,   // Value for pin D3
#     "pin_D4": 1,   // Value for pin D4
#     "pin_D5": 1,   // Value for pin D4
#     "pin_D11": 1,  // Value for pin D11 (fan)
#     "pin_D12": 1   // Value for pin D44 (heater)
# }




    # pin_D22 = 1 #relay Pump (OUTPUT)
    # pin_D24 = 1 #relay Pump (OUTPUT)
    # pin_D26 = 1 #relay Pump (OUTPUT)
    # pin_D28 = 1 #relay Pump (OUTPUT)
    # pin_D2 = 1 #relay Pump (OUTPUT)
    # pin_D3 = 1 #relay Pump (OUTPUT)
    # pin_D4 = 1 #relay Pump (OUTPUT)
    # pin_D5 = 1 #relay Light (OUTPUT)

    # pin_D32 = 1 #Echo 
    # pin_D34 = 1 #Trig 
    # pin_D36 = 1 #Echo 
    # pin_D38 = 1 #Trig 
    # pin_D40 = 1 #Echo 
    # pin_D42 = 1 #Trig 

    # pin_D9 = 1 #Servo Moter 
    # pin_D10 = 1 #Servo Moter

    # pin_D11 = 1 #fan (OUTPUT)
    # pin_D12 = 1 #heater (OUTPUT)

    # pin_D46 = 1 #DHT11 (air temp)
    # pin_D48 = 1 #DS18b20 (inner water temp)
    # pin_D50 = 1 #DS18b20 (outer water temp)
    # pin_D52 = 1 #IR sender
    # pin_D53 = 1 #IR receiver
    # pin_A8 = 1 #LDR 1
    # pin_A9 = 1 #LDR 2
    # pin_A10 = 1 #LDR 3
    # pin_A13 = 1 #LDR 4
    # pin_A14 = 1 #LDR 5

    # pin_D20 = 1 #LCD I2C SDA 
    # pin_D21 = 1 #LCD I2C SLA 

    # pin_A11 = 1 #Potentiometer 
    # pin_A12 = 1 #Potentiometer 

