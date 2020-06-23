import os

from src.util.voice import *
from src.service.sql import get_list
from src.service.config_api import DetectResult
import src.const as const

def get_song_path(song,logging):
    if song is None:
        return DetectResult(code=const.CODE_NAME_NOT_EXIST, message='Song id not valid')
    try:
        song_dir = os.path.abspath(const.SONG_DIR)
        logging.debug("the song dir : {}".format(song_dir))
        full_song_path = song_dir + "/{}.mp3".format(song)
        
        logging.debug("Full song  path : {}".format(full_song_path))
        if os.path.isfile(full_song_path):
            return DetectResult(code=const.CODE_DONE,data = song_dir, message='Found Song')
        else:
            return DetectResult(code=const.CODE_SONG_NOT_EXIST,data = song_dir, message='song {} is not  exist'.format(song))
    except  Exception as ex:
        logging.error("This {} not exist")

def get_song_list(logging):

    song_list = get_list()
    logging.info("song list res: {}".format(song_list))
    if song_list is None or len(song_list) == 0:
        return DetectResult(code=const.CODE_FAIL, message='Server song is empty')
    else:
        return DetectResult(code=const.CODE_DONE,data = song_list, message='Found song list')
