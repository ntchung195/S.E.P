import 'dart:math';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:rxdart/rxdart.dart';

import 'infoControllerBloC.dart';

enum PlayerState { stopped, playing, paused }
enum PlayerMode { shuffle, repeat, normal }

class MainControllerBloC{

  InfoControllerBloC infoBloC;
  BehaviorSubject<List<Song>> songfromDB;

//List
  
  BehaviorSubject<List<Song>> favourite;

//List management
  BehaviorSubject<bool> isUsed;
  BehaviorSubject<bool> fromDB; 
  BehaviorSubject<List<Song>> _songs;
  bool isDispose = false;
  // List<Album> _albums;
  // List<Song> _favorites;
  // List<Song> _recently;
  // List<Song> _currentPlayList;
  
//Music Player Controller (Offline)

  MusicFinder _audioPlayer;
  Duration _duration;
  BehaviorSubject<Duration> _position;

  BehaviorSubject<PlayerState> _playerState;
  BehaviorSubject<PlayerMode> _playerMode;

  BehaviorSubject<Song> _currentSong;
  BehaviorSubject<MapEntry<List<Song>, List<Song>>> _currPlaylist;
  BehaviorSubject<MapEntry<List<SongItem>, List<SongItem>>> _currPlaylistOnline;
  
  BehaviorSubject<List<Song>> get songList => _songs;
  BehaviorSubject<Song> get currentSong => _currentSong;

  bool get isPlaying => _playerState.value == PlayerState.playing;
  bool get isPaused => _playerState.value == PlayerState.paused;

  bool get isShuffle => _playerMode.value == PlayerMode.shuffle;
  bool get isRepeat => _playerMode.value == PlayerMode.repeat;

  Duration get duration => _duration;
  BehaviorSubject<Duration> get position => _position;

  BehaviorSubject<PlayerState> get playerState => _playerState;
  BehaviorSubject<PlayerMode> get playerMode => _playerMode;

  MainControllerBloC(){
    infoBloC = InfoControllerBloC();
    _initStreams();
    _initAudioPlayer();
    _initCurrentSong();
  }

  void dispose(){
    isDispose = true;
    isUsed.close();
    fromDB.close();
  //Common stream
    _currPlaylist.close();
    _currPlaylistOnline.close();
    _audioPlayer.stop();
    _position.close();
    _songs.close();
    _currentSong.close();
    _playerState.close();
    _playerMode.close();

  //Online stream
    favourite.close();
    songfromDB.close();
  }

  void _initStreams(){
    
    isUsed = BehaviorSubject<bool>.seeded(false);
    fromDB = BehaviorSubject<bool>.seeded(false);
    
    _currPlaylist = BehaviorSubject<MapEntry<List<Song>, List<Song>>>();
    _currPlaylistOnline = BehaviorSubject<MapEntry<List<SongItem>, List<SongItem>>>();
    _songs = BehaviorSubject<List<Song>>();
    

    _position = BehaviorSubject<Duration>();

    _playerState = BehaviorSubject<PlayerState>.seeded(PlayerState.stopped);
    _playerMode = BehaviorSubject<PlayerMode>.seeded(PlayerMode.normal);

    songfromDB = BehaviorSubject<List<Song>>();
    favourite = BehaviorSubject<List<Song>>();

  }

  void _initCurrentSong() {
    Song initSong = Song(
      null,
      " ",
      " ",
      " ",
      null,
      null,
      null,
      null,
      null,
    );
    _currentSong = BehaviorSubject<Song>.seeded(initSong);
  }

  void _initAudioPlayer() {
    _audioPlayer = MusicFinder();

    _audioPlayer.setPositionHandler(
      (Duration position) {
        updatePosition(position);
      },
    );

    _audioPlayer.setDurationHandler(
      (Duration dur) {
        _duration = dur;
      },
    );

    _audioPlayer.setCompletionHandler(
      () {
        onComplete();
      },
    );

    _audioPlayer.setErrorHandler((msg) {
      _playerState.add(PlayerState.stopped);
      _duration = new Duration(seconds: 0);
      _position = BehaviorSubject<Duration>.seeded(Duration(seconds: 0));
    });
  }

  Future<void> fetchFavourite() async {
    List<Song> _favourite = await getfavourite();
    print(_favourite);
    favourite.add(_favourite);
  }

  Future<void> fetchSongs() async {
    print("Fectch Songs");
    await MusicFinder.allSongs()
      .then(
        (songs) => _songs.add(songs)
      );
  }

  void updatePlaylist(List<Song> normalPlaylist) {
    int count = 0;
    List<String> _print = [];
    while (count < 6){
      _print = _print + [normalPlaylist[count].title];
      count++;
    }
    print("Songs : $_print");

    List<Song> _shufflePlaylist = []..addAll(normalPlaylist);
    _shufflePlaylist.shuffle();
    _currPlaylist.add(MapEntry(normalPlaylist, _shufflePlaylist));
  }

  // void updatePlaylistOnline(List<SongItem> normalPlaylist) {
  //   List<SongItem> _shufflePlaylist = []..addAll(normalPlaylist);
  //   _shufflePlaylist.shuffle();
  //   _currPlaylistOnline.add(MapEntry(normalPlaylist, _shufflePlaylist));
  // }

  void playMode(int mode){
    if (mode == 0)
      _playerMode.add(PlayerMode.normal);
    else if (mode == 1)
      if (!isRepeat)
        _playerMode.add(PlayerMode.repeat);
      else
        _playerMode.add(PlayerMode.normal);
    else 
      if (!isShuffle)
        _playerMode.add(PlayerMode.shuffle);
      else
        _playerMode.add(PlayerMode.normal);
  }

  void updatePosition(Duration position) {
    _position.add(position);
  }

  void audioSeek(double seconds) {
    _audioPlayer.seek(seconds);
  }

//Basic Function
  playSong(Song song) async{
    Song songPlay = song;
    if (song.uri == null) {
      Song songDB = await getSong(song.iD);
      if (songDB == null) {
        print("Cant load song");
        return;
      }
      songPlay = songDB;
    }
    _currentSong.add(songPlay);
    _audioPlayer.play(songPlay.uri, isLocal: false);
    _playerState.add(PlayerState.playing);
  }

  Future<void> pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) _playerState.add(PlayerState.paused);
  }

  Future<void> stop() async{
    final result = await _audioPlayer.stop();
    if (result == 1) {
      _playerState.add(PlayerState.stopped);
      _position.add(Duration(seconds: 0));
    }
  }

  Future<void> next() async {
    stop();

    final List<Song> _playlist = isShuffle ? _currPlaylist.value.value : _currPlaylist.value.key;
    
    int index = 0;
    if (fromDB.value == true) {
      while (index < _playlist.length){
        if (_currentSong.value.title == _playlist[index].title && _currentSong.value.artist == _playlist[index].artist){
          break;
        }
        index++;
      }
    }
    else
      index = _playlist.indexOf(_currentSong.value);
    //print("Index: $index");

    if (index == -1) index = 0; //Song not in current playlist
    
    if (index + 1 == _playlist.length)
      index = 0;
    else
      index += 1;

    //print("Shuffle: ${_currPlaylist.value.value}");

    // int count = 0;
    // List<String> _print = [];
    // while (count < 6){
    //   _print = _print + [_playlist[count].title];
    //   count++;
    // }

    // print(_print);

    print(_playlist[index].title);
    playSong(_playlist[index]);
  }

  Future prev() async {
    stop();

    final List<Song> _playlist =
            isShuffle ? _currPlaylist.value.value : _currPlaylist.value.key;
    
    int index = 0;
    if (fromDB.value == true) {
      while (index < _playlist.length){
        if (_currentSong.value.title == _playlist[index].title && _currentSong.value.artist == _playlist[index].artist){
          break;
        }
        index++;
      }
    }
    else
      index = _playlist.indexOf(_currentSong.value);
    if (index == 0)
      index = _playlist.length - 1;
    else
      index -= 1;

    playSong(_playlist[index]);
  }

  void playRandomSong(){
    Random r = new Random();
    List<Song> songs = _songs.value;
    int nextIndex = r.nextInt(songs.length);
    while (_currentSong.value == songs[nextIndex])
      nextIndex = r.nextInt(songs.length);
    playSong(songs[nextIndex]);
  }

  void onComplete() {
    stop();
    if (isRepeat)
      playSong(_currentSong.value);
    else
      next();
  }


}