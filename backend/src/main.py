import os
import logging
import sys
# sys.path.append('..')
import src.const as const


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
from src.handler.song_handle import get_song_path,get_song_list
from src.handler.play_list_handle import create_play_list
from src.service import sql
from src import app

# app = Flask(__name__)

# mongo = PyMongo(app)

# db =mongo.db

@app.route('/')
def index():
    return jsonify(
        status = 200,
        message = 'Successs connect to MongoDB!'
    )
    
@app.route('/enroll', methods=["POST"])
def enroll():
    log.info('Starting Process....')
    if request.method == "POST":
        json_reg = request.get_json(force=True,silent=True)
        log.info('request info:{}'.format(request))
        log.info('json_reg:{}'.format(json_reg))
        if not json_reg:
            return ApiResponse(message="Invalid json"), status.HTTP_400_BAD_REQUEST
        
        username = json_reg['username']
        # session['user_name'] = username
        

        log.debug("User Name: {}".format(username))

        user_id = json_reg['user_id']

        # session['user_id'] = user_id
        log.debug("User ID: {}".format(user_id))
        req = DetectRequest(name=username,user_id=user_id)

        ok, msg = req.validate()
        if not ok:
            return ApiResponse(message=msg), status.HTTP_400_BAD_REQUEST

        result = add_user(username,log)
        if result.code != const.CODE_DONE :
            if result.code == const.CODE_FILE_EXIST:                
                return ApiResponse(success=True,code = result.code,message=result.message)
            log.info('Get Error....')
            return ApiResponse(success=False,message=result.message),status.HTTP_400_BAD_REQUEST

        log.info('End Process')
        return ApiResponse(success = True,code = result.code)
 
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

@app.route("/getSongList",methods=['GET'])
def getSongList():
    log.info('Starting Process....')
    song_list = get_song_list(logging)
    if song_list.data is None or len(song_list.data) == 0:
        log.info('End Process....')
        return ApiResponse(daget_song_listta=song_list.data,message=song_list.message,success=False,code=song_list.code), status.HTTP_400_BAD_REQUEST
    else:
        log.info('End Process....')
        return ApiResponse(data=song_list.data,message=song_list.message,success=True,code=song_list.code)

@app.route("/getSongPath",methods=['GET'])
def getSong():
    log.info('Starting Process....')
    song = request.args.get('s') or request.args.get('song')
    log.info('Error Here 3')

    if song is None or len(song) == 0:
        return ApiResponse(message='Missing Song Id'), status.HTTP_400_BAD_REQUEST
    res = get_song_path(song,logging)
    log.info('Respond result: {}'.format(res))
    if res.code == const.CODE_SONG_NOT_EXIST:
        return ApiResponse(message=res.message,code=res.code,data=''), status.HTTP_400_BAD_REQUEST
    if res.code == const.CODE_DONE:
        return ApiResponse(message=res.message,code=res.code,data=res.data)
get_song_list
@app.route("/createList",methods=['POST'])
def getList():
    log.info('Starting Process....')
    json_reg = request.get_json(force=True,silent=True)
    log.info('request info:{}'.format(request))
    log.info('json_reg:{}'.format(json_reg))
    if not json_reg:
        return ApiResponse(message="Invalid json"), status.HTTP_400_BAD_REQUEST

    username = json_reg['username']
    # session['user_name'] = username
    
    log.debug("User Name: {}".format(username))

    user_id = json_reg['user_id']

    log.debug("User ID: {}".format(user_id))

    list_name = json_reg['list_name']

    req = DetectRequest(name=username,user_id=user_id)

    ok, msg = req.validate()
    if not ok:
        return ApiResponse(message=msg), status.HTTP_400_BAD_REQUEST

    result = create_play_list(user_id,username,list_name,log)

    if result.code != const.CODE_DONE :
        if result.code == const.CODE_PLAYLIST_NOT_EXIST:                
            return ApiResponse(success=True,code = result.code,message=result.message),status.HTTP_404_NOT_FOUND
        log.info('Get Error....')
        return ApiResponse(success=False,message=result.message),status.HTTP_400_BAD_REQUEST

    log.info('End Process')
    return ApiResponse(success = True,code = result.code,message=result.message)




