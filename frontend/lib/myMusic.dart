//import 'package:MusicApp/OnlineFeature/UI/homePage.dart';
import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/root.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/BloC/musicplayerBloC.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/Feature/downloadlist.dart';

class GoOffline extends StatelessWidget {

  final GlobalBloC gBloC = GlobalBloC();

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloC>(
      create: (BuildContext context){
        gBloC.mpBloC.fetchSongs();
        return gBloC;
      },
      dispose: (BuildContext context, GlobalBloC gBloC) => gBloC.dispose(),
      child: Downloadlist(false),
    );
    //return Downloadlist();
  }
}

class GoOnline extends StatelessWidget {

  final UserModel userInfo;
  GoOnline(this.userInfo);
  
  final GlobalBloC gBloC = GlobalBloC();

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloC>(
      create: (BuildContext context){
        gBloC.mpBloC.fetchSongs();
        //gBloC.mpBloC.fetchAllSongDB();
        gBloC.mpBloC.fetchRecently();
        gBloC.mpBloC.fetchFavourite();
        gBloC.userBloC.saveUserInfo(userInfo);
        
        return gBloC;
      },
      dispose: (BuildContext context, GlobalBloC gBloC) => gBloC.dispose(),
      child: RootWidget(),
    );
    //return HomePage();
  }
}