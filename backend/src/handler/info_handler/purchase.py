import src.main
from flask import jsonify
from src.service.sql import query_transaction, get_user_coin, check_password
from src.service.config_api import DetectResult
import src.const as const

def purchase(request, db):
    username = request['username']
    itemname = request['name']
    itemtype = request['type']
    coin = request['coin']
    password = request['password']

    # mua bai hat, mua vip?
    # Check password, hiển thị confirm purchase (app)
    password_check = check_password(username, password)
    if password_check == False:
        return DetectResult(code=const.CODE_FAIL, message='Wrong password')
    
    purchase_check, purchase_message = query_transaction(username, itemname, itemtype, coin)

    if purchase_check == False:
        return DetectResult(code=const.CODE_FAIL, message=purchase_message)

    newcoin = get_user_coin(username)

    return DetectResult(code=const.CODE_DONE, data = {"coin": newcoin},  message=purchase_message)

    


