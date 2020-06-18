import 'dart:math';
// import 'package:MusicApp/OnlineFeature/httpTest.dart';
import 'package:MusicApp/Data/playlistModel.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:rxdart/rxdart.dart';

class InfoControllerBloC {

  BehaviorSubject<UserModel> _userInfo;
  BehaviorSubject<List<String>> playlists;

  BehaviorSubject<UserModel> get userInfo => _userInfo;

  InfoControllerBloC(){
    _initStreams();
  }
  
  void _initStreams(){
    UserModel initUser = UserModel(name: "Sang", email: "sangn2911@gmail.com", phone: "0935594725", coin: 0, isVip: 0); 
    _userInfo = BehaviorSubject<UserModel>.seeded(initUser);
    playlists = BehaviorSubject<List<String>>.seeded(["Playlist1", "Playlist2", "Playlist3"]);
  }


  Future<void> fetchPlaylists(String name) async {
    List<String> response = await fetchPlaylist(name);
    playlists.add(response);
  }

  void dispose(){
    playlists.close();
  }

  void saveUserInfo(UserModel userInfo){
    _userInfo.add(userInfo);
  }

  void changeUserName(String name){
    _userInfo.value.name = name;
  }
}