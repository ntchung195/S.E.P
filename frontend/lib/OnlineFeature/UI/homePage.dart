import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:MusicApp/Custom/customMarquee.dart';
import 'package:MusicApp/OnlineFeature/UI/userProfile.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/Custom/customText.dart';

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
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
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
                      offlineList(),
                      StreamBuilder<bool>(
                        stream: mpBloC.isUsed,
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
                          if (!snapshot.hasData){
                            return Container();
                          }
                          return !snapshot.data
                            ? Container(height: 60)
                            : Container(height: 130);
                        },
                      ),
                      //!isUsed ? Container(height: 60) : Container(height: 130),
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
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
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
            MaterialPageRoute(builder: (context) => UserProfile(globalBloC))
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
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
          child: TextLato("Recently Play", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        StreamBuilder<List<Song>>(
          stream: mpBloC.recently,
          builder: (context, snapshot) {
            if (mpBloC.isDispose) return Container();

            if (!snapshot.hasData) {
                return circleLoading("Loading");
              }

            List<Song> _songList = snapshot.data;
            if (_songList.length == 0) {
              return Container();
            }

            return Container(
              height: 170/640 * SizeConfig.screenHeight,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _songList.length,
                itemBuilder: (BuildContext context, int index){
                  return songTile(IconCustom.album_1, _songList[index], _songList);
                },
              )
            );
          }
        ),
      ],
    );
  }

  Widget favouriteList(){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          //padding: EdgeInsets.only(left: 31/360 * SizeConfig.screenWidth),
          child: TextLato("Favorite albums and songs", Colors.white, 20, FontWeight.w700),
        ),
        SizedBox(height: 10/640 * SizeConfig.screenHeight),
        StreamBuilder(
          stream: mpBloC.favourite,
          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
            if (mpBloC.isDispose) return Container();

            if (!snapshot.hasData) {
              return circleLoading("Waiting for server");
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
                  return songTile(IconCustom.album_1, _songList[index], _songList);
                },
              )
            );
          }
        ),
      ],
    );
  }

  Widget offlineList(){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
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
            stream: mpBloC.songList,
            builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
              if (mpBloC.isDispose) return Container();
              if (!snapshot.hasData) {
                return circleLoading("Loading");
              }
              List<Song> _songList = snapshot.data;
              if (_songList.length == 0) {
                return Container();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _songList.length,
                itemBuilder: (BuildContext context, int index){
                  return songTile(IconCustom.album_1, _songList[index], _songList);
                },
              );
            },
          )
        ),
      ],
    );
  }

  Widget songTile(IconData icon, Song _song, List<Song> songlist){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
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
              mpBloC.isUsed.add(true);
              mpBloC.updatePlaylist(songlist);
              mpBloC.stop();
              mpBloC.handleSong(_song);
            },
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget> [
              Container(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    // CustomMarquee(_song.title, Colors.white, 20,FontWeight.w700),
                    // CustomMarquee(_song.title, Colors.white, 20,FontWeight.w700),
                    TextLato(_song.title, Colors.white, 20, FontWeight.w700),
                    TextLato(_song.artist, ColorCustom.grey1, 14, FontWeight.w400),
                  ]
                ),
              ),
              _song.iD != null 
                ? Row(
                  children: <Widget> [
                    SizedBox(width: 20),
                    purchaseButton(_song.title)
                  ]
                )
                : Container(),
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

  // await(Future<ConnectivityResult> checkConnectivity) {}

  Widget circleLoading(String str){
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
            TextLato(str, Colors.white, 20, FontWeight.w500)
          ],
        ),
      ),
    );
  }

}

