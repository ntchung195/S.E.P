import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MusicApp/Feature/downloadlist.dart';

class GoOffline extends StatelessWidget {

  final GlobalBloC gBloC = GlobalBloC();

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloC>(
      create: (BuildContext context){
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
      create: (BuildContext context) { 
        gBloC.userBloC.saveUserInfo(userInfo);
        gBloC.mpBloC.fetchFromDB();
        return gBloC;
      },
      dispose: (BuildContext context, GlobalBloC gBloC) => gBloC.dispose(),
      child: RootWidget(),
    );
  }
}