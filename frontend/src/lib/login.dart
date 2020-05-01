import 'package:flutter/material.dart';
import 'sizeConfig.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //SizeConfig().printAllDetail();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black,
        body: Center(
          child: KeyboardAvoider(
            autoScroll: true,
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: SizeConfig.screenHeight*5/64,),
                logoWidget(),
                SizedBox(height: SizeConfig.screenHeight*5/64,),
                textInput(),
                SizedBox(height: SizeConfig.screenHeight/12.8,),
                signInButton(),
                signUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logoWidget(){
    return  Container(
      height: 145.0,
      width: 217.0,
      // child: SvgPicture.asset(
      //   "images/b.svg",
      //   color: Color(0xFFf6a115),
      //   fit: BoxFit.none,
      //   ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/b.png"),
          fit: BoxFit.none,
          )
        ),
    );
  }

  Widget textInput(){
   return Padding(
      padding: EdgeInsets.only(left: SizeConfig.screenWidth*5/36,top: 0.0,right: SizeConfig.screenWidth*5/36,bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text("Username or Email:"),
          textField(hint: "example@example.com"),
          SizedBox(height: SizeConfig.screenHeight/12.8,),
          text("Password:"),
          textField(),
        ],
      ),
    );
 }

  Widget text(String t){
    return Text(
      t,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
      ),
    );
  }

  Widget textField({String hint = ""}){
    return TextField(
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
        ),
        contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        filled: true,
        fillColor: Color(0xFFf6a115),
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

  Widget signInButton(){
    return RaisedButton(
      onPressed: ((){
        print("Sign In");
      }),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.black)
      ),
      padding: EdgeInsets.fromLTRB(52, 4, 52, 4),
      //padding: EdgeInsets.only(left: 52,right: 52),
      child: Text(
        "Sign In",
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
        ),
      ),
    );
  }
  Widget signUp(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Don't Have An Account? ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        GestureDetector(
          onTap: () {print("Sign Up");},
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Color(0xFFf6a115),
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}