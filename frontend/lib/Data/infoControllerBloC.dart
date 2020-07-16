// import 'dart:math';
// import 'package:MusicApp/OnlineFeature/httpTest.dart';
// import 'package:MusicApp/Data/playlistModel.dart';
// import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/Data/playlistModel.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
//import 'package:flute_music_player/flute_music_player.dart';
import 'package:rxdart/rxdart.dart';

class InfoControllerBloC {

  BehaviorSubject<UserModel> _userInfo;
  BehaviorSubject<List<String>> playlists;
  BehaviorSubject<List<SongItem>> currentPlaylist;
  BehaviorSubject<String> currentId;

  BehaviorSubject<UserModel> get userInfo => _userInfo;

  InfoControllerBloC(){
    _initStreams();
  }
  
  void _initStreams(){
    UserModel initUser = UserModel(name: "Sang", email: "sangn2911@gmail.com", phone: "0935594725", coin: 0, isVip: 0); 
    _userInfo = BehaviorSubject<UserModel>.seeded(initUser);
    playlists = BehaviorSubject<List<String>>();

    SongItem initSong = SongItem(id: "", title: "Song Sample", artist: "Unknown");
    Playlist playlist = Playlist(name: "Playlist 1", songlist: [initSong, initSong, initSong]);
    currentId = BehaviorSubject<String>();
    currentPlaylist = BehaviorSubject<List<SongItem>>.seeded(playlist.songlist);
  }


  Future<void> fetchPlaylists(String name) async {
    List<String> response = await fetchPlaylist(name);
    print(response);
    playlists.add(response);
  }

  void dispose(){
    currentId.close();
    playlists.close();
    currentPlaylist.close();
  }

  void saveUserInfo(UserModel userInfo){
    _userInfo.add(userInfo);
  }

  void changeUserName(String name){
    _userInfo.value.name = name;
  }
}