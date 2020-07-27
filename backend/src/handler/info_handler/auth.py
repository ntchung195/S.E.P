import src.main
from flask import jsonify
from src.service.config_api import DetectResult
import src.const as const
from src.service.sql import get_user_info,update_user_login, get_user_coin, initialize_userinfo, update_user_logout, check_password

def register(request, db):
    password = request['password']
    username = request['username']
    email = request['email']
    exist_user = get_user_info(username)
    
    if exist_user is None:
        check_init = initialize_userinfo(username, password, email)
        if check_init is False:
            return DetectResult(code=const.CODE_SERVICE_UNAVAILABLE, message='Service not available')

    else:
        return DetectResult(code=const.CODE_USER_EXISTED, message='Username alr used')

    return DetectResult(code=const.CODE_DONE,data = exist_user, message='User sign up successfully')



def login(request, db):
    password = request['password']
    username = request['username']
    exist_user = get_user_info(username)

    if exist_user is None:
        return DetectResult(code=const.CODE_NAME_NOT_EXIST, message='User is not Exist')

    if exist_user['isLog'] == 1:
        return DetectResult(code=const.CODE_ACCOUNT_LOGGED, message='User already logged in')

    password_check = check_password(username, password)
    if password_check == False:
        return DetectResult(code=const.CODE_FAIL, message='Wrong password')

    login_check = update_user_login(username)
    print(login_check)
    if login_check == False:
        return DetectResult(code=const.CODE_SERVICE_UNAVAILABLE, message='Service not available')

    coinn = get_user_coin(username)
    if coinn is None:
        return DetectResult(code=const.CODE_COIN_NULL, message='User has no coin')
    exist_user["coin"] = coinn

    return DetectResult(code=const.CODE_DONE,data = exist_user, message='USER LOGGED IN')

    


def logout(result, db):
    username = result["username"]
    login_check = update_user_logout(username)
    print(login_check)
    if login_check == False:
        return DetectResult(code=const.CODE_SERVICE_UNAVAILABLE, message='Service not available')
    
    return DetectResult(code=const.CODE_DONE, message='USER LOGGED OUT')

def userInfo(username,db):
    exist_user = get_user_info(username)

    if exist_user is None:
        return DetectResult(code=const.CODE_NAME_NOT_EXIST, message='User is not Exist')

    if exist_user['isLog'] == 1:
        return DetectResult(code=const.CODE_ACCOUNT_LOGGED, message='User already logged in')

    login_check = update_user_login(username)
    if login_check == False:
        return DetectResult(code=const.CODE_SERVICE_UNAVAILABLE, message='Service not available')

    coinn = get_user_coin(username)
    if coinn is None:
        return DetectResult(code=const.CODE_COIN_NULL, message='User has no coin')

    email = exist_user['email']
    phone = exist_user['phone']
    status = exist_user['status']
    exist_user["coin"] = coinn
    return DetectResult(code=const.CODE_DONE,data = exist_user, message='USER LOGGED IN')