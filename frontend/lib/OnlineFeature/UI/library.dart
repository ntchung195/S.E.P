
// import 'package:MusicApp/Feature/currentPlaying.dart';
// import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/OnlineFeature/UI/playlist.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/Custom/customText.dart';
import 'package:provider/provider.dart';


class Library extends StatefulWidget { 

  // final UserModel userInfo;
  // Library(this.userInfo);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final MainControllerBloC mp = Provider.of<MainControllerBloC>(context);
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
              listTile(Icons.playlist_add,"Create playlist",(){
                createPlayList(context, mp);
              }),
              listTile(Icons.star,"Favourite Songs",(){}),
              listTile(IconCustom.album_1,"My Playlist",() async{
                UserModel userInfo =  mp.infoBloC.userInfo.value;
                //String username = userInfo.name;
                //List<String> playlists = await fetchPlaylist(userInfo.name);
                mp.infoBloC.fetchPlaylists(userInfo.name);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => Playlists(mp, userInfo),
                  )
                );
              }),
            ]
          ),
        ),
      ),
    );
  }

  Widget listTile(IconData icon,String str, Function() function){
    return ListTile(
      leading: Icon(
        icon,
        size: 40,
        color: ColorCustom.orange,
      ),
      title: TextLato(str, Colors.white, 22, FontWeight.w500),
      onTap: function,
    );
  }

  final TextEditingController customController = TextEditingController(text: "");

  Future<String> createPlayList(BuildContext context, MainControllerBloC mp){
    return showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          backgroundColor: ColorCustom.grey,
          title: TextLato("New playlist's name:",Colors.amber, 20, FontWeight.w700),
          content: TextField(
            obscureText: false,
            controller: customController,
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              color: Colors.amber,
            ),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)
              )
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: TextLato("Confirm",Colors.amber, 20, FontWeight.w700),
              onPressed: () async{
                List<String> playlists = await createPlaylist(customController.text, mp.infoBloC.userInfo.value.name);
                if ( playlists == null ) {
                  createAlertDialog("Playlist's name exist", context);
                }
                else{
                  mp.infoBloC.playlists.add(playlists);
                  Navigator.pop(context);
                }
                  
              },
            ),
            MaterialButton(
              elevation: 5.0,
                child: TextLato("Cancel",Colors.amber, 20, FontWeight.w700),
              onPressed: (){
                Navigator.of(context).pop(customController.text.toString());
              },
            )
          ],
        );
      }
    );
  }


}