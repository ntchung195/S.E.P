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
import src.const as const

def voice_recognite(user_name,user_id,logging,tag = 'recognize'):
    user_directory = const.USER_DIR +'/' + user_name
    logging.info(" User directory is : {}".format(user_directory))
    register_gmm = user_directory + '/{0}.gmm'.format(user_id)
    regconize_wav = user_directory + '/{0}_{1}.wav'.format(user_id,tag)

    res,score = verify_model(register_gmm,regconize_wav,logging)
    if not res:
        return DetectResult(code=const.CODE_FAIL,score_auth = 1 + score,data = res, message="cannot recognize user, recognize again!")
    return DetectResult(code=const.CODE_DONE,score_auth = 1 + score,data = res, message="recognize success")