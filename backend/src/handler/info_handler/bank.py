import src.main
from flask import jsonify

def trans(result, db):
    user_wallet = db.wallet
    coin = result['coin']   
    username = result['username']
    
    if coin <= 20000:
        return jsonify(
            statusCode = 400,
            message = 'Transaction Denied'
                ), 400

    user_wallet.update(
        {"username": username},
        {
            "$inc": {
                "coin": coin,
            }
        },
        upsert = True,
    )

    newcoin = user_wallet.find_one({'username': username})['coin']
    print(newcoin)
    
    return jsonify(
    statusCode = 201,
    message = 'Succeed',
    coin = newcoin
                ), 200

    