import 'dart:math';
// import 'package:MusicApp/OnlineFeature/httpTest.dart';
import 'package:MusicApp/Data/playlistModel.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:rxdart/rxdart.dart';

import 'infoControllerBloC.dart';

enum PlayerState { stopped, playing, paused }
enum PlayerMode { shuffle, repeat, normal }

class MainControllerBloC{

  InfoControllerBloC infoBloC;

//List
  
  BehaviorSubject<List<SongItem>> favourite;

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
    isUsed.close();
    fromDB.close();
    isDispose = true;
    _audioPlayer.stop();
    playerState.close();
    playerMode.close();
    position.close();
    songList.close();
    currentSong.close();
    _songs.close();
    favourite.close();
    _playerState.close();
    _playerMode.close();
    _position.close();
    _currentSong.close();
  }

  void _initStreams(){
    isUsed = BehaviorSubject<bool>.seeded(false);
    fromDB = BehaviorSubject<bool>.seeded(false);
    _songs = BehaviorSubject<List<Song>>();
    favourite = BehaviorSubject<List<SongItem>>();
    //_albums = List<Album>();
    _position = BehaviorSubject<Duration>();
    //_favorites = [];
    _playerState = BehaviorSubject<PlayerState>.seeded(PlayerState.stopped);
    _playerMode = BehaviorSubject<PlayerMode>.seeded(PlayerMode.normal);
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
    List<SongItem> fav = await getfavourite();
    print(fav);
    favourite.add(fav);
  }




  Future<void> fetchSongs() async {
    print("Fectch Songs");
    await MusicFinder.allSongs()
      .then(
        (songs) => _songs.add(songs)
      );
  }

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
  play(Song song, {Playlist playlist}) {
    _currentSong.add(song);
    _audioPlayer.play(song.uri, isLocal: false);
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
    List<Song> songs = _songs.value;
    int index = songs.indexOf(_currentSong.value);
    //print(index);
    if (index == -1) index = 0;
    if (index + 1 == songs.length)
      _currentSong.add(songs[0]);
    else
      _currentSong.add(songs[index + 1]);
    play(songs[index + 1]);
  }

  Future prev() async {
    stop();
    List<Song> songs = _songs.value;
    int index = songs.indexOf(_currentSong.value);
    if (index - 1 == -1)
      _currentSong.add(songs[songs.length - 1]);
    else
      _currentSong.add(songs[index - 1]);
    play(_currentSong.value);
  }

  void playRandomSong(){
    Random r = new Random();
    List<Song> songs = _songs.value;
    int nextIndex = r.nextInt(songs.length);
    while (_currentSong.value == songs[nextIndex])
      nextIndex = r.nextInt(songs.length);
    _currentSong.add(songs[nextIndex]);
    play(_currentSong.value);
  }

  void onComplete() {
    stop();
    if (isRepeat)
      play(_currentSong.value);
    else if (isShuffle) {
      playRandomSong();   
    }
    else
      next();
  }


}