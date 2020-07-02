from flask import jsonify
import src.main

def createPlayList(result,db):
    username= result['username']
    listname = result['playlistname']
    #song= result['song']
    play = db.playList
    
    res = []
    
    for x in play.find({'username':username},{'playlistName':1,'username':1,'song':1}):
        
        if (listname == x['playlistName']):
            return jsonify(
                message = "Already exist please try another name"
            ),400
        x['_id'] = str(x['_id'])
        res.append(x['playlistName'])
    play.insert({'username':username,'playlistName':listname,'songName':[]})
    return jsonify(
         res
    ),200
def myPlaylist(result,db):
    username = result ['username']
    # listname = result['playlistname']
    # song = result['song']
    play = db.playList
    res = []
    for x in play.find({"username":username},{'playlistName':1}):
        x['_id'] = str(x['_id'])
        res.append(x['playlistName'])
    return jsonify(
         res
    ),200
def addSong(result,db):
    play = db.playList
    title = result['title']
    username = result['username']
    playlistName = result['playlistname']
    play.update({'username':username,'playlistName':playlistName},{'$push':{'songName':title}})
    # can user $addToSet to add
    return jsonify(message = 'Add successful'),200
def deleteSong(result,db):
    username = result['username']
    playlistName = result['playlistName']
    title = result['title']
    play = db.playList
    if play.find({'username':username}) is None:
        return jsonify(),400
    play.update({'username':username,'playlistName':playlistName},{'$pull':{'songName':title}})
    return jsonify(),200
def deletePlaylist(result,db):
    return ""