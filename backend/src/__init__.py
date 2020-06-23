import os
import json
import datetime
from bson.objectid import ObjectId
from flask.logging import default_handler
from flask import Flask
from pymongo import MongoClient
import pymongo

from src.service.config_api import FlaskApp

class JSONEncoder(json.JSONEncoder):
    ''' extend json-encoder class'''

    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        if isinstance(o, datetime.datetime):
            return str(o)
        return json.JSONEncoder.default(self, o)


app = FlaskApp(__name__)
app.logger.removeHandler(default_handler)

try:
    client = MongoClient('mongodb://{0}:{1}@{2}:27017/?authSource={3}'.format(os.environ['MONGO_ADMIN_USER'],os.environ['MONGO_ADMIN_PWD'],os.environ['MONGO_HOSTNAME'],os.environ['MONGO_DATABASE']),serverSelectionTimeoutMS=3000)
    client.server_info()
except pymongo.errors.ServerSelectionTimeoutError as err:
    # do whatever you need
    print('Err:',err)
db =client.musicapp

# use the modified encoder class to handle ObjectId & datetime object while jsonifying the response.
app.json_encoder = JSONEncoder
