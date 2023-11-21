from flask import Flask
from flask_pymongo import PyMongo

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb+srv://admin:admin@cluster0.do6q5hx.mongodb.net/greenhouse?retryWrites=true&w=majority"
mongo = PyMongo(app)

# Import the routes to register them with the app
from root import *
from temperature import *
from humidity import *
from disease import *
from getData import *
from randomNumber import *



if __name__ == "__main__":
    port = 8080
    host = '0.0.0.0'
    print(f"Server is working on port: {port}")
    app.run(host=host, port=port, debug=True)
