//import 'package:MusicApp/OnlineFeature/UI/homePage.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/root.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Data/mainControlBloC.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/Feature/downloadlist.dart';

class GoOffline extends StatelessWidget {

  final MainControllerBloC mpBloC = MainControllerBloC();

  @override
  Widget build(BuildContext context) {
    return Provider<MainControllerBloC>(
      create: (BuildContext context){
        mpBloC.fetchSongs();
        return mpBloC;
      },
      dispose: (BuildContext context, MainControllerBloC mp) => mp.dispose(),
      child: Downloadlist(false, null),
    );
    //return Downloadlist();
  }
}

class GoOnline extends StatelessWidget {

  final UserModel userInfo;
  GoOnline(this.userInfo);
  
  final MainControllerBloC mpBloC = MainControllerBloC();

  @override
  Widget build(BuildContext context) {
    return Provider<MainControllerBloC>(
      create: (BuildContext context){
        mpBloC.fetchSongs();
        mpBloC.fetchFavourite();
        return mpBloC;
      },
      dispose: (BuildContext context, MainControllerBloC mp) => mp.dispose(),
      child: RootWidget(userInfo),
    );
    //return HomePage();
  }
}