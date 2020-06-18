import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/myMusic.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/OnlineFeature/UI/signUp.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';


class Login extends StatelessWidget {

  final TextEditingController usernameInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();

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
                signInWithVoiceButton(),
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

  Widget signInWithVoiceButton(){
    return IconButton(
        onPressed: (){
          print("Voice Authentication");
        },
        iconSize: 35,
        icon: Icon(
          Icons.mic,
          color: Colors.yellow,
        ),
      );
  }

  Widget signInButton(BuildContext context){
    return ButtonTheme(
      height: 35,
      minWidth: 164,
      buttonColor: Colors.white,
      child: RaisedButton(
        onPressed: (() async{
          createAlertDialog("Sign In Successfully",context)
            .then((value) 
            => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoOnline(null),
                )
                // PageRouteBuilder(
                //   transitionDuration: Duration(milliseconds: 550),
                //   transitionsBuilder: (BuildContext context, 
                //     Animation<double> animation, 
                //     Animation<double> secAnimation,
                //     Widget child){
                //       return ScaleTransition(
                //         alignment: Alignment.center,
                //         scale: animation,
                //         child: child,
                //       );
                //   },
                //   pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secAnimation,){
                //     return GoOnline();
                //   }
                // )
              )
            );
          // final username = usernameInput.text.trimRight();
          // final password = passwordInput.text.trimRight();

          // final UserModel userInfo = await verifyUser(username, password);

          // if (userInfo == null)
          //   createAlertDialog("Check your info",context);
          // else {
          //   createAlertDialog("Sign In Successfully",context)
          //     .then((value) =>
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => GoOnline(userInfo),
          //         )
          //       )
          //     );
          // }
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.black)
        ),
        child: textLato(
          "Sign In",
          color: Colors.black, 
          size: 18.0, 
          fontweight: FontWeight.w400
        ),
      ),
    );
  }

  Widget signUp(BuildContext context){
    return Row(
      children: <Widget>[
        SizedBox(width: 82),
        textLato(
          "Don't Have An Account? ",
          color: Colors.white, 
          size: 18.0, 
          fontweight: FontWeight.w400
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUp(),
                )
              );
            },
          child: textLato(
            "Sign Up", 
            color: ColorCustom.orange, 
            size: 18.0, 
            fontweight: FontWeight.w400
          ),
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
        child: textLato("Offline", color: Colors.black, size: 18.0, fontweight: FontWeight.w400 ),
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