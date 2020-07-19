import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
// import 'package:MusicApp/Data/userModel.dart';
// import 'package:http/http.dart' as http;
//import 'package:flutter_svg/flutter_svg.dart';
//import 'package:keyboard_avoider/keyboard_avoider.dart';


class SignUp extends StatelessWidget {

  final TextEditingController emailInput = TextEditingController();
  final TextEditingController usernameInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();
  final TextEditingController passwordInput2 = TextEditingController();

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
          SizedBox(height: SizeConfig.screenHeight*35/640,),
          signUpButton(context),
          SizedBox(height: SizeConfig.screenHeight*8/640,),
          signIn(context)
        ],
      ),
      ),
    );
  }

  Widget logoWidget(){
    return Container(
      height: 60.0,
      width: 250.0,
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
            text("Email:"),
            textField(false, hint: "example@example.com", input: emailInput),
            SizedBox(height: SizeConfig.screenHeight*15/640,),
            text("Username:"),
            textField(false, hint: "", input: usernameInput),
            SizedBox(height: SizeConfig.screenHeight*15/640,),
            text("Password:"),
            textField(true, input: passwordInput),
            SizedBox(height: SizeConfig.screenHeight*15/640,),
            text("Confirm password:"),
            textField(true, input: passwordInput2),
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

  Widget textField(bool isPassword, {String hint = "",TextEditingController input}){
    return TextField(
      obscureText: isPassword,
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
            fontWeight: FontWeight.w300,
            fontSize: 18.0,
            color: Colors.black,
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

  Widget signUpButton(BuildContext context){
    return ButtonTheme(
      height: 35,
      minWidth: 165,
      buttonColor: Colors.white,
      child: RaisedButton(
        onPressed: (() async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
            final email = emailInput.text.trim();
            final username = usernameInput.text.trim();
            final password = passwordInput.text.trim();
            if (password != passwordInput2.text.trim())
              createAlertDialog("Check confirm password again",context);
            else {
              final int reponse = await createUser(email, username, password);
              if (reponse == 1)
                createAlertDialog("Username exists",context);
              else if (reponse == 0) {
                createAlertDialog("Sign Up Successfully",context)
                .then((value) => Navigator.pop(context));
              }
              else
                createAlertDialog("Fail",context);
            }
          } else if (connectivityResult == ConnectivityResult.none) {
            createAlertDialog("No Internet Connection",context);
          }
        }),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.black)
        ),
        child: Text(
          "Sign up",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget signIn(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Already signed up? ",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            "Sign in here!",
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              color: ColorCustom.orange,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}