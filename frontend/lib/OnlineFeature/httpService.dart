import 'dart:convert';

//import 'package:MusicApp/Data/playlistModel.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

String url = 'http://25.19.229.40:5000/'; //localhost

Future<int> createUser(String email, String name, String password) async{

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

  print("Status Code: ${response.statusCode}");
  
  if (response.statusCode == 200){
    print("Response body: ${response.body}");
    return 0;
  }
  else if (response.statusCode == 400){
    print("Response body: ${response.body}");
    return 1;
  }
  else{
    print("Error: ${response.statusCode}");
    return 2;
  }
  
}

Future<UserModel> verifyUser(String name, String password) async{

  Map data = {
    "service": "login",
    "username": name,
    "password": password
  };

  String body = json.encode(data);

  final response = await http.post(url, 
    body: body,
  );

  print("Status Code: ${response.statusCode}");

  if (response.statusCode == 200){
    print("Response body: ${response.body}");
    UserModel userInfo = userModelFromJson(response.body);
    return userInfo;
  }
  else {
    print("Response body: ${response.body}");
    return null;
  }
  
}

createAlertDialog(String str, BuildContext context){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Center(
        child: Text(
          str,
          style: TextStyle(
            fontSize: 20,
            color: Colors.red
          ),
        ),
      ),
    );
  });
}