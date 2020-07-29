import 'dart:convert';
import 'dart:math';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayerState { stopped, playing, paused }
enum PlayerMode { shuffle, repeat, normal }

class MusicPlayerBloC{


//List
  BehaviorSubject<List<Song>> onlineSongs;
  BehaviorSubject<List<Song>> recently;
  BehaviorSubject<List<Song>> favourite;

  BehaviorSubject<List<Song>> _offlineSongs;

//Boolean Value
  BehaviorSubject<bool> isUsed;
  BehaviorSubject<bool> fromDB; 
  bool isDispose = false;
  // List<Album> _albums;
  // List<Song> _currentPlayList;
  
//Music Player

  MusicFinder _audioPlayer;

  Duration _duration;
  BehaviorSubject<Duration> _position;

  BehaviorSubject<PlayerState> _playerState;
  BehaviorSubject<PlayerMode> _playerMode;

  BehaviorSubject<Song> _currentSong;
  BehaviorSubject<MapEntry<List<Song>, List<Song>>> _currPlaylist;
  
  BehaviorSubject<List<Song>> get songList => _offlineSongs;
  BehaviorSubject<MapEntry<List<Song>, List<Song>>> get currentPlaying => _currPlaylist;
  BehaviorSubject<Song> get currentSong => _currentSong;

  bool get isPlaying => _playerState.value == PlayerState.playing;
  bool get isPaused => _playerState.value == PlayerState.paused;

  bool get isShuffle => _playerMode.value == PlayerMode.shuffle;
  bool get isRepeat => _playerMode.value == PlayerMode.repeat;

  Duration get duration => _duration;
  BehaviorSubject<Duration> get position => _position;

  BehaviorSubject<PlayerState> get playerState => _playerState;
  BehaviorSubject<PlayerMode> get playerMode => _playerMode;

  MusicPlayerBloC(){
    _initStreams();
    _initAudioPlayer();
    _initCurrentSong();
    fetchSongs();
    fetchRecently();
  }

  void dispose(){
    isDispose = true;
    isUsed.close();
    fromDB.close();
  //Common stream
    _currPlaylist.close();
    _audioPlayer.stop();
    _position.close();
    _offlineSongs.close();
    _currentSong.close();
    _playerState.close();
    _playerMode.close();
    recently.close();

  //Online stream
    favourite.close();
    onlineSongs.close();
  }

  void _initStreams(){
    
    isUsed = BehaviorSubject<bool>.seeded(false);
    fromDB = BehaviorSubject<bool>.seeded(false);
    
    _currPlaylist = BehaviorSubject<MapEntry<List<Song>, List<Song>>>();
    _offlineSongs = BehaviorSubject<List<Song>>();
    recently = BehaviorSubject<List<Song>>.seeded([]);

    _position = BehaviorSubject<Duration>();

    _playerState = BehaviorSubject<PlayerState>.seeded(PlayerState.stopped);
    _playerMode = BehaviorSubject<PlayerMode>.seeded(PlayerMode.normal);

    onlineSongs = BehaviorSubject<List<Song>>();
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
      //_playerState.add(PlayerState.stopped);
      _duration = new Duration(seconds: 0);
      _position = BehaviorSubject<Duration>.seeded(Duration(seconds: 0));
    });
  }

  Future<void> fetchFromDB() async{
    await fetchFavourite();
    await fetchAllSongDB();
  }

  Future<void> fetchFavourite() async {
    print("Fectch Favourite");
    List<Song> _favourite = await getfavourite();
    if (_favourite != null)
      favourite.add(_favourite);
  }

  Future<void> fetchAllSongDB() async {
    print("Fectch Songs in DB");
    List<Song> songDBlist = await getSongDB();
    if (songDBlist != null)
      onlineSongs.add(songDBlist);
  }

  Future<void> fetchSongs() async {
    print("Fectch Songs");
    await MusicFinder.allSongs()
      .then(
        (songs) => _offlineSongs.add(songs)
      );
  }

  Future<void> fetchRecently() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _encodedStrings = _prefs.getStringList("Recently") ?? [];
    List<Song> _recently = [];
    for (String data in _encodedStrings){
      Song song = _decodeSongFromJson(data);
      _recently.add(song);
    }
    recently.add(_recently);
  }

  void updatePlaylist(List<Song> normalPlaylist) {
    List<Song> _shufflePlaylist = []..addAll(normalPlaylist);
    _shufflePlaylist.shuffle();
    _currPlaylist.add(MapEntry(normalPlaylist, _shufflePlaylist));
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

  void updateRecent(Song song) async {

    if (fromDB.value) {
      for (int i = 0; i < recently.value.length; i++)
        if (song.iD == recently.value[i].iD) return;
    }
    else {
      for (var x in recently.value){
        if (song.title == x.title && song.artist == x.artist) return;
      }
        
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _encodedStrings = _prefs.getStringList("Recently") ?? [];
    
    if (recently.value.length >= 10){
      recently.value.removeAt(recently.value.length-1);
      _encodedStrings.removeAt(recently.value.length-1);
    }

    recently.value.insert(0, song);
    recently.add(recently.value);
    _encodedStrings.insert(0,_encodeSongToJson(song));
    _prefs.setStringList("Recently", _encodedStrings);

  }

  String _encodeSongToJson(Song song) {
    final _songMap = songToMap(song);
    final data = json.encode(_songMap);
    return data;
  }

  Song _decodeSongFromJson(String ecodedSong) {
    final _songMap = json.decode(ecodedSong);
    final Song _song = songFromJson(_songMap);
    return _song;
  }

  Song songFromJson(Map map){
    return Song(
      map["id"], 
      map["artist"], 
      map["title"],
      map["album"],
      map["albumId"],
      map["duration"], 
      map["uri"],
      map["albumArt"],
      map["iD"]
    );
  }

  Map<String, dynamic> songToMap(Song song) {
    Map<String, dynamic> _map = {};
    _map["album"] = song.album;
    _map["id"] = song.id;
    _map["artist"] = song.artist;
    _map["title"] = song.title;
    _map["albumId"] = song.albumId;
    _map["duration"] = song.duration;
    _map["uri"] = song.uri;
    _map["albumArt"] = song.albumArt;
    _map["iD"] = song.iD;
    return _map;
  }

//Basic Function
  void handleSong(Song song) async{
    Song songPlay = song;

    if (song.iD != null) 
      fromDB.add(true);
    
    if (song.uri == null) {
      Song songDB = await getSong(song.iD);
      songDB.iD = song.iD;
      if (songDB == null) {
        print("Cant load song");
        return;
      }
      songPlay = songDB;
    }

    updateRecent(songPlay);
    _currentSong.add(songPlay);
    play();
  }

  void play() async{
    _playerState.add(PlayerState.playing);
    // _audioPlayer.setStartHandler(() { })
    final result = await _audioPlayer.play(_currentSong.value.uri, isLocal: false);
    if (result == 1) _playerState.add(PlayerState.playing);
  }

  void pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) _playerState.add(PlayerState.paused);
  }

  void stop() async{
    final result = await _audioPlayer.stop();
    if (result == 1) {
      _playerState.add(PlayerState.stopped);
      _position.add(Duration(seconds: 0));
    }
  }

  void next() async {
    stop();

    final List<Song> _playlist = isShuffle ? _currPlaylist.value.value : _currPlaylist.value.key;
    
    int index = 0;
    if (_currentSong.value.iD != null) {
      while (index < _playlist.length){
        if (_currentSong.value.iD == _playlist[index].iD){
          break;
        }
        index++;
      }
    }
    else
      index = _playlist.indexOf(_currentSong.value);

    if (index == -1) index = 0; //Song not in current playlist
    
    if (index + 1 == _playlist.length)
      index = 0;
    else
      index += 1;

    //print(_playlist[index].title);
    handleSong(_playlist[index]);
  }

  void prev() async {
    stop();

    final List<Song> _playlist =
            isShuffle ? _currPlaylist.value.value : _currPlaylist.value.key;
    
    int index = 0;
    if (fromDB.value == true) {
      while (index < _playlist.length){
        if (_currentSong.value.iD == _playlist[index].iD){
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

    handleSong(_playlist[index]);
  }

  void playRandomSong(){
    Random r = new Random();
    List<Song> songs = _offlineSongs.value;
    int nextIndex = r.nextInt(songs.length);
    while (_currentSong.value == songs[nextIndex])
      nextIndex = r.nextInt(songs.length);
    handleSong(songs[nextIndex]);
  }

  void onComplete() {
    stop();
    if (isRepeat)
      handleSong(_currentSong.value);
    else
      next();
  }


}