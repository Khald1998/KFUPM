from app import app, mongo
from flask import jsonify, request

@app.route('/pinsPOST', methods=['POST'])
def pinsPOST():


    data = request.json

    # Define the MongoDB collection
    collection = mongo.db.pins

    # Iterate over the data items
    for pin, value in data.items():
        # Check if the pin already exists in the database
        existing_pin = collection.find_one({"pin": pin})

        if existing_pin:
            # If it exists, update the value
            collection.update_one({"pin": pin}, {"$set": {"value": value}})
        else:
            # If it doesn't exist, insert a new document
            collection.insert_one({"pin": pin, "value": value})

    return jsonify({"message": "Data updated successfully"}), 200


# {
#     "pin_D22": 0,  // Value for pin D22
#     "pin_D24": 1,  // Value for pin D24
#     "pin_D26": 1,  // Value for pin D26
#     "pin_D28": 1,  // Value for pin D28
#     "pin_D2": 1,   // Value for pin D2
#     "pin_D3": 1,   // Value for pin D3
#     "pin_D4": 1,   // Value for pin D4
#     "pin_D11": 1,  // Value for pin D11 (fan)
#     "pin_D12": 1   // Value for pin D44 (heater)
# }



    # pin_D22 = 1 #relay (OUTPUT)
    # pin_D24 = 1 #relay (OUTPUT)
    # pin_D26 = 1 #relay (OUTPUT)
    # pin_D28 = 1 #relay (OUTPUT)
    # pin_D2 = 1 #relay (OUTPUT)
    # pin_D3 = 1 #relay (OUTPUT)
    # pin_D4 = 1 #relay (OUTPUT)

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
    # pin_D48 = 1 #DS18b20 (inner water)
    # pin_D50 = 1 #DS18b20 (outer water)
    # pin_D52 = 1 #IR sender
    # pin_D53 = 1 #IR receiver
    # pin_A8 = 1 #LDR 1
    # pin_A9 = 1 #LDR 2
    # pin_A10 = 1 #LDR 3

    # pin_D20 = 1 #SDA 
    # pin_D21 = 1 #SLA 