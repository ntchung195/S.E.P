import os

from src.util.voice import *
from src.service.sql import create_user_song_list
from src.service.config_api import DetectResult
import src.const as const


def create_play_list(user_id,user_name,list_name,logging):
    if user_id is None or user_name is None:
        return DetectResult(code=const.CODE_USER_ID_NOT_VALID, message='User is not Valid')
    if list_name is None:
        return DetectResult(code=const.CODE_PLAYLIST_NOT_EXIST, message='Play list is not Valid')
    res = create_user_song_list(user_id,user_name,list_name)
    logging.info("query respond: {}".format(res))
    if res == False:
        return DetectResult(code=const.CODE_FAIL, message='Canot create play list')
    else:
        return DetectResult(code=const.CODE_DONE, message='Created {0} for {1}'.format(list_name,user_name))