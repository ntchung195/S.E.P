import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/Data/userModel.dart';
import 'package:MusicApp/OnlineFeature/UI/purchase.dart';
import 'package:MusicApp/OnlineFeature/httpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
import 'package:MusicApp/Custom/customIcons.dart';

class UserProfile extends StatefulWidget {

  final UserModel userInfo;
  UserProfile(this.userInfo);


  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  UserModel userInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userInfo = widget.userInfo;
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
      title: text("Profile"),
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
    //widget.userInfo.printAll();
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
              text("${userInfo.name}"),
              SizedBox(height: 15,),
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: ColorCustom.orange),
                ),
                child: Center(
                  child: InkWell(
                    child: text("VIP",color: userInfo.isVip == 1 ? Colors.amber : Colors.white, size: userInfo.isVip == 1 ? 40 : 20, fontWeight: userInfo.isVip == 1 ? FontWeight.w900 : FontWeight.w400),
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Purchase(),
                          );
                        }
                      );
                    },
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
    return ListView(
        children: <Widget>[
          infoListTitle(Icons.mail , "${userInfo.email}", onPressed: (){}),
          infoListTitle(Icons.phone, "${userInfo.phone}", onPressed: (){}),
          infoListTitle(Icons.attach_money,"${userInfo.coin}", onPressed: (){}),
          infoListTitle(Icons.exit_to_app,"Log out", onPressed: () async {
            final bool response = await logOut(userInfo.name);
            if (response){
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            }
            else{
              createAlertDialog("Fail to log out", context);
            }
          }),
        ],
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
      title: text(str, size: 25),
      trailing: IconButton(
          onPressed: onPressed,
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Colors.amber,
          )
      ),
    );
  }

  Widget text(String str, {Color color = Colors.white, double size = 20.0, FontWeight fontWeight = FontWeight.w400}){
    return Text(
      str,
      style: TextStyle(
        color: color,
        fontSize: 20.0,
        fontFamily: 'Lato',
        fontWeight: fontWeight,
      ),
    );
  }
}