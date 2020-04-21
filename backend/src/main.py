import os
from flask import Flask, request, jsonify
from flask.logging import default_handler
from flask_pymongo import PyMongo

app = Flask(__name__)
app.logger.removeHandler(default_handler)
app.config["MONGO_URI"] = 'mongodb://' + os.environ['MONGO_ADMIN_USER'] + ':' + os.environ['MONGO_ADMIN_PWD'] + ':27000/' + os.environ['MONGO_DATABASE']

mongo = PyMongo(app)

db =mongo.db

# @app.route('/')
# def index():
#     return jsonify(
#         status = True,
#         message = 'Successs connect to MongoDB!'
#     )
@app.route('/')
def index():
    # user_collection = mongo.db.users
    # user_collection.insert({'name' : 'Cristina'})
    # user_collection.insert({'name' : 'Derek'})
    return '<h1>Added a User!</h1>'
