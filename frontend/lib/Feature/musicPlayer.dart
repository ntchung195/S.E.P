import 'dart:ui';

import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
//import 'package:provider/provider.dart';
import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:rxdart/rxdart.dart';
import 'package:MusicApp/Custom/customText.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';


class MusicPlayer extends StatefulWidget {
  final MainControllerBloC _mp;
  MusicPlayer(this._mp);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {

//Temp--------------------------------


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
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black),
      //   shape: BoxShape.circle,
      // ),
      child: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
            icon: dropDownButton(),
            onPressed: (){
              Navigator.pop(context);
            }
          ),
          title: TextLato("Music Player", Colors.white, 25, FontWeight.w700),
          actions: <Widget>[
            StreamBuilder(
              stream: widget._mp.fromDB,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData){
                  return Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 20.0,
                  );
                }
                bool isOnline = snapshot.data;
                
                return isOnline ? Icon(
                  Icons.wifi,
                  color: Colors.white,
                  size: 30.0,
                ) 
                : Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 27.0,
                ); 
              }
            ),
            SizedBox(width: 12),
          ],
        ),
        body: body()
      ),
    );
  }

  Widget body(){
    final MainControllerBloC mp = widget._mp;
    return Center(
      child: Column(
          children: <Widget>[
            SizedBox(height: SizeConfig.screenHeight*28/640),
            imageDecoration(),
            //albumArtCover(mp),
            SizedBox(height: SizeConfig.screenHeight*28/640),
            songInfo(mp),
            SizedBox(height: SizeConfig.screenHeight*20/640),
            favoritePlayListButton(),
            musicControl(mp),
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

  Widget albumArtCover(MainControllerBloC mp){
    // final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    // final MainControllerBloC mp = widget._mp;
    return Container(
      child: StreamBuilder<Song>(
        stream: mp.currentSong,
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

  Widget songInfo(MainControllerBloC mp){
    //final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    // final MainControllerBloC mp = widget._mp;
    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: StreamBuilder<Song>(
        stream: mp.currentSong,
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
            widget._mp.infoBloC.fetchPlaylists("Tri");
            widget._mp.fromDB.value
              ? addPlayList(context, widget._mp)
              : createAlertDialog("Offline playlist is not supported", context);
          }
        ),
      ]
    );
  }

  Widget musicControl(MainControllerBloC mp){
    return Column(
      children: <Widget>[
        musicSlider(mp),
        controlButton(mp),
      ],
    );
  }

  Widget musicSlider(MainControllerBloC mp){
    // final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    // final MainControllerBloC mp = widget._mp;
    return Container(
      width: 360,
      child: StreamBuilder<MapEntry<Duration,Song>>(
        stream: CombineLatestStream.combine2(mp.position, mp.currentSong, (a,b) => MapEntry(a,b)),
        builder: (BuildContext context, AsyncSnapshot<MapEntry<Duration,Song>> snapshot){
          if (!snapshot.hasData){
            return Slider(value: 0, onChanged: null, activeColor: Colors.white,);
          }
          if (snapshot.data == null){
            return Slider(value: 0, onChanged: null, activeColor: Colors.white,);
          }

          final Duration dataPos = snapshot.data.key;
          final int positioninMilliseconds = dataPos?.inMilliseconds;
          //final Song currentSong = snapshot.data.value;
          Duration duration;
          int durationinMilliseconds = 0;
          try {
            durationinMilliseconds = mp.duration.inMilliseconds;
            duration = mp.duration;
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
                  mp.updatePosition(newPos);
                },
                onChangeEnd: (double value) {
                  mp.audioSeek(value / 1000);
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

  Widget controlButton(MainControllerBloC mp){
    //final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    //final MainControllerBloC mp = widget._mp;
    return Container(
      child: StreamBuilder<MapEntry<MapEntry<PlayerState,PlayerMode>,Song>>(
        stream: CombineLatestStream.combine3(mp.playerState, mp.playerMode,mp.currentSong, (a,b, c) => MapEntry(MapEntry(a,b),c)),
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
                  mp.playMode(2);
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
                onPressed: () => mp.prev()
              ),
  // Button "Pause/Play"
              IconButton(
                iconSize: 68.0,
                icon: (playerState != PlayerState.paused) 
                  ? iconPause 
                  : iconPlay,
                onPressed: (playerState != PlayerState.paused) 
                  ? () {
                    mp.pause();
                  }
                  : () {
                    mp.playSong(currentSong);
                    }
                ),
  // Button "Next Music"
              IconButton(
                iconSize: 54.0,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.grey,
                ),
                onPressed: () => mp.next()
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
                    mp.playMode(1);
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

  Future<String> addPlayList(BuildContext context, MainControllerBloC mp){
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
                    stream: widget._mp.infoBloC.playlists,
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
                      //print(playlists);
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
        print( widget._mp.currentSong.value.title);
        int result = await playlistAdd(playlist,"Tri", widget._mp.currentSong.value.title);
        if (result == 1){
          createAlertDialog("Add to $playlist successfully", context);
        } else
          createAlertDialog("Failed to add to $playlist", context);
        print("Add to $playlist");
      },
    );
  }

  Widget noPlaylist(){
    return Center(
      child: TextLato("No playlist found.", Colors.white, 19, FontWeight.w500)
    );
  }

}
