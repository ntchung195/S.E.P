import os
import json
import datetime
from bson.objectid import ObjectId
from flask.logging import default_handler
from flask import Flask
from flask_pymongo import PyMongo


class JSONEncoder(json.JSONEncoder):
    ''' extend json-encoder class'''

    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        if isinstance(o, datetime.datetime):
            return str(o)
        return json.JSONEncoder.default(self, o)


app = Flask(__name__,template_folder='template')
app.logger.removeHandler(default_handler)
app.config["MONGO_URI"] = 'mongodb://' + os.environ['MONGO_ADMIN_USER'] + ':' + os.environ['MONGO_ADMIN_PWD'] + '@' + os.environ['MONGO_HOSTNAME'] + ':27017/' + os.environ['MONGO_DATABASE']

mongo = PyMongo(app)

db =mongo.db

# use the modified encoder class to handle ObjectId & datetime object while jsonifying the response.
app.json_encoder = JSONEncoder

# from src import *