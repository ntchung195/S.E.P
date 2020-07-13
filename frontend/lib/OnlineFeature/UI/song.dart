// import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/myMusic.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/OnlineFeature/UI/signUp.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';

class Song extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          child: Column(
          crossAxisAlignment:CrossAxisAlignment.center,
          children: <Widget>[
            
          ],
        ),
      ),
    );
  }
  

  Widget textLato(String str, {Color color = Colors.white, double size = 20.0, FontWeight fontweight = FontWeight.normal}){
    return Text(
      str,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: 'Lato',
        fontWeight: fontweight,
      ),
    );
  }

}