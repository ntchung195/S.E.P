from src import db
import os
from datetime import datetime


def get_user_id(user_name):
    """
    Get User ID By Name
    """
    data =db.userInfo.find_one({"name":user_name})
    if len(data) == 0:
        return
    else:
        result = data['_id']
        return str(result)

def create_user_song_list(user_name,user_id,play_list):
    """
    Create Play List
    """
    is_success = False
    try:
        data = db.playList.insert({
            "list_name": play_list,
            "song" : [],
            "user" : {
                "id": user_id,
                "user_name": user_name
            },
            "createdAt" : datetime.now(),
            "modifiedAt" : datetime.now()
        })
        print("data:",data)
        is_success = True
    except Exception as ex:
        is_success = False
        return is_success
    return is_success

def get_list():
    """
    Get List Song Name
    """
    data = db.songInfo.find({})
    res = []
    for document in data:
        res.append({"id": str(document['_id']),"name":str(document['songName'])})
        print(document)
    
    return res

    
