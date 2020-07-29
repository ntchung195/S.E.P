import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customText.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  FocusNode focusNode = FocusNode();
  String hintText = 'Songs, albums, artists...';

  String _searchKey = "";
  
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        if (focusNode.hasFocus) {
          hintText = '';
        } else {
          hintText = 'Songs, albums, artists...';
        }       
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: searchBar(),
          ),
          backgroundColor: Colors.black,
          body: body(),
      ),
    );
  }

  Widget body(){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10,),
        searchList(),
        StreamBuilder<bool>(
          stream: mpBloC.isUsed,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
            if (!snapshot.hasData){
              return Container(height: 70);
            }
            return !snapshot.data
              ? Container(height: 70)
              : Container(height: 135);
          },
        ),
      ],
    );
  }

  Widget searchBar(){
    return Container(
      constraints: BoxConstraints(
       maxHeight: 70,
       maxWidth: 350 
      ),
      padding: EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 3,
          color: ColorCustom.orange,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 22,),
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
              focusNode: focusNode,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18),
//Hint text for textfield
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: ColorCustom.grey,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              border: InputBorder.none,
              ),
//Function for textfield
            onChanged: (string){
              setState(() {
                _searchKey = string;
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
    );
  }

  Widget emptySearch(){
    return Expanded(
      child: Container(
        child: Center(
          child: TextLato("No results found.", Colors.white, 18, FontWeight.w400,),
        ),
      ),
    );
  }

  Widget initScreen(){
    return Expanded(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 75,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              TextLato("Welcome", Colors.grey, 20, FontWeight.w700,),
            ],
          ),
        ),
      ),
    );
  }

  Widget errorScreen(){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
    return Expanded(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                size: 75,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              TextLato("Server Error", Colors.grey, 20, FontWeight.w700,),
              SizedBox(height: 10),
              RaisedButton(
                padding: EdgeInsets.zero,
                color: ColorCustom.orange,
                child: TextLato("Retry", Colors.black, 20, FontWeight.w700),
                onPressed: (){
                  mpBloC.onlineSongs.add(null);
                  mpBloC.fetchAllSongDB();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchList(){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
    return Container(
      child: StreamBuilder(
        stream: mpBloC.onlineSongs,
        builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot){
          if (!snapshot.hasData){
            return initScreen();
          }
          else if (snapshot.data == []){
            return errorScreen();
          } 
          else if (snapshot.data[0] == null && _searchKey == ""){
            return errorScreen();
          }

          List<Song> songsDB = snapshot.data;
          List<Song> _filterList;
          if (_searchKey == "") _filterList = songsDB;
          else
            _filterList = songsDB.where((element) => 
              (element.title.toLowerCase().contains(_searchKey.toLowerCase()) || 
              element.artist.toLowerCase().contains(_searchKey.toLowerCase())))
              .toList();
          
          if (_filterList.length == 0){
            return emptySearch();
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _filterList.length,
                itemBuilder: (BuildContext context, int index){
                  Song _song = _filterList[index];
                  return songTile(_song, _filterList);
                }
              ),
            )
          );
        }
      ),
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

  Widget songTile(Song song, List<Song> songList){
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final MusicPlayerBloC mpBloC = globalBloC.mpBloC;
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
      //trailing: moreSetting(),
      onTap: () {                                                         //Function for song cards
        mpBloC.isUsed.add(true);
        mpBloC.updatePlaylist(songList);
        mpBloC.stop();
        mpBloC.handleSong(song);
      },
    );
  }


}