from src import db
import os
from datetime import datetime


def get_user_id(user_name):
    """
    Get User ID By Name
    """
    data =db.userInfo.find_one({"name":user_name})
    if data is None:
        return
    else:
        result = data['_id']
        return str(result)

def get_user_info(username):
    return db.userInfo.find_one({'username': username})

def get_user_coin(username):
    return db.wallet.find_one({'username': username})['coin']

def update_user_login(username):
    try:
        db.userInfo.update(
            {'username':username},
            {
                '$set':{'isLog': 1},
            },
            upsert= True
        )
    except Exception as e:
        print("Exception happended: ", e)
        return False
    return True

def update_user_logout(username):
    try:
        db.userInfo.update(
            {'username':username},
            {
                '$set':{'isLog': 0},
            },
            upsert= True
        )
    except Exception as e:
        print("Exception happended: ", e)
        return False
    return True

def check_password(username, password):
    confirm_password = db.userInfo.find_one({'username': username})['password']
    return confirm_password == password

def initialize_userinfo(username, password, email): 
    try: 
        db.userInfo.insert({'username': username, 'password': password, 'email': email, 'status': 0, 'isLog': 0, 'phone': ""})
        db.wallet.insert({'username': username, 'coin':0})
    except Exception as e:
        print("Exception happended: ", e)
        return False
    return True


def query_transaction(username, itemname, itemtype, coin):
    if coin < 0:
        return False, 'Invalid coin!'
    cur_coin = db.wallet.find_one({'username': username})['coin']

    if cur_coin < coin:
        return False, 'Not enough coin!'
    try:
        if itemname == 'VIP':
            db.userInfo.update(
                {'username':username},
                {
                    '$set':{'status': 1},
                },
                upsert= True
            )

        db.wallet.update(
            {"username": username},
            {
                "$inc": {
                    "coin": -int(coin),
                }
            }, 
        )

        db.transaction.insert({
            'username': username,
            'coin': coin,
            'item': {
                'name': itemname,
                'type': itemtype,
            },
            'date': datetime.now()
        }
        )
    except Exception as e:
        print("Exception happended: ", e)
        return False, "Service unavailable"
    return True, "Successful Transaction"
    
def get_user_id(user_name):
    """
    Get User ID By Name
    """
    data =db.userInfo.find_one({"name":user_name})
    if data is None:
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

    
