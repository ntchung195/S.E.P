import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:MusicApp/Custom/customText.dart';
import 'package:MusicApp/BloC/userBloC.dart';

import 'package:MusicApp/Data/userModel.dart';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

const CODE_DONE = 1000;
const CODE_FAIL = 1008;
const CODE_RECORD_SUCCESS = 1020;
const CODE_REGSITER_VOICE_SUCCESS = 1021;

const CODE_WORKING = 2000;
const CODE_TIMEOUT = 2001;

const USER_NOT_EXIST = 3003;

String url1 = 'http://25.19.229.40:5000/'; //localhost

String url2 = 'http://25.11.142.123:5000/';

String url = 'http://25.40.136.16:5000/';

String url3 = 'http://25.39.35.22:5000/';


//User Information

Future<int> createUser(String email, String name, String password) async {

  Map data = {
    "service": "signup",
    "email": email,
    "username": name,
    "password": password
  };  

  String body = json.encode(data);

  final response = await http.post(url,
    body: body,
  );

  // print("Status Code: ${response.statusCode}");
  // print("Response body in Create User: ${response.body}");
  
  if (response.statusCode == 200){
    return 0;
  }
  else if (response.statusCode == 400){
    return 1;
  }
  else{
    return 2;
  }
  
}


Future<MapEntry<UserModel,int>> verifyUser(String name, String password) async{
  
  try {
    Map data = {
      "service": "login",
      "username": name,
      "password": password
    };

    String body = json.encode(data);

    final response = await http.post(url, 
      body: body,
    ).timeout(Duration(seconds: 5));

    print("Status Code: ${response.statusCode}");
    print("Response body In Verify User: ${response.body}");

    if (response.statusCode == 200){
      var jsondecode = json.decode(response.body);
      UserModel userInfo = userModelFromJson(jsondecode["data"]);
      return MapEntry<UserModel,int>(userInfo,CODE_WORKING);
    }
    else {
      return MapEntry<UserModel,int>(null,USER_NOT_EXIST);
    }
  } on TimeoutException catch (_){
    return MapEntry<UserModel,int>(null,CODE_TIMEOUT);
  } on SocketException catch (_){
    print("Socker Exception At Verify User");
    return MapEntry<UserModel,int>(null,CODE_TIMEOUT);
  }
}

Future<bool> logOut(String name) async{

  try {  
    Map data = {
      "service": "logout",
      "username": name,
    };

    String body = json.encode(data);

    final response = await http.post(url, 
      body: body,
    ).timeout(Duration(seconds: 5));

    print("Status Code: ${response.statusCode}");
    print("Response body In Log Out: ${response.body}");

    if (response.statusCode == 200){
      return true;
    }
    else {
      return false;
    }
  } on SocketException catch (_) {
    print("Log Out Fail");
    return null;
  }

}

Future<UserModel> getUserInfo(String name) async{

  Map data = {
    "username": name,
  };

  String body = json.encode(data);

  final response = await http.post(url + "getUserInfo",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Response body In Verify User: ${response.body}");

  if (response.statusCode == 200){
    var jsondecode = json.decode(response.body);
    UserModel userInfo = userModelFromJson(jsondecode["data"]);
    return userInfo;
  }
  else {
    return null;
  }
  
}

// Voice Authentication

Future<int> prepareVoice(String username, String id) async{

  Map data = {
    "username": username,
    "user_id": id
  };

  String body = json.encode(data);

  final response = await http.post(url + "enroll", 
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body PrepareVoice: ${response.body}");

  var jsondecode = json.decode(response.body);

  if (response.statusCode == 200){
    if (jsondecode["code"] == 1006) return 3;
    return 0;
  }
  else {
    return 1;
  }

}

Future<int> voiceAuthentication(int count, String username, String id, String tag ,File file) async{

  Uint8List bytes = file.readAsBytesSync();

  Map data = {
    "username": username,
    "user_id": id,
    "count": count,
    "tag": tag,
    "user_data": bytes,
  };

  String body = json.encode(data);

  final response = await http.post(url + "voice", 
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body verifyVoice: ${response.body}");

  if (response.statusCode == 200){
    if (tag == "recognize"){
      int result = await verifyVoice(username, id);
      if (result == 2) return 2;
    }
    return 0;
  }
  else {
    return 1;
  }

}

Future<int> verifyVoice(String username, String id) async{

  //Uint8List bytes = file.readAsBytesSync();

  Map data = {
    "username": username,
    "user_id": id,
  };

  String body = json.encode(data);

  final response = await http.post(url + "verify",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body verifyVoice: ${response.body}");

  var jsondecode = json.decode(response.body);

  if (response.statusCode == 200){

    if (jsondecode["code"] == 1008){
      return 2;
    }
    return 0;
  }
  else {
    return 1;
  }

}


// Purchase

Future<int> buyVipAndSong(UserBloC userBloC, String password ,String type, int coin, {String songID = ""}) async{

  Map data;
  if(type == "status"){
    data = {
      "service": "purchase",
      "username": userBloC.userInfo.value.name,
      "password": password,
      "type": type,
      "name": "VIP",
      "coin": coin,
    };
  } else {
    data = {
      "service": "purchase",
      "username": userBloC.userInfo.value.name,
      "password": password,
      "type": type,
      "name": songID,
      "coin": coin,
    };
  }

  String body = json.encode(data);

  final response = await http.post(url, 
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Message: ${response.body}");
  var jsondecode = json.decode(response.body);

  if (response.statusCode == 200){
    userBloC.userInfo.value.isVip = 1;
    userBloC.userInfo.value.coin = jsondecode["data"]["coin"];
    userBloC.userInfo.add(userBloC.userInfo.value);
    return 0;
  }
  else if(jsondecode["message"] == "Not enough coin!"){
    return 1;
  }
  else if(jsondecode["code"] == 1008){
    return 2;
  }
  else 
    return 3;

}

Future<int> transactionForCoin(UserBloC userBloC, int coin) async{

  Map data = {
    "username": userBloC.userInfo.value.name,
    "coin": coin,
  };

  String body = json.encode(data);

  final response = await http.post(url + "bank", 
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Message: ${response.body}");
  var jsondecode = json.decode(response.body);

  if (response.statusCode == 200){
    userBloC.userInfo.value.coin = jsondecode["coin"];
    userBloC.userInfo.add(userBloC.userInfo.value);
    return 0;
  }
  else {
    return 1;
  }

}

Future<int> updateInfo(UserBloC _infoBloC, String value, String username, String service) async{
  
  Map data = {};
  UserModel initUser;

  if (service == "updateEmail") {
    data = {
      "service": service,
      "username": username,
      "email": value,
    };
  }
  else if (service == "updatePhone"){
    data = {
      "service": service,
      "username": username,
      "phone": value,
    };
  } 

  String body = json.encode(data);

  final response = await http.post(url + "update",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Update Body: ${response.body}");

  UserModel userInfo = _infoBloC.userInfo.value;
  if (response.statusCode == 200){
    
    if (service == "updateEmail"){
      String value = json.decode(response.body)["email"];
      initUser = UserModel(name: userInfo.name, email: value, phone: userInfo.phone, coin: userInfo.coin, isVip: userInfo.isVip); 
    }
    else if (service == "updatePhone"){
      String value = json.decode(response.body)["phone"];
      initUser = UserModel(name: userInfo.name, email: userInfo.email, phone: value, coin: userInfo.coin, isVip: userInfo.isVip);
    }

    _infoBloC.saveUserInfo(initUser);
    return 1;
  }
  else {
    return 0;
  }

}

//Activity with song database

Future<List<Song>> getSongDB() async {

  try {    
    final response = await http.get(url + "getSongList").timeout(Duration(seconds: 5));

    print("Status Code: ${response.statusCode}");
    // print("Body Song: ${response.body}");

    if (response.statusCode == 200) {
      var jsondecode = json.decode(response.body);
      List<Song> songs = List<Song>.from(jsondecode["data"].map((x) => Song.fromJson(x)));
      return songs;
    }
    else if (response.statusCode == 400) {
      var jsondecode = json.decode(response.body);
      if (jsondecode["code"] == 1008)
        return [];

    }
    else return [];
  } on TimeoutException catch (_) {
    print("Timeout");
    return [null];
  }
  return null;
}

Future<List<Song>> getfavourite() async {

  Map data = {
    "service": "favouriteLst",
  };

  String body = json.encode(data);

  try {
    final response = await http.post(url + "song",
      body: body,
    ).timeout(Duration(seconds: 5));

    print("Status Code: ${response.statusCode}");
    // print("Body Favourite: ${response.body}");
    
    if (response.statusCode == 200){
      var jsondecode = json.decode(response.body);
      List<Song> songs = List<Song>.from(jsondecode["favourite"].map((x) => Song.fromJson(x)));
      return songs;
    }
    else {
      return [];
    }
  } on TimeoutException catch (_){
    print("Timeout");
    return [null];
  } on SocketException catch (_){
    print("Socket Exception");
    return [null];
  }

}

Future<Song> getSong(String id) async{

  Map data = {
    "service": "songLink",
    "_id": id,
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body Song: ${response.body}");

  if (response.statusCode == 200){
    
    var jsondecode = json.decode(response.body);
    Song song = Song(
      null, 
      jsondecode["artist"] == null ? "Unknown" : jsondecode["artist"], 
      jsondecode["title"] == null ? "Unknown" : jsondecode["title"], 
      "Unknown",
      null, 
      100, 
      jsondecode["link"],
      null,
      id,
      );

    return song;
  }
  else {
    return null;
  }

}

Future<List<String>> fetchPlaylist(String username) async{

  Map data = {
    "service": "myPlaylist",
    "username": username,
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    var jsondecode = json.decode(response.body);
    List<dynamic> playlists = jsondecode;
    List<String> result = playlists.cast<String>().toList();
    return result;
  }
  else {
    return null;
  }

}


Future<List<String>> createPlaylist(String name, String username) async{

  Map data = {
    "service": "createPlaylist",
    "playlistname": name,
    "username": username,
  };


  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body Playlist: ${response.body}");

  if (response.statusCode == 200) {
    

    if (response.body == "Duplicated") return [""];

    var jsondecode = json.decode(response.body);
    print("Body Create Playlist: $jsondecode");

    List<dynamic> playlists = jsondecode;
    List<String> result = playlists.cast<String>().toList();
    return result;
  }
  else {
    return null;
  }

}

Future<int> deletePlaylist(String playlistname, String username) async{

  Map data = {
    "service": "deletePlaylist",
    "playlistName": playlistname,
    "username": username,
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");  

  if (response.statusCode == 200) {
    print("Body Playlist: ${response.body}");
    // var jsondecode = json.decode(response.body);
    int result = 1;
    return result;
  }
  else {
    return null;
  }

}


Future<int> playlistAdd(String playlistName, String username, String id) async{

  Map data = {
    "service": "addSong",
    "playlistName": playlistName,
    "username": username,
    "_id": id,
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body Playlist Add: ${response.body}");

  if (response.statusCode == 200){
    if (response.body == "Duplicated") return 2; 
    return 1;
  }
  else {
    return 0;
  }

}

Future<int> playlistDelete(String playlist, String username, String id) async{

  Map data = {
    "service": "delSong",
    "playlistName": playlist,
    "username": username,
    "_id": id,
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body Playlist Delete: ${response.body}");

  if (response.statusCode == 200){
    //var jsondecode = json.decode(response.body);
    return 1;
  }
  else {
    return 0;
  }

}


Future<List<Song>> getPlaylist(String username, String playlistname) async{

  Map data = {
    "service": "fetchPlaylist",
    "username": username,
    "playlistName": playlistname
  };

  String body = json.encode(data);

  final response = await http.post(url + "song",
    body: body,
  );

  print("Status Code: ${response.statusCode}");
  print("Body Fetch Playlist: ${response.body}");

  if (response.statusCode == 200){
    var jsondecode = json.decode(response.body);
    List<Song> songs = List<Song>.from(jsondecode.map((x) => Song.fromJson(x)));
    //print("playlist: $songs");
    return songs;
  }
  else {
    return [];
  }
}

createAlertDialog(String str, BuildContext context){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Center(
        child: TextLato(str, Colors.red, 20, FontWeight.w700),
      ),
    );
  });
}

//request /getSongList
