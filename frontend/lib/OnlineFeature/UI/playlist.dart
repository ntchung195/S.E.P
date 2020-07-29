import 'dart:ui';

import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:MusicApp/BloC/userBloC.dart';
import 'package:MusicApp/Feature/currentPlaying.dart';
import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';

import 'package:MusicApp/Custom/customText.dart';

class Playlists extends StatefulWidget {

  final GlobalBloC gBloC;
  Playlists(this.gBloC);

  @override
  _PlaylistsState createState() => _PlaylistsState();

}

class _PlaylistsState extends State<Playlists> {

  bool isUsed = false;
  GlobalBloC globalBloC;
  UserBloC userBloC;
  MusicPlayerBloC mpBloC;

  @override
  void initState() {
    super.initState();
    globalBloC = widget.gBloC;
    userBloC = globalBloC.userBloC;
    mpBloC = globalBloC.mpBloC;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: BackButton(
            color: Colors.white,
            onPressed: (){
              Navigator.pop(context);
            }
          ),
          title: TextLato("My Playlists", Colors.white, 22, FontWeight.w700),
        ),
        body: Stack(
          children: <Widget>[
            body(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: <Widget> [
                  currentPlaying(),
                ]
              )
            ),            
          ] 
        ),
      ),
    );
  }

  Widget body(){
    return Container(
      color: Colors.black,
      child: StreamBuilder(
        stream: userBloC.playlists,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot){
          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          }
          List<String> playlists = snapshot.data;
          print(playlists);
          
          if (playlists.length == 0){
            return noPlaylist();
          }
          else
            return listPlaylist(context, playlists);
        }
      )
    );
  }

  Widget listPlaylist(BuildContext context, List<String> playlists){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: playlists.length + 2,
      itemBuilder: (BuildContext context, int index){
        if (index == playlists.length) 
          return Container(
            height: 60,
            child: Center(
              child: createPlaylistButton(),
            ),
          );
        if (index == playlists.length + 1) 
          return mpBloC.isUsed.value ? Container(height: 60) : Container();
        String playlist = playlists[index];
        return playListCard(playlist);
        },                                     
    );
  }

  Widget playListCard(String playlist){
    return ListTile(
      contentPadding: EdgeInsets.only(left: 40, right: 20),
      leading: Icon(
        Icons.library_music,
        color: ColorCustom.orange,
        size: 45,
      ),
      onTap: () async {
        List<Song> songs = await getPlaylist(userBloC.userInfo.value.name, playlist);
        mpBloC.isUsed.add(true);
        mpBloC.updatePlaylist(songs);
        mpBloC.stop();
        mpBloC.handleSong(songs[0]);
      },
      title: TextLato(playlist, Colors.white, 22, FontWeight.w700),
      trailing: moreSetting(playlist),
    );
  }

  Widget moreSetting(String playlist){
    return PopupMenuButton<int>(
      color: ColorCustom.grey,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 30.0,
      ),
      itemBuilder: (BuildContext context) 
        => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: Text(
                "Open",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                )
              ),
            )
      ],
//Function for Upload and Add to playlist
      onSelected: (val) async{
        if (val == 1){
          List<Song> songs = await getPlaylist(userBloC.userInfo.value.name, playlist);
          userBloC.currentPlaylist.add(songs);
          songList(context, playlist);
        }
          
        else {
          print("Delete this playlist");
          int result = await deletePlaylist(playlist, userBloC.userInfo.value.name);
          if (result == 1) {
            createAlertDialog("Delete $playlist Successfully", context);
            userBloC.playlists.value.remove(playlist);
            userBloC.playlists.add(userBloC.playlists.value);
          }
          else {
            createAlertDialog("Fail to delete", context);
          }
        }
      },
//-----------------------------------------------------------
    );
  }


  Widget noPlaylist(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          TextLato("No playlist found.", Colors.white, 19, FontWeight.w500),
          TextLato("Create new one?", Colors.white, 18, FontWeight.w500),
          createPlaylistButton(),
        ]
      )
    );
  }

  Widget createPlaylistButton(){
    return ButtonTheme(
      height: 31,
      minWidth: 158,
      buttonColor: ColorCustom.orange,
      child: RaisedButton(
        onPressed: ((){
          createPlaylistPopUp(context);
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)
        ),
        child: Text(
          "Create a playlist",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget currentPlaying(){
    return StreamBuilder<bool>(
      stream: mpBloC.isUsed,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
        if (!snapshot.hasData){
          return Container();
        }
        return !snapshot.data
          ? Container()
          : GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayer(globalBloC),
                )
              );
            },
            child: CurrentPlayBar(globalBloC)
          );
      },
    );
  }

  final TextEditingController customController = TextEditingController(text: "");

  Future<String> createPlaylistPopUp(BuildContext context){
    return showDialog(
      context: context, 
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: ColorCustom.grey,
            title: TextLato("New playlist's name:",ColorCustom.orange, 20, FontWeight.w700),
            content: TextField(
              obscureText: false,
              controller: customController,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                color: ColorCustom.orange,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                )
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: TextLato("Confirm",ColorCustom.orange, 20, FontWeight.w700),
                onPressed: () async {
                  print("Username: ${userBloC.userInfo.value.name}");
                  List<String> playlists = await createPlaylist(customController.text, userBloC.userInfo.value.name);
                  if (playlists[0] == "") createAlertDialog("Playlist Exists", context);
                  else if (playlists == null) createAlertDialog("Server Error", context);
                  else {
                    userBloC.playlists.add(playlists);
                    Navigator.pop(context);
                    createAlertDialog("Playlist ${customController.text} created", context);
                  }
                },
              ),
              MaterialButton(
                elevation: 5.0,
                  child: TextLato("Cancel",ColorCustom.orange, 20, FontWeight.w700),
                onPressed: (){
                  Navigator.of(context).pop(customController.text.toString());
                },
              )
            ],
          ),
        );
      }
    );
  }

  Widget songPopUpMenu(Song song, List<Song> songs, String playlist){
    return PopupMenuButton<int>(
      color: ColorCustom.grey,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 30.0,
      ),
      itemBuilder: (BuildContext context) 
        => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: Text(
                "Play",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                )
              ),
            )
      ],
//Function for Upload and Add to playlist
      onSelected: (val) async{
        if (val == 1){
          mpBloC.isUsed.add(true);
          mpBloC.updatePlaylist(songs);
          mpBloC.stop();
          mpBloC.handleSong(song);
        }
        else {
          int result = await playlistDelete(playlist, userBloC.userInfo.value.name, song.iD);
          if (result == 1) {
            songs.remove(song);
            userBloC.currentPlaylist.add(songs);
            createAlertDialog("Delete Successfully", context);
          }
          else {
            createAlertDialog("Delete Fail", context);
          }
        }
      },
//-----------------------------------------------------------
    );
  }



  Widget musicIcon(){
    return Container(
      height: 51,
      width: 47,
      decoration: BoxDecoration(
        color: ColorCustom.orange,
        border: Border.all(
        color: Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.black,
        size: 45,
      ),
    );
  }

  Future<String> songList(BuildContext context, String playlistname){
    return showDialog(
      context: context, 
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Dialog(
            insetPadding: EdgeInsets.only(left: 50, right: 50, top: 100, bottom: 100),
            backgroundColor: ColorCustom.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextLato(playlistname, ColorCustom.orange, 25, FontWeight.w500),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: userBloC.currentPlaylist,
                    builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
                      if (!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      }
                      List<Song> songs = snapshot.data;
                      //print(playlists);
                      if (songs.length == 0){
                        return Container(
                          child: Center(
                            child: TextLato("Song Not Found", Colors.white, 20, FontWeight.w700),
                          )
                        );
                      }
                      else {
                        return listSongs(context, songs, playlistname);
                      }
                    }
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget listSongs(BuildContext context, List<Song> songs,  String playlist){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index){
        //String songTitle = playlist[index].title;
        return songTile(songs[index], songs, playlist);
        },                                     
    );
  }

  Widget songTile(Song song, List<Song> songs, String playlist){
    return ListTile(
      contentPadding: EdgeInsets.only(left: 30),
      leading: musicIcon(),
      title: TextLato(song.title, Colors.white, 22, FontWeight.w700),
      subtitle: TextLato(song.artist, Colors.grey, 17, FontWeight.w500),
      onTap: () async{

        mpBloC.isUsed.add(true);
        mpBloC.updatePlaylist(songs);
        mpBloC.stop();
        mpBloC.handleSong(song);

      },
      trailing: songPopUpMenu(song, songs, playlist),
    );
  }

  Widget noSong(){
    return Center(
      child: TextLato("No song found", Colors.white, 19, FontWeight.w500)
    );
  }


}