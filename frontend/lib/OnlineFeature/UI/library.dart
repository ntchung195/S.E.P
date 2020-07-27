import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:MusicApp/BloC/userBloC.dart';
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
    final GlobalBloC globalBloC = Provider.of<GlobalBloC>(context);
    final UserBloC userBloC = globalBloC.userBloC;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: Container(),
          title: TextLato("Library", Colors.white, 25, FontWeight.w700),
        ),
        body: userBloC.userInfo.value.isVip == 1 ?
          Padding(
            padding: EdgeInsets.only(left: 35, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                listTile(Icons.playlist_add,"Create playlist",(){
                  createPlayList(context, globalBloC);
                }),
                listTile(IconCustom.album_1,"My Playlist",() async{
                  UserModel userInfo =  userBloC.userInfo.value;
                  userBloC.fetchPlaylists(userInfo.name);
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => Playlists(globalBloC),
                    )
                  );
                }),
              ]
            ),
          ) : Container(
            height: 100,
            child: Center(
              child: TextLato("This service is for VIP user", ColorCustom.orange, 25, FontWeight.w700),
            )
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

  Future<String> createPlayList(BuildContext context, GlobalBloC globalBloC){
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
                UserModel user = globalBloC.userBloC.userInfo.value;
                List<String> playlists = await createPlaylist(customController.text, user.name);
                if ( playlists[0] == "" ) {
                  createAlertDialog("Playlist's name exist", context);
                }
                else if ( playlists == null) createAlertDialog("Server Error", context);
                else{
                  globalBloC.userBloC.playlists.add(playlists);
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