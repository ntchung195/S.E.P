import pyaudio
import wave
# import cv2
import os
import pickle
import time
from scipy.io.wavfile import read
# from IPython.display import Audio, display, clear_output

# from main_functions import *
from src.util.voice import *
from src.service.sql import get_user_id
from src.service.config_api import DetectResult
import const

def add_user(name,logging):
    
    # name = input("Enter Name:")
    
    #Voice authentication
    # FORMAT = pyaudio.paInt16
    # CHANNELS = 2
    # RATE = 44100
    # CHUNK = 1024
    # RECORD_SECONDS = 3
    if name is None:
        return DetectResult(code=const.CODE_NAME_NOT_EXIST, message='User Name not exist')
    user_id = get_user_id(name)
    if user_id is None:
        return DetectResult(code=const.CODE_ACCOUNT_NOT_EXIST, message='User Id not exist')
    
    user_dir = os.path.abspath(const.USER_DIR)
    if os.path.isdir(user_dir+'/{}'.format(name)):
        return DetectResult(code=const.CODE_FILE_EXIST, message='User already register voice regcognition')
    else:
        os.mkdir(user_dir+'/{}'.format(name))
        return DetectResult(code=const.CODE_DONE, message='Register Success')
    

def add_user_info(data,user_name,user_id,logging):
    filename_wav = "../static/user_voice/{0}/{1}.wav".format(user_name,user_id)
    logging.debug("User's Voice Direct: {}".format(filename_wav))
    try:           
        f = open(filename_wav,'wb')
        f.write(data)
        f.close
    except Exception as ex:
        logging.error(f'processing failed:',user_id)
        return DetectResult(code=const.CODE_SERVICE_UNAVAILABLE, message=const.MSG_SERVICE_UNAVAILABLE)
    return DetectResult(code=const.CODE_DONE, message=const.MSG_REG_SUCCESS)


def register_user_voice(user_name,user_id,logging):
    user_dir = const.USER_DIR +'/' + user_name
    logging.debug(" User directory is : {}".format(user_dir))
    res = vectorize_voice(user_dir,user_id,logging)
    if not res:
        return DetectResult(code=const.CODE_FAIL, message=const.MSG_FAIL)
    return DetectResult(code=const.CODE_DONE, message=const.MSG_SUCCESS)



