import 'dart:ui';

import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/userBloC.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:rxdart/rxdart.dart';
import 'package:MusicApp/Custom/customText.dart';


class MusicPlayer extends StatefulWidget {

  final GlobalBloC globalBloC;
  MusicPlayer(this.globalBloC);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {

//BloC--------------------------------
  UserBloC userBloC;
  MusicPlayerBloC mpBloC;

// Button play
  Icon iconPlay = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );
// Button pause
  Icon iconPause = Icon(
    Icons.pause_circle_filled,
    color: Colors.white,
  );

  Widget dropDownButton (){
    return Icon(
      Icons.arrow_drop_down,
      color: Colors.white,
      size: 40,
    );
  }

  @override
  void initState() {
    super.initState();
    userBloC = widget.globalBloC.userBloC;
    mpBloC = widget.globalBloC.mpBloC;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(0),
            ),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: dropDownButton(),
            onPressed: (){
              Navigator.pop(context);
            }
          ),
          title: TextLato("Music Player", Colors.white, 25, FontWeight.w700),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 30,
              icon: Icon(
                Icons.format_list_bulleted,
                color: Colors.white,
              ), 
              onPressed: (){
                currentPlaylist(context);
              }
            ),
            //SizedBox(width: 9),
          ],
        ),
        body: body()
      ),
    );
  }

  Widget body(){
    return Center(
      child: Column(
          children: <Widget>[
            SizedBox(height: SizeConfig.screenHeight*28/640),
            imageDecoration(),
            //albumArtCover(),
            SizedBox(height: SizeConfig.screenHeight*28/640),
            songInfo(),
            SizedBox(height: SizeConfig.screenHeight*20/640),
            favoritePlayListButton(),
            musicControl(),
          ],
        ),
    );
  }

  Widget imageDecoration(){
    return Icon(
      IconCustom.album_1,
      size: 200,
      color: ColorCustom.deepOrange,
    );
  }

  Widget albumArtCover(){
    return Container(
      child: StreamBuilder<Song>(
        stream: mpBloC.currentSong,
        builder: (BuildContext context, AsyncSnapshot<Song> snapshot){
          if (!snapshot.hasData || snapshot.data.albumArt == null){
            return  imageDecoration();
          }
          Song currSong = snapshot.data;
          return Container(
            height: 200,
            width: 200,
            child: Image(
              fit: BoxFit.fill,
              image: AssetImage(
                currSong.albumArt,
              )
            ),
          );

        }
      )
    );
  }

  Widget songInfo(){
    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: StreamBuilder<Song>(
        stream: mpBloC.currentSong,
        builder: (BuildContext context, AsyncSnapshot<Song> snapshot){
          if (!snapshot.hasData){
            return Container();
          }
          Song currentSong = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                text(currentSong.title, true ,Colors.white, 25, FontWeight.w700),
                text(currentSong.artist, true , ColorCustom.grey1, 19, FontWeight.w400),
            ],
          );
        },
      )
    );
  }

  Widget favoritePlayListButton(){
    return Row(                                                              //Playlist and RateButton
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          iconSize: 30,
          icon: Icon(
            Icons.star_border,
            color: Colors.white,
            size: 32,
          ), 
          onPressed: (){
            print("Favorite Button");
          }
        ),
        SizedBox(width: SizeConfig.screenWidth*200/360),
        IconButton(
          icon: Icon(
            IconCustom.playlist,
            color: Colors.white,
            size: 25,
          ), 
          onPressed: (){
            userBloC.fetchPlaylists("Tri");
            mpBloC.fromDB.value
              ? addPlayList(context)
              : createAlertDialog("Offline playlist is not supported", context);
          }
        ),
      ]
    );
  }

  Widget musicControl(){
    return Column(
      children: <Widget>[
        musicSlider(),
        controlButton(),
      ],
    );
  }

  Widget musicSlider(){
    return Container(
      width: 360,
      child: StreamBuilder<MapEntry<Duration,Song>>(
        stream: CombineLatestStream.combine2(mpBloC.position, mpBloC.currentSong, (a,b) => MapEntry(a,b)),
        builder: (BuildContext context, AsyncSnapshot<MapEntry<Duration,Song>> snapshot){
          if (!snapshot.hasData){
            return Slider(value: 0, onChanged: null, activeColor: Colors.white,);
          }
          if (snapshot.data == null){
            return Slider(value: 0, onChanged: null, activeColor: Colors.white,);
          }

          final Duration dataPos = snapshot.data.key;
          final int positioninMilliseconds = dataPos?.inMilliseconds;

          Duration duration;
          int durationinMilliseconds = 0;
          try {
            durationinMilliseconds = mpBloC.duration.inMilliseconds;
            duration = mpBloC.duration;
          } catch(e) {
            duration = Duration(seconds: 0);
          }
          return Column(
            children: <Widget>[
              Slider(
                min: 0.0,
                max: durationinMilliseconds.toDouble(),
                value: durationinMilliseconds > positioninMilliseconds 
                  ? positioninMilliseconds.toDouble()
                  : durationinMilliseconds.toDouble(),
                onChanged: (double value) {
                  final Duration newPos = Duration(
                    milliseconds: value.toInt(),
                  );
                  mpBloC.updatePosition(newPos);
                },
                onChangeEnd: (double value) {
                  mpBloC.audioSeek(value / 1000);
                },
                activeColor: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  text(dataPos.toString().split('.').first,false ,Colors.white, 15, FontWeight.w200),
                  SizedBox(width: 200),
                  text(duration.toString().split('.').first,false ,Colors.white, 15, FontWeight.w200),
                ]
              )
            ],
          );
        },
      ),
    );
  }

  Widget controlButton(){
    return Container(
      child: StreamBuilder<MapEntry<MapEntry<PlayerState,PlayerMode>,Song>>(
        stream: CombineLatestStream.combine3(mpBloC.playerState, mpBloC.playerMode,mpBloC.currentSong, (a,b, c) => MapEntry(MapEntry(a,b),c)),
        builder: (BuildContext context, AsyncSnapshot<MapEntry<MapEntry<PlayerState,PlayerMode>,Song>> snapshot){
          if (!snapshot.hasData){
            return Container();
          }
          final Song currentSong = snapshot.data.value;
          final PlayerState playerState = snapshot.data.key.key;
          final PlayerMode playerMode = snapshot.data.key.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 28,
                icon: Icon(
                  IconCustom.shuffle,
                  color: (playerMode == PlayerMode.shuffle) 
                    ? ColorCustom.orange 
                    : Colors.white,
                ), 
                onPressed: (){
                  mpBloC.playMode(2);
                }
              ),
              SizedBox(width: 10),
  // Button "Back Music"
              IconButton(
                iconSize: 54.0,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.grey,
                ),
                onPressed: () => mpBloC.prev()
              ),
  // Button "Pause/Play"
              IconButton(
                iconSize: 68.0,
                icon: (playerState != PlayerState.paused) 
                  ? iconPause 
                  : iconPlay,
                onPressed: (playerState != PlayerState.paused) 
                  ? () {
                    mpBloC.pause();
                  }
                  : () {
                    mpBloC.play();
                    }
                ),
  // Button "Next Music"
              IconButton(
                iconSize: 54.0,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.grey,
                ),
                onPressed: () => mpBloC.next()
                ),
              SizedBox(width: 10),
  // Button "repeat"
              IconButton(
                iconSize: 28,
                icon: Icon(
                  IconCustom.repeat,
                  color: (playerMode == PlayerMode.repeat) 
                    ? ColorCustom.orange 
                    : Colors.white,
                ), 
                onPressed: (){
                  setState(() {
                    mpBloC.playMode(1);
                  });
                }
              ),
            ],
          );
        }
      ),
    );
  }

  Widget text(String str,bool isHide ,Color color , double size, FontWeight fontweight){
    return Text(
      str,
      overflow: isHide ? TextOverflow.ellipsis : TextOverflow.visible,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: 'Lato',
        fontWeight: fontweight,
      ),
    );
  }

//Add song to playlist
  Future<String> addPlayList(BuildContext context){
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
                    TextLato("Choose playlist", ColorCustom.orange, 25, FontWeight.w500),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
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
                      if (playlists.length == 0){
                        return noPlaylist();
                      }
                      else
                        return listPlaylist(context, playlists);
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

  Widget listPlaylist(BuildContext context, List<String> playlists){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (BuildContext context, int index){
        String playlist = playlists[index];
        return playListCard(playlist);
        },                                     
    );
  }

  Widget playListCard(String playlist){
    return ListTile(
      contentPadding: EdgeInsets.only(left: 30),
      leading: Icon(
        Icons.library_music,
        color: ColorCustom.orange,
        size: 50,
      ),
      title: TextLato(playlist, Colors.white, 22, FontWeight.w700),
      onTap: () async{

        int result = await playlistAdd(playlist,"Tri", mpBloC.currentSong.value.iD);
        if (result == 1){
          createAlertDialog("Add to $playlist successfully", context);
        } 
        else if (result == 2){
          createAlertDialog("Duplicate Name", context);
        }
        else
          createAlertDialog("Failed to add to $playlist", context);
        //print("Add to $playlist");
      },
    );
  }

  Widget noPlaylist(){
    return Center(
      child: TextLato("No playlist found.", Colors.white, 19, FontWeight.w500)
    );
  }

//Current song list 
  Future<String> currentPlaylist(BuildContext context){
    return showDialog(
      context: context, 
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              )
            ),
            insetPadding: EdgeInsets.only(left: 50, right: 50, top: 80, bottom: 80),
            backgroundColor: ColorCustom.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextLato("Current Playing", ColorCustom.orange, 25, FontWeight.w500),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: mpBloC.currentPlaying,
                    builder: (BuildContext context, AsyncSnapshot<MapEntry<List<Song>, List<Song>>> snapshot){
                      if (!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      }
                      List<Song> songlist = snapshot.data.key;
                      return songList(context, songlist);
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

  Widget songList(BuildContext context, List<Song> songlist){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: songlist.length,
      itemBuilder: (BuildContext context, int index){
        Song song = songlist[index];
        return songTile(song, songlist);
        },                                     
    );
  }


  Widget songTile(Song song, List<Song> songlist){
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20),
      leading: Icon(
        Icons.library_music,
        color: ColorCustom.orange,
        size: 50,
      ),
      title: TextLato(song.title, Colors.white, 22, FontWeight.w700),
      subtitle: TextLato(song.artist, Colors.grey, 15, FontWeight.w500),
      onTap: () {
        mpBloC.updatePlaylist(songlist);
        mpBloC.stop();
        mpBloC.handleSong(song);
      },
    );
  }

}
