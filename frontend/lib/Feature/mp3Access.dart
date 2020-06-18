import 'package:flute_music_player/flute_music_player.dart';
import 'dart:math';

class Mp3Access{
  
  List<Song> _mp3Files;
  int _currentFileIndex = -1;
  MusicFinder musicFinder;

  Mp3Access(this._mp3Files) {
    musicFinder = new MusicFinder();
  }

  List<Song> get songs => _mp3Files;
  int get length => _mp3Files.length;
  int get songNumber => _currentFileIndex + 1;

  setCurrentIndex(int index) {
    _currentFileIndex = index;
  }

  int get currentIndex {
    if (_currentFileIndex == -1 || _currentFileIndex > _mp3Files.length)
      return 0;
    return _currentFileIndex;
  } 

  Song get nextSong {
    if (_currentFileIndex < length) {
      _currentFileIndex++;
    }
    if (_currentFileIndex >= length) _currentFileIndex = 0;
    return _mp3Files[_currentFileIndex];
  }

  Song get randomSong {
    Random r = new Random();
    _currentFileIndex = r.nextInt(_mp3Files.length);
    return _mp3Files[_currentFileIndex];
  }

  Song get prevSong {
    if (_currentFileIndex > 0) {
      _currentFileIndex--;
    }
    if (_currentFileIndex == 0) _currentFileIndex = _mp3Files.length - 1;
    return _mp3Files[_currentFileIndex];
  }

  MusicFinder get audioPlayer => musicFinder;
  
}