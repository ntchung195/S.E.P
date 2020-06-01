from src import db



def get_user_id(user_name):
    """
    Get User ID By Name
    """
    data =db.userInfo.find_one(user_name)
    if len(data) == 0:
        return
    else:
        result = data['_id']
        return str(result)

def get_playlist_user(user_name,user_id):
    pass
    
