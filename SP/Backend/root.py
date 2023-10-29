from app import app, mongo
from flask import jsonify, request

@app.route('/')
def hello():
    db = mongo.db
    count = db.mycollection.count_documents({})
    return f"Hello, your Flask server is running! You have {count} documents in your 'mycollection'."
