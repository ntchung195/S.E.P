import 'dart:ui';

import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:MusicApp/Data/songModel.dart';

import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/Feature/currentPlaying.dart';
import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';

import 'package:MusicApp/Custom/customText.dart';



class Playlists extends StatefulWidget {

  final MainControllerBloC mp;
  final UserModel userInfo;
  Playlists(this.mp, this.userInfo);

  @override
  _PlaylistsState createState() => _PlaylistsState();

}

class _PlaylistsState extends State<Playlists> {

  bool isUsed = false;

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
                  currentPlaying(widget.mp),
                ]
              )
            ),            
          ] 
        ),
      ),
    );
  }

  Widget body(){
    MainControllerBloC _mp = widget.mp;
    return Container(
      color: Colors.black,
      child: StreamBuilder(
        stream: _mp.infoBloC.playlists,
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
          return widget.mp.isUsed.value ? Container(height: 60) : Container();
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
      title: TextLato(playlist, Colors.white, 22, FontWeight.w700),
      trailing: moreSetting(playlist),
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

  Widget currentPlaying(MainControllerBloC mp){
    return StreamBuilder<bool>(
      stream: mp.isUsed,
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
                  builder: (context) => MusicPlayer(mp),
                )
              );
            },
            child: CurrentPlayBar(mp)
          );
      },
    );
  }

  final TextEditingController customController = TextEditingController(text: "");

  Future<String> createPlaylistPopUp(BuildContext context){
    return showDialog(
      context: context, 
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: TextLato("New playlist's name:",Colors.white, 20, FontWeight.w700),
            content: TextField(
              obscureText: false,
              controller: customController,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
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
                child: TextLato("Confirm",Colors.white, 20, FontWeight.w700),
                onPressed: () async{
                  List<String> playlists = await createPlaylist(customController.text, widget.userInfo.name);
                  widget.mp.infoBloC.playlists.add(playlists);
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                elevation: 5.0,
                  child: TextLato("Cancel",Colors.white, 20, FontWeight.w700),
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
      onSelected: (val){
        if (val == 1)
          songList(context, widget.mp, playlist);
        else print("Delete this playlist");
      },
//-----------------------------------------------------------
    );
  }


  Widget songPopUpMenu(String songTitle){
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
      onSelected: (val){
        if (val == 1)
          print("Song sample");
        else print("Delete this song");
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

  Future<String> songList(BuildContext context, MainControllerBloC mp, String playlist){
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
                    TextLato(playlist, ColorCustom.orange, 25, FontWeight.w500),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: widget.mp.infoBloC.currentPlaylist,
                    builder: (BuildContext context, AsyncSnapshot<List<SongItem>> snapshot){
                      if (!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      }
                      List<SongItem> playlists = snapshot.data;
                      //print(playlists);
                      if (playlists.length == 0){
                        return noPlaylist();
                      }
                      else
                        return listSongs(context, playlists);
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

  Widget listSongs(BuildContext context, List<SongItem> playlist){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: playlist.length,
      itemBuilder: (BuildContext context, int index){
        String songTitle = playlist[index].title;
        return songTile(songTitle);
        },                                     
    );
  }

  Widget songTile(String song){
    return ListTile(
      contentPadding: EdgeInsets.only(left: 30),
      leading: musicIcon(),
      title: TextLato(song, Colors.white, 22, FontWeight.w700),
      onTap: () async{

      },
      trailing: songPopUpMenu(song),
    );
  }

  Widget noSong(){
    return Center(
      child: TextLato("No song found", Colors.white, 19, FontWeight.w500)
    );
  }


}