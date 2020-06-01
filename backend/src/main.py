import os
import logging
import sys
import const
sys.path.append('..')

log = logging.getLogger()
log.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
log.addHandler(handler)

from flask import  request, jsonify,Flask,render_template,session
from flask_api import status
# from flask.logging import default_handler
# from flask_pymongo import PyMongo

from src.service.config_api import ApiResponse,DetectRequest,DetectResult 
from src.handler.add_user import add_user,add_user_info, register_user_voice
from src.handler.auth_user import voice_recognite
from src.service import sql
from src import app, db

# app = Flask(__name__)
# app.logger.removeHandler(default_handler)
# app.config["MONGO_URI"] = 'mongodb://' + os.environ['MONGO_ADMIN_USER'] + ':' + os.environ['MONGO_ADMIN_PWD'] + '@' + os.environ['MONGO_HOSTNAME'] + ':27017/' + os.environ['MONGO_DATABASE']

# mongo = PyMongo(app)

# db =mongo.db

@app.route('/')
def index():
    return jsonify(
        status = 200,
        message = 'Successs connect to MongoDB!'
    )
    
@app.route('/enroll', methods=["GET", "POST"])
def enroll():
    log.info('Starting Process....')
    if request.method == "POST":
        json_reg = request.get_json(force=True,silent=True)
        if not json_reg:
            return ApiResponse(message="Invalid json"), status.HTTP_400_BAD_REQUEST
        
        username = json_reg['username']
        session['user_name'] = username
        

        log.debug("User Name: {}".format(username))

        user_id = json_reg['user_id']

        session['user_id'] = user_id
        log.debug("User ID: {}".format(user_id))
        req = DetectRequest(name=username,user_id=user_id)

        ok, msg = reg.validate()
        if not ok:
            return ApiResponse(message=msg), status.HTTP_400_BAD_REQUEST

        result = add_user(username,log)
        # if not result:
        #     return redirect(url_for('enroll'))
        if result.code != const.CODE_DONE or result.code != const.CODE_FILE_EXIST:
            return ApiResponse(success=False,message=result.message),status.HTTP_400_BAD_REQUEST
        log.info('End Process')
        return ApiResponse(success = True), status.HTTP_200_OK
    else:
        return render_template('enroll.html')
 
@app.route('/auth', methods =['POST', 'GET'])
def auth():
    pass

@app.route('/voice', methods = ['POST', 'GET'])
def voice():
    log.info('Starting Process....')
    if request.method == 'POST':
        data = request.data
        if data is None:
            return ApiResponse(message="Cannot recognize voice"),status.HTTP_400_BAD_REQUEST
        if "user_id" in session:
            user_id = session['user_id']
        else:
            return ApiResponse(message="User not register recognition voice"),status.HTTP_400_BAD_REQUEST
        if "user_name" in session:
            user_name = session['user_name']
        result = add_user_info(data,user_name,user_id,log)
        if result.code == const.CODE_SERVICE_UNAVAILABLE:
            return ApiResponse(message=result.message),status.HTTP_503_SERVICE_UNAVAILABLE
        if result.code == const.CODE_DONE:
            log.info('End Process')
            return ApiResponse(success = True,message=result.message), status.HTTP_200_OK

@app.route('/biometrics', methods = ['POST', 'GET'])
def biometrics():
    log.info('Starting Process....')
    if request.method == 'GET':
        if 'user_id' in session:
            user_id = session['user_id']
        else:
            return ApiResponse(message="User not register recognition voice"),status.HTTP_400_BAD_REQUEST
        if 'user_name' in session:
            user_name = session['user_name'] 
        log.debug("Into the biometrics route.")
        result = register_user_voice(user_name,user_id,log)
        if result.code == const.CODE_FAIL:
            return ApiResponse(message=result.message),status.HTTP_400_BAD_REQUEST
        if result.code == const.CODE_DONE:
            return ApiResponse(message=result.message),status.HTTP_200_OK


@app.route("/verify", methods=['GET'])
def verify():
    log.info('Starting Process....')

    if 'user_id' in session:
        user_id = session['user_id']
    else:
        return ApiResponse(message="User not register recognition voice"),status.HTTP_400_BAD_REQUEST
    if 'user_name' in session:
        user_name = session['user_name']

    result = voice_recognite(user_name,user_id,log) 



