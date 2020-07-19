import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/OnlineFeature/UI/userProfile.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/OnlineFeature/UI/purchase.dart';
import 'package:MusicApp/Custom/customText.dart';


bool isUsed = false;

class HomePage extends StatefulWidget {

  // final UserModel userInfo;
  // HomePage(this.userInfo);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0/640 * SizeConfig.screenHeight),
        child: appBar(context)
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
              child: Container(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      recentlyList(),
                      favouriteList(),
                      yourSongList(),
                      !isUsed ? Container(height: 60) : Container(height: 130),
                    ]
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar(BuildContext context){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      leading: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 30,
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(
              color: Colors.black
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Icon(
            Icons.person,
            color: Colors.black,
          ),
        ),
        onPressed: () async{

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfile(mp))
          );
          
        }
      ),
      title: TextLato("Home", Colors.white , 25, FontWeight.w700),
      actions: <Widget>[
        IconButton(
          icon: Icon(IconCustom.settings_1), 
          onPressed: (){}
        ),
      ],
    );
  }

  Widget recentlyList(){
    //final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
          child: TextLato("Recently Play", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
          height: 170/640 * SizeConfig.screenHeight,
          color: Colors.black,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (BuildContext context, int index){
              Song songTemp = Song(0, "Artist $index", "Song $index", null, null, null, null, null, null);
              return songTile(IconCustom.album_1, songTemp, true);
            },
          )
        ),
      ],
    );
  }

  Widget favouriteList(){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
          child: TextLato("Favorite albums and songs", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        StreamBuilder(
          stream: mp.favourite,
          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
            if (mp.isDispose) return Container();

            if (!snapshot.hasData) {
              return Container(
                height: 170/640 * SizeConfig.screenHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      SizedBox(height: 30),
                      TextLato("Waiting for server", Colors.white, 20, FontWeight.w500)
                    ],
                  ),
                ),
              );
            }

            List<Song> _songList = snapshot.data;
            if (_songList.length == 0) {
              return Container();
            }
            return Container(
              //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
              height: 170/640 * SizeConfig.screenHeight,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _songList.length,
                itemBuilder: (BuildContext context, int index){
                  return songTile(IconCustom.album_1, _songList[index], false);
                },
              )
            );
          }
        ),
      ],
    );
  }

  Widget yourSongList(){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: TextLato("Your songs", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        Container(

          height: 170/640 * SizeConfig.screenHeight,
          color: Colors.black,
          child: StreamBuilder<List<Song>>(
            stream: mp.songList,
            builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
              if (mp.isDispose) return Container();
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              }
              List<Song> _songList = snapshot.data;
              // _filterList = _songList;
              if (_songList.length == 0) {
                return Container();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _songList.length,
                itemBuilder: (BuildContext context, int index){
                  Song _song = _songList[index];
                  return songDownloaded(mp, IconCustom.album_1, _song, _songList);
                },
              );
            },
          )
        ),
      ],
    );
  }

  Widget songTile(IconData icon, Song _song, bool inPhone){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return Container(
      width: 150/360 * SizeConfig.screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          IconButton(
            padding: EdgeInsets.all(0),
            iconSize: 110/640 * SizeConfig.screenHeight,
            icon: Container(
              color: ColorCustom.orange,
              child: Icon(
                Icons.music_note,
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              setState(() {
                isUsed = true;
              });
              
              //mp.infoBloC.currentId.add(_song.iD);
              mp.isUsed.add(true);
              mp.fromDB.add(true);
              mp.updatePlaylist(mp.favourite.value);
              mp.stop();
              mp.playSong(_song);
              //print("Select song $title");
            },
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget> [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Container(
                      width: 100,
                      child: TextLato(_song.title, Colors.white, 20, FontWeight.w700)
                    ),
                    Container(
                      width: 100,
                      child: TextLato(_song.artist, ColorCustom.grey1, 14, FontWeight.w400)
                      ),
                  ]
                ),
              ),
              SizedBox(width: 30),
              inPhone ? Container() : purchaseButton(_song.title),
            ]
          )
        ]
      ),
    );
  }

  Widget purchaseButton(String title){
    return SizedBox(
      height: 25/640 * SizeConfig.screenHeight,
      width: 25/640 * SizeConfig.screenHeight,
      child: IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(
        Icons.shopping_cart,
        color: Colors.white,
        size: 25/360 * SizeConfig.screenWidth,
        ), 
      onPressed: (){
        print("Buy $title");
      }),
    );
  }

  Widget songDecoration(Song song){
    return Container(
        color: ColorCustom.orange,
        child: Icon(
          Icons.music_note,
          color: Colors.black,
        ),
      ); 
    // return song.albumArt == null
    //   ? Container(
    //     color: ColorCustom.orange,
    //     child: Icon(
    //       Icons.music_note,
    //       color: Colors.black,
    //     ),
    //   ) 
    //   : Container(
    //     child: FadeInImage(
    //       placeholder: NetworkImage(url), 
    //       image: null
    //     ),
    //   );
      // : Container(
      //     child: Image(
      //       fit: BoxFit.fill,
      //       image: AssetImage(
      //         song.albumArt,
      //       )
      //     ),
      //   );
  }


  Widget songDownloaded(MainControllerBloC mp, IconData icon, Song song, List<Song> songList){
    String title = song.title;
    String artist = song.artist;
    return Container(
      width: 150/360 * SizeConfig.screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          IconButton(
            padding: EdgeInsets.all(0),
            iconSize: 110/640 * SizeConfig.screenHeight,
            icon: songDecoration(song),
            onPressed: (){
              setState(() {
                isUsed = true;
              });
              mp.updatePlaylist(songList);
              mp.isUsed.add(true);
              mp.stop();
              mp.playSong(song);
            },
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget> [
              Container(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    TextLato(title, Colors.white, 20, FontWeight.w700),
                    TextLato(artist, ColorCustom.grey1, 14, FontWeight.w400),
                  ]
                ),
              ),
            ]
          )
        ]
      ),
    );
  }

  Widget buttonSet(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
        color: Colors.white,
      ),
      height: 65/640 * SizeConfig.screenHeight,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonWidget(Icons.home, "Home",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.search, "Search",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.library_music, "Library",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.shopping_cart, "VIP",
              function: (){
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return Dialog(
                //       child: Purchase(),
                //     );
                //   }
                // );
              }
            ),
          ],
        )
      ),
    );
  }

  Widget buttonWidget(IconData icon, String str, {void Function() function}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 2),
        IconButton(
          padding: EdgeInsets.only(bottom: 0),
          iconSize: 40,
          icon: Icon(
            icon,
            color: Colors.black,    
          ),
          onPressed: function,
        ),
        TextLato(str, Colors.black, 12, FontWeight.w700),
      ],
    );
  }

  await(Future<ConnectivityResult> checkConnectivity) {}

}

