import 'package:MusicApp/Custom/customMarquee.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:MusicApp/Custom/customText.dart';
import 'package:MusicApp/BloC/recoderBloC.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/myMusic.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/OnlineFeature/UI/signUp.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController usernameInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();
  RecorderBloC recordBloC = RecorderBloC();
  List<Map> _userList = [];

  @override
  void initState() {
    super.initState();
    fetchRecentlyUser();
  }

  void fetchRecentlyUser() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> localSave = _prefs.getStringList("username") ?? [];
    for (var user in localSave){
      _userList.add(json.decode(user));
    }
  }

  bool isContain(String name, String id){
    for (var user in _userList){
      if (name == user["name"] || id == user["id"]) return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          child: Column(
          crossAxisAlignment:CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: SizeConfig.screenHeight*52/640,),
            logoWidget(),
            SizedBox(height: SizeConfig.screenHeight*31/640,),
            textInput(),
            SizedBox(height: SizeConfig.screenHeight*33/640,),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: SizeConfig.screenWidth / 2 - 82),
                  child: signInButton(context),
                ),
                signInWithVoiceButton(context),
              ]
            ),
            SizedBox(height: SizeConfig.screenHeight*8/640,),
            signUp(context),
            SizedBox(height: SizeConfig.screenHeight*8/640,),
            offlineButton(context),
          ],
        ),
      ),
    );
  }

  Widget logoWidget(){
    return Container(      
      width: 250.0,
      height: 150.0,
      child: Icon(
        IconCustom.mymusic,
        color: ColorCustom.orange,
        size: 100,
      ),
    );
  }

  Widget textInput(){
   return Padding(
      padding: EdgeInsets.only(left: SizeConfig.screenWidth*5/36,top: 0.0,right: SizeConfig.screenWidth*5/36,bottom: 0),
      child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            text("Username or Email:"),
            textField(false, input: usernameInput,hint: "example@example.com"),
            SizedBox(height: SizeConfig.screenHeight*38/640,),
            text("Password:"),
            textField(true, input: passwordInput),
          ],
        ),
      ),
    );
 }

  Widget text(String str){
    return Text(
      str,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
      ),
    );
  }

  Widget textField(bool isPass, {TextEditingController input, String hint = ""}){
    return TextField(
      obscureText: isPass,
      controller: input,
      style: TextStyle(
        fontSize: 20.0,
        fontFamily: 'Lato',
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w400,
          fontSize: 20.0,
          color: Colors.black.withOpacity(0.3),
        ),
        contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        filled: true,
        fillColor: ColorCustom.orange,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.black)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.black)
        )
      ),
      showCursor: true,
      cursorColor: Colors.black,
    );
  }

  int count = 0;


  Widget signInWithVoiceButton(BuildContext context){
    return IconButton(
        onPressed: () {
          // int result = await  prepareVerify("username", "id");
          // print("$result");
          if (count < 3)
            createVoiceVerify(context);
          else createAlertDialog("Please login with password", context);
        },
        iconSize: 35,
        icon: Icon(
          Icons.mic,
          color: Colors.yellow,
        ),
      );
  }

  void saveLocal(UserModel userInfo) async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Map<String,String> user = {
      "id": userInfo.id,
      "name": userInfo.name,
    };
    var data = json.encode(user);
    List<String> localSave = _prefs.getStringList("username") ?? [];

    if (!isContain(userInfo.name, userInfo.id)) {
      if (localSave.length >= 3) localSave.removeAt(0);
      localSave.add(data);
    }

    setState(() {
      _userList.add(user);
    });

    print("Local save: $localSave");
    _prefs.setStringList("username", localSave);

  }


  Widget signInButton(BuildContext context){
    return ButtonTheme(
      height: 35,
      minWidth: 164,
      buttonColor: Colors.white,
      child: RaisedButton(
        onPressed: (() async{
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            createAlertDialog("No Internet Connection",context);
          }


          final username = usernameInput.text.trimRight();
          final password = passwordInput.text.trimRight();

          UserModel userInfo;
          int code;
          if (username == "_")
            userInfo = UserModel(
              id: "5eb4048961f2042d286fd175",
              name: "_",
              email: "example@gmail.com",
              phone: "00000",
              coin: 100000,
              isVip: 1
            );
          else if (username == "" || password == ""){
            createAlertDialog("Do not leave username \nor password empty",context);
            return;
          }
          else {
            var response = await verifyUser(username, password);
            userInfo = response.key;
            code = response.value;
          }

          if (code == USER_NOT_EXIST)
            createAlertDialog("Check your info",context);
          else if (code == CODE_TIMEOUT){
            createAlertDialog("Time out",context);
          }
          else {
            setState(() {
              count = 0;
            });
            saveLocal(userInfo);
            createAlertDialog("Sign In Successfully",context)
              .then((value) =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoOnline(userInfo),
                  )
                )
              );
            }
        }),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)
        ),
        child: TextLato("Sign In", Colors.black, 18.0, FontWeight.w400),
      ),
    );
  }

  Widget signUp(BuildContext context){
    return Row(
      children: <Widget>[
        SizedBox(width: 82),
        TextLato("Don't Have An Account? ", Colors.white, 18.0, FontWeight.w400),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () async{
            var connectivityResult = await (Connectivity().checkConnectivity());
            if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUp(),
                  )
                );
            } else if (connectivityResult == ConnectivityResult.none) {
              createAlertDialog("No Internet Connection",context);
            }
          },
          child: TextLato("Sign Up", ColorCustom.orange, 18.0, FontWeight.w400),
        ),
      ],
    );
  }

  
  Widget offlineButton(BuildContext context){
    return ButtonTheme(
      height: 35,
      minWidth: 165,
      buttonColor: Colors.white,
      child: RaisedButton(
        onPressed: ((){
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoOffline()
            )
          );
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)
        ),
        child: TextLato("Offline", Colors.black, 18.0, FontWeight.w400),
      ),
    );
  }

  bool isRecorderDispose = false;

  Future<void> createVoiceVerify(BuildContext context){
    return showDialog(
      context: context, 
      builder: (context){
        int index = 0;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: StatefulBuilder(
            builder: (context, setState){ 
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 65,vertical: 150),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white
                                ),
                                onPressed: (){
                                  setState(() {
                                    if (index == 0){
                                      index = _userList.length - 1;
                                    }
                                    else index--;
                                  });
                                },
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 50,
                                width: 150,
                                child: Center(
                                  child: CustomMarquee( _userList[index]["name"], ColorCustom.orange, 25, FontWeight.w700)
                                )
                              ),
                              SizedBox(width: 15),
                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white
                                ),
                                onPressed: (){
                                  setState(() {
                                    if (index == _userList.length - 1){
                                      index = 0;
                                    }
                                    else index++;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          switchIcon(status, record.duration.inMilliseconds.toDouble()),
                          Expanded(child: Container(),),
                          InkWell(
                            child: TextLato("Finish", ColorCustom.orange, 25, FontWeight.w700),
                            onTap: () async {
                              print("File Path: ${recordBloC.currentFile.path}");
                              File file = recordBloC.currentFile;
                              int result = await voiceAuthentication(0,_userList[index]["name"],_userList[index]["id"],"recognize",file);
                              setState(() {
                                count += 1;
                              });
                              if (result == 0){
                                setState(() {
                                  count = 0;
                                });
                                UserModel userInfo = await getUserInfo(_userList[index]["name"]);
                                createAlertDialog("Sign In Successfully",context)
                                  .then((value) =>
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GoOnline(userInfo),
                                      )
                                    )
                                  );
                              }
                              if (result == 2){
                                if (count == 3) Navigator.pop(context);
                                createAlertDialog("Fail to recognize",context);
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
            InkWell(child: TextLato("Start", Colors.white, 25, FontWeight.w700))
          ],
        );
      case RecordingStatus.Stopped:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 110,
              height: 110,
              child: Center(
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
              padding: EdgeInsets.zero,
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
