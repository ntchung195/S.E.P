import src.main
from flask import jsonify
from datetime import datetime

def update_phone(result, db):
    users = db.userInfo
    username = result["username"]
    phone = result["phone"]
    if phone.isdecimal():
        users.update(
            {"username": username},
            {
                "$set": {
                    "phone": phone,
                }
            }, 
            upsert= True
        )
        return jsonify(
        phone = phone
                    ), 200
    return jsonify(
        message = "Not Decimal Number"
    ), 400

def update_email(result, db):
    users = db.userInfo
    username = result["username"]
    email = result["email"]
    users.update(
        {"username": username},
        {
            "$set": {
                "email": email,
            }
        }, 
        upsert= True
    )
    return jsonify(
    email = email
                ), 200