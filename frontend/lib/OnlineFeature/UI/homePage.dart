import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:MusicApp/Data/songModel.dart';
import 'package:MusicApp/Data/userModel.dart';
// import 'package:MusicApp/Feature/currentPlaying.dart';
// import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/OnlineFeature/UI/userProfile.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/OnlineFeature/UI/purchase.dart';
import 'package:MusicApp/Custom/custemText.dart';


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
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
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
                      recentlyList(mp),
                      favouriteList(mp),
                      yourSongList(mp),
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
          
          UserModel userInfo = mp.infoBloC.userInfo.value;
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfile(userInfo))
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

  Widget recentlyList(MainControllerBloC mp){
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
              return songTile(IconCustom.album_1, "", "Song $index", "Artist $index", true);
            },
          )
        ),
      ],
    );
  }

  Widget favouriteList(MainControllerBloC mp){
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
          builder: (BuildContext context, AsyncSnapshot<List<SongItem>> snapshot){
            if (mp.isDispose) return Container();
            if (!snapshot.hasData) {
              return Container(
                height: 170/640 * SizeConfig.screenHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              );
            }
            List<SongItem> _songList = snapshot.data;
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
                  String id = _songList[index].id;
                  String title = _songList[index].title;
                  String artist = _songList[index].artist;
                  return songTile(IconCustom.album_1, id, title, artist, false);
                },
              )
            );
          }
        ),
      ],
    );
  }

  Widget yourSongList(MainControllerBloC mp){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: TextLato("Your songs", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
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
                  return songDownloaded(mp, IconCustom.album_1, _song);
                },
              );
            },
          )
        ),
      ],
    );
  }

  Widget songTile(IconData icon, String id, String title, String artist, bool inPhone){
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
              Song songTest = await getSong(id);
              mp.isUsed.add(true);
              mp.fromDB.add(true);
              mp.stop();
              mp.play(songTest);
              print("Select song $title");
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
                    TextLato(title, Colors.white, 20, FontWeight.w700),
                    TextLato(artist, ColorCustom.grey1, 14, FontWeight.w400),
                  ]
                ),
              ),
              SizedBox(width: 30/110 * (110/640 * SizeConfig.screenHeight)),
              inPhone ? Container() : purchaseButton(title),
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

  Widget songDownloaded(MainControllerBloC mp, IconData icon, Song song){
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
            icon: Container(
              color: ColorCustom.orange,
              child: Icon(
                Icons.music_note,
                color: Colors.black,
              ),
            ),
            onPressed: (){
              setState(() {
                isUsed = true;
              });
              mp.isUsed.add(true);
              mp.stop();
              mp.play(song);
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Purchase(),
                    );
                  }
                );
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

}

