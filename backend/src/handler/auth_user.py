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
import src.const

def voice_recognite(user_name,user_id,log,tag = 'recognize'):
    user_directory = const.USER_DIR +'/' + user_name
    logging.info(" User directory is : {}".format(user_directory))
    filename_wav = user_directory + '/{0}_{1}.wav'.format(user_id,tag)
    res = verify_model(filename_wav,user_directory,logging)
    if not res:
        return DetectResult(code=const.CODE_FAIL, message=const.MSG_FAIL)
    return DetectResult(code=const.CODE_DONE, message=const.MSG_SUCCESS)