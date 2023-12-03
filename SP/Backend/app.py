from flask import Flask
from flask_socketio import SocketIO
from flask_pymongo import PyMongo


app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb+srv://admin:admin@cluster0.do6q5hx.mongodb.net/greenhouse?retryWrites=true&w=majority"
mongo = PyMongo(app)
# socketio = SocketIO(app)
socketio = SocketIO(app, cors_allowed_origins='*')

# Import routes and SocketIO event handlers
from root import *
from disease import *
from microcontroller import *
from pins import *
from socket_events import *
from fertilizer import *

if __name__ == '__main__':
    port = 8080
    host = '0.0.0.0'
    print(f"Server is working on port: {port}")
    socketio.run(app, host=host, port=port, debug=True)
