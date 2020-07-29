import 'dart:io';
import 'dart:ui';
import 'package:MusicApp/BloC/globalBloC.dart';
import 'package:MusicApp/BloC/userBloC.dart';
import 'package:MusicApp/Custom/customText.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/BloC/recoderBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/OnlineFeature/UI/purchase.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

import '../httpService.dart';

class UserProfile extends StatefulWidget {

  final GlobalBloC globalBloC;
  UserProfile(this.globalBloC);


  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  UserModel userInfo;
  UserBloC userBloC;
  RecorderBloC recordBloC;

  @override
  void initState() {
    super.initState();
    recordBloC = RecorderBloC();
    userBloC = widget.globalBloC.userBloC;
    userInfo = userBloC.userInfo.value;
  }

  @override
  void dispose() {
    super.dispose();
    recordBloC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: appBar(context),
        backgroundColor: Colors.black,
        body: Column(
            children: <Widget>[
              profileContainer(false),
              SizedBox(height: 29/640*SizeConfig.screenHeight,),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 38, right: 38),
                  child: childList(context),
                ),
              )
            ]
        )
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      leading: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 45,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
        ),
        onPressed: (){
          Navigator.pop(context);
        }
      ),
      title: TextLato("Profile", Colors.white, 20, FontWeight.w400),
      actions: <Widget>[
        IconButton(
            onPressed: (){},
            icon: Icon(
              IconCustom.settings_1
            ),
        ),
      ],
    );
  }

  Widget profileContainer(bool isVIP){
    return Container(
      width: 500,
      height: 135,
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorCustom.orange
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 20,),
          avatar(),
          SizedBox(width: 70),
          Column(
            children: <Widget>[
              SizedBox(height: 10),
              TextLato("${userInfo.name}", Colors.white, 20, FontWeight.w600),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorCustom.orange, width: 5),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: StreamBuilder<Object>(
                    stream: userBloC.userInfo,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      final UserModel _userInfo = snapshot.data;
                      return InkWell(
                        child: _userInfo.isVip == 1
                          ? TextLato("VIP", Colors.yellow, 20, FontWeight.w900)
                          : TextLato("VIP", Colors.white, 20, FontWeight.w400),
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Purchase(userBloC: userBloC, type: "status", parentContext: context,),
                              );
                            }
                          );
                        },
                      );
                    }
                  ),
                )
              )
            ],
          )
        ],
      ),
    );
  }

  Widget avatar(){
    return CircleAvatar(
      backgroundColor: ColorCustom.orange,
      child: Container(
        child: Icon(
          Icons.person,
          color: Colors.black,
          size: 50,
          )
        ),
      radius: 40,
    );
  }


  Widget childList(BuildContext context){
    return StreamBuilder(
      stream: userBloC.userInfo,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (!snapshot.hasData) 
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );

        UserModel _userInfo = snapshot.data;
        return ListView(
          children: <Widget>[
            infoListTitle(Icons.mail , "${_userInfo.email}", onPressed: (){
              createPopUp(context, "Enter new email", () async { 
                int result = await updateInfo(userBloC , customController.text.toString(), _userInfo.name, "updateEmail");
                customController.text = "";
                result == 1 ? createAlertDialog("Update Successfully", context) : createAlertDialog("Check Your Info", context);
              });
            }),
            infoListTitle(Icons.phone, "${_userInfo.phone}", onPressed: (){
              createPopUp(context, "Enter new phone number", () async { 
                int result = await updateInfo(userBloC , customController.text.toString(), _userInfo.name, "updatePhone");
                customController.text = "";
                result == 1 ? createAlertDialog("Update Successfully", context) : createAlertDialog("Check Your Info", context);
              });
            }),
            infoListTitle(Icons.attach_money,"${_userInfo.coin}", onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Purchase(userBloC: userBloC, type: "buycoin", parentContext: context,),
                  );
                }
              );
            }),
            infoListTitle(Icons.keyboard_voice,"Voice Authentication", onPressed: () async{
              // ignore: unused_local_variable
              int result = await prepareVoice(_userInfo.name, _userInfo.id); //Voice Request

              //if (result == 0)
                createVoiceRegister(context, "Voice Register");
              //else if (result == 3) createAlertDialog("Already register \nvoice recognition", context);
              //else createAlertDialog("Something's wrong", context);

            }),
            infoListTitle(Icons.exit_to_app,"Log Out", onPressed: () async {
              if (_userInfo.name == "_") {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
                return;
              }

              final bool response = await logOut(_userInfo.name);
              if (response){
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              }
              else {
                createAlertDialog("Fail to log out", context);
              }
            }),
          ],
        );
      },
    );
  }

  Widget infoListTitle(IconData icon, String str, {void Function() onPressed }){
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 20),
      leading: Icon(
        icon,
        size: 50,
        color: Colors.amber,
      ),
      title: TextLato(str, Colors.white , 20, FontWeight.w400),
      trailing: IconButton(
          onPressed: onPressed,
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Colors.amber,
          )
      ),
    );
  }

  final TextEditingController customController = TextEditingController(text: "");

  Future<void> createPopUp(BuildContext context, String title,void Function() function){
    return showDialog(
      context: context, 
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: ColorCustom.grey,
            title: TextLato(title, Colors.amber, 20, FontWeight.w700),
            content: TextField(
              obscureText: false,
              controller: customController,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                color: Colors.amber,
              ),
              cursorColor: Colors.amber,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                )
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: TextLato("Confirm",Colors.amber, 20, FontWeight.w700),
                onPressed: () async{
                  function();
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                elevation: 5.0,
                  child: TextLato("Cancel",Colors.amber, 20, FontWeight.w700),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      }
    );
  }

  bool isRecorderDispose = false;

  Future<void> createVoiceRegister(BuildContext context, String title){
    return showDialog(
      context: context, 
      builder: (context){
        int count = 1;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: StatefulBuilder(
            builder: (context, setState){ 
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 90,vertical: 150),
                backgroundColor: ColorCustom.grey,
                child: StreamBuilder(
                  stream: recordBloC.currentRecord,
                  builder: (context, snapshot) {
                    if (isRecorderDispose){
                      return Container();
                    }
                    if (!snapshot.hasData){
                      return CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      );
                    }

                    Recording record = snapshot.data;
                    RecordingStatus status = record.status;

                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10),
                          TextLato(title, ColorCustom.orange, 25, FontWeight.w700),
                          SizedBox(height: 50),
                          switchIcon(status, record.duration.inMilliseconds.toDouble()),
                          Expanded(child: Container(),),
                          InkWell(
                            child: TextLato("Finish", ColorCustom.orange, 25, FontWeight.w700),
                            onTap: () async{
                              if (recordBloC.currentFile != null){
                                // print("File Path: ${recordBloC.currentFile.path}");
                                File file = recordBloC.currentFile;
                                int result = 5;
                                if (count == 5)
                                  result = await voiceAuthentication(count, userInfo.name, userInfo.id, "register", file);
                                else {
                                  await voiceAuthentication(count, userInfo.name, userInfo.id, "register", file);
                                }
                                setState(() {
                                  count += 1;
                                });
                                if (result == 0) createAlertDialog("Success", context);
                                else createAlertDialog("Again", context);
                              }
                              
                            },
                          ),
                          SizedBox(height: 15),
  
                        ],
                      ),
                    );
                  }
                ),
              );
            }
          ),
        );
      }
    );
  }

  Widget switchIcon(RecordingStatus status, double value){
    switch (status) {
      case RecordingStatus.Initialized:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 110,
              height: 110,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 100,
                icon: Icon(
                  Icons.keyboard_voice,
                  color: Colors.white,
                ),
                onPressed: () {
                  recordBloC.start();
                },
              ),
            ),
            SizedBox(height: 25),
            TextLato("Start", Colors.white, 25, FontWeight.w700)
          ],
        );
      case RecordingStatus.Stopped:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 110,
              height: 110,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 100,
                icon: Icon(
                  Icons.adjust,
                  color: Colors.white,
                ),
                onPressed: (){
                  recordBloC.initRecoder();
                },
              ),
            ),
            SizedBox(height: 25),
            TextLato("Ready", Colors.white, 25, FontWeight.w700)
          ],
        );         

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 110,
              height: 110,
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 15,
                  value: value/Duration(seconds: 2).inMilliseconds.toDouble(),
                ),
              ),
            ),
            SizedBox(height: 25),
            TextLato("Speak Your Name", Colors.white, 25, FontWeight.w700)
          ],
        );
    }
  }

}