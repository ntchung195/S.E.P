import src.main
from flask import jsonify
from bson.objectid import ObjectId
def song(result,db):
    name =[]
    song = db.songInfo
    for x in song.find({},{'songName':1,'artist':1,'_id':1}):        
        
        x['_id'] = str(x['_id'])
        x["title"] = x["songName"]
        name.append(x)
    return jsonify(
        favourite = name
    ),200

def play(result,db):
    song = db.songInfo
    id = result['_id']
    songRes = song.find_one({"_id" :ObjectId(id)},{'songName':1,'artist':1,'_id':0,'link':1,'duration':1})
    songRes["title"] = songRes["songName"]
    return jsonify(
        songRes
    ),200