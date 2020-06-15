
// import 'package:MusicApp/Feature/currentPlaying.dart';
// import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Custom/custemText.dart';

class Library extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: Container(),
          title: TextLato("Library", Colors.white, 25, FontWeight.w700),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 35, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              ListTile(
                leading: Icon(
                  Icons.playlist_add,
                  size: 40,
                  color: ColorCustom.orange,
                ),
                title: TextLato("Create playlist", Colors.white, 22, FontWeight.w500),
              ),
              ListTile(
                leading: Icon(
                  Icons.star,
                  size: 40,
                  color: ColorCustom.orange,
                ),
                title: TextLato("Favourite Songs", Colors.white, 22, FontWeight.w500),
              ),
              ListTile(
                leading: Icon(
                  IconCustom.album_1,
                  size: 40,
                  color: ColorCustom.orange,
                ),
                title: TextLato("My Playlist", Colors.white, 22, FontWeight.w500),
              ),
            ]
          ),
        ),
      ),
    );
  }
}