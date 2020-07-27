#import song
from flask import jsonify
from bson.objectid import ObjectId
def createPlayList(result,db):
    username= result['username']
    listname = result['playlistname']
    #song= result['song']
    play = db.playList
    
    res = []
    
    for x in play.find({'username':username},{'list_name':1,'username':1,'song':1}):
        
        if (listname == x['list_name']):
            return 'Duplicated'
    play.insert({'username':username,'list_name':listname,'song':[]})
    for x in play.find({'username':username},{'list_name':1,'username':1,'song':1}):
        x['_id'] = str(x['_id'])
        res.append(x['list_name'])
    return jsonify(
         res
    ),200
def myPlaylist(result,db):
    username = result ['username']
    # listname = result['playlistname']
    # song = result['song']
    play = db.playList
    res = []
    for x in play.find({"username":username},{'list_name':1}):
        x['_id'] = str(x['_id'])
        res.append(x['list_name'])
    return jsonify(
         res
    ),200
def addSong(result, db):
    id = result["_id"]
    songs = db.songInfo
    play = db.playList
    res = []
    res =songs.find_one({'_id':ObjectId(id)})
    if not res:
        return "Wrong Id"
    if play.find_one({'songs._id':ObjectId(id)}):
        return "Duplicated"
    play.update({'username':result['username'],'list_name':result['playlistName']},{'$push':{'song':{'_id':res['_id'], 'songName':res['songName'] }}})


    return ""
def delPlaylist(result,db):
    username = result['username']
    playlistName = result['playlistName']
    print(playlistName)
    play = db.playList
    play.remove({'username':username,'list_name':playlistName})
    return "1"
def delSong(result, db):
    username = result['username']
    playlistName = result['playlistName']
    idSong = result['_id']
    print(idSong)
    songs = db.songInfo
    play = db.playList
    res = []
    res =songs.find_one({'_id':ObjectId(idSong)})
    if not res:
        return "Wrong Id"
    play.update({'username':username,'list_name':playlistName},{'$pull':{'song': {'songName':res['songName'] }}})
    return "Delete success"

def fetchPlaylist(result, db):
    play = db.playList
    songdb = db.songInfo
    username = result['username']
    playlistName = result['playlistName']
    res = play.find_one({'username':username,'list_name':playlistName})['song']
    temp = []
    fiRes = []
    
    for x in res:
        temp.append(str(x['_id']))
    for x in temp:
            fiRes.append(songdb.find_one({'_id':ObjectId(x)},{'songName':1,'artist':'1','_id':1}))
    for x in fiRes:
        x['_id'] = str(x['_id'])
        x['title'] = str(x['songName'])  
    print("fires:{}".format(fiRes))
    return jsonify(
        fiRes
    )