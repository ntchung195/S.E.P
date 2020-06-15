import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/Feature/currentPlaying.dart';
import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/OnlineFeature/UI/userProfile.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Downloadlist extends StatefulWidget {
  final bool _isOnline;
  final UserModel userInfo;
  Downloadlist(this._isOnline, this.userInfo);

  @override
  _DownloadlistState createState() => _DownloadlistState();
}

class _DownloadlistState extends State<Downloadlist> {

  //PanelController _panelController;

  List<dynamic> _filterList = List();
  List<dynamic> _songList = List();
  String _filterkey = "";

  bool isUsed = false;

  @override
  void initState() {
    //_panelController = PanelController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return SafeArea(
      child: Scaffold(
        appBar: appBar(context),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              searchBar(),
              SizedBox(height: SizeConfig.screenHeight*7/640),
              shuffleButton(),
              SizedBox(height: SizeConfig.screenHeight*7/640),
              musicList(),
              isUsed 
                ? GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayer(mp)
                          )
                      );
                    },
                    child: CurrentPlayBar()
                  ) 
                : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget userButton(BuildContext context){
    return IconButton(
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
      onPressed: () async {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfile(widget.userInfo))
        );
      }
    );
  }

  Widget appBar(BuildContext context){
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      leading: !widget._isOnline ? BackButton(
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ) : userButton(context),
      title: Text(
        "Downloaded Songs",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      actions: <Widget>[
        IconButton(icon: Icon(IconCustom.settings_1), onPressed: (){}),
      ],
    );
  }

  Widget shuffleButton(){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return ButtonTheme(
      height: 31,
      minWidth: 158,
      buttonColor: ColorCustom.orange,
      child: RaisedButton(
        onPressed: ((){
          mp.stop();
          mp.playRandomSong();
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)
        ),
        child: Text(
          "Shuffle Play",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget searchBar(){
    return Padding(
      padding: EdgeInsets.only(left: 32,right: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
          color: Colors.black,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 9.0),
// Search Icon
            Icon(
              Icons.search,
              color: ColorCustom.orange,
              size: 25,
            ),

            SizedBox(width: 20),
// Text Input Field
            Expanded(
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18),
//Hint text for textfield
                decoration: InputDecoration(
                  hintText: 'Songs, albums, artists',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w100,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
                border: InputBorder.none,
                ),
//Function for textfield
              onChanged: (string){
                setState(() {
                  _filterkey = string;
                });
              },
              showCursor: true,
              cursorColor: Colors.black,
              )
            ),
            SizedBox(width: 49),
//-----------------------------------------------------------
          ],
        ),
      ),
    );
  }

  Widget empTylist(){
    return Center(
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 85,),
            Text(
              "Song Is Not Found",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 30.0,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      )
      );
  }

  Widget musicList(){
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
    return StreamBuilder<List<Song>>(
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

        _songList = snapshot.data;
        // _filterList = _songList;
        _filterList = _songList.where((element) => 
          (element.title.toLowerCase().contains(_filterkey.toLowerCase()) || 
          element.artist.toLowerCase().contains(_filterkey.toLowerCase())))
          .toList();
        if (_songList.length == 0) {
          return empTylist();
        }
        return Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: _filterList.length + 1,
            itemBuilder: (BuildContext context, int index){
              if (index == _filterList.length) 
                return widget._isOnline ? Container(height: 60) : Container();
              Song _song = _filterList[index];
              return songTile(mp, _song);
              },                                     
            ),
        );
      },

    );
  }

  Widget musicIcon(){
    return Container(
      height: 50,
      width: 50,
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
      size: 40,
        ),
    );
  }

  Widget musicArt(Song song){
    return Container(
      height: 50,
      width: 50,
      child: Image(
        fit: BoxFit.fill,
        image: AssetImage(
          song.albumArt,
        )
      ),
    );
  }

  Widget songTile(MainControllerBloC mp, Song song){
    return ListTile(
      leading: musicIcon(),
      title: Text(
        song.title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        song.artist,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ColorCustom.grey1,
          fontSize: 14.0,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: moreSetting(),
      onTap: () {                                                         //Function for song cards
        setState(() {
          isUsed = true;
        });
        mp.isUsed.add(true);
        mp.fromDB.add(false);
        mp.stop();
        mp.play(song);
      },
    );
  }

  Widget moreSetting(){
    return PopupMenuButton<int>(
      color: ColorCustom.grey,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 30.0,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 1,
          child: Text(
            "Upload",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text(
            "Add to playlist",
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
          print("Upload");
        else print("Add to playlist");
      },
//-----------------------------------------------------------
    );
  }


}