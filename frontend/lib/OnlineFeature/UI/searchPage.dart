// import 'package:MusicApp/Data/mpControlBloC.dart';
// import 'package:MusicApp/Feature/currentPlaying.dart';
// import 'package:MusicApp/Feature/musicPlayer.dart';
import 'package:MusicApp/Custom/sizeConfig.dart';
import 'package:MusicApp/OnlineFeature/UI/homePage.dart';
// import 'package:MusicApp/OnlineFeature/UI/userProfile.dart';
// import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:MusicApp/Custom/color.dart';
// import 'package:MusicApp/Custom/customIcons.dart';
// import 'package:provider/provider.dart';
import 'package:MusicApp/OnlineFeature/UI/purchase.dart';
import 'package:MusicApp/Custom/custemText.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  FocusNode focusNode = FocusNode();
  String hintText = 'Songs, albums, artists';

  String _searchKey = "";
  
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        if (focusNode.hasFocus) {
          hintText = '';
        } else {
          hintText = 'Songs, albums, artists';
        }       
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
        child: Scaffold(
        backgroundColor: Colors.black,
        body: body(),
      ),
    );
  }

  Widget buttonSet(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
        color: Colors.white,
      ),
      height: 65/640 * SizeConfig.screenHeight,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonWidget(Icons.home, "Home",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.search, "Search",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.library_music, "Library",
              function: (){}
            ),
            SizedBox(width: 50),
            buttonWidget(Icons.shopping_cart, "VIP",
              function: (){
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Purchase(),
                    );
                  }
                );
              }
            ),
          ],
        )
      ),
    );
  }

  Widget buttonWidget(IconData icon, String str, {void Function() function}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 2),
        IconButton(
          padding: EdgeInsets.only(bottom: 0),
          iconSize: 40,
          icon: Icon(
            icon,
            color: Colors.black,    
          ),
          onPressed: function,
        ),
        TextLato(str, Colors.black, 12, FontWeight.w700),
      ],
    );
  }

  Widget body(){
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.only(left: 35,right: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextLato("Search", Colors.white, 36, FontWeight.w500),
              ],
            ),
            SizedBox(height: 20,),
            searchBar(),
            allTagColumn(),
            //emptySearch()
            !isUsed ? Container(height: 75) : Container(height: 150),
          ],
        ),
      ),
    );
  }

  Widget searchBar(){
    return Container(
      padding: EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
        color: Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 22,),
// Search Icon
          Icon(
            Icons.search,
            color: ColorCustom.orange,
            size: 25,
          ),
          SizedBox(width: 20),
// Text Input Field
          Expanded(
            child: TextField(
              focusNode: focusNode,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18),
//Hint text for textfield
              decoration: InputDecoration(
                
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w100,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              border: InputBorder.none,
              ),
//Function for textfield
            onSubmitted: (string){
              setState(() {
                _searchKey = string;
              });
            },
            showCursor: true,
            cursorColor: Colors.black,
            )
          ),
          SizedBox(width: 49),
//-----------------------------------------------------------
        ],
      ),
    );
  }

  Widget allTagColumn(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16,),
        TextLato("Top Gernes", Colors.white, 20, FontWeight.w400),
        SizedBox(height: 15,),
        
        Row(
          children: <Widget>[
            tagMusic("Pop", ColorCustom.brown, Icons.album),
            SizedBox(width: 10,),
            tagMusic("KPop", ColorCustom.lightBlue, Icons.album)
          ],
        ),
        SizedBox(height: 10,),

        Row(
          children: <Widget>[
            tagMusic("EDM", ColorCustom.mediumYellow, Icons.album),
            SizedBox(width: 10,),
            tagMusic("Rock", ColorCustom.deepRed, Icons.album)
          ],
        ),
        SizedBox(height: 16,),

        TextLato("Others", Colors.white, 20, FontWeight.w400),
        SizedBox(height: 15,),

        Row(
          children: <Widget>[
            tagMusic("JPop", ColorCustom.lightPink, Icons.album),
            SizedBox(width: 10,),
            tagMusic("Jax", ColorCustom.lightBrown, Icons.album)
          ],
        ),
        SizedBox(height: 10,),

        Row(
          children: <Widget>[
            tagMusic("Charts", ColorCustom.moreDeepRed, Icons.album),
            SizedBox(width: 10,),
            tagMusic("New\nRelease", ColorCustom.lightGreen, Icons.album)
          ],
        ),
        SizedBox(height: 10,),

        Row(
          children: <Widget>[
            tagMusic("Karaoke", ColorCustom.deepOrange, Icons.album),
            SizedBox(width: 10,),
            tagMusic("Party", ColorCustom.purple, Icons.album)
          ],
        ),
      ],
    );
  }

  Widget tagMusic(String str, Color color, IconData icon){
    return GestureDetector(
      onTap: () {
        print("Select $str");
      },
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 5),
        width: 155,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                TextLato(str, Colors.white, 18, FontWeight.w400),
              ]
            ),
            Expanded(child: Container(),),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget> [
                Icon(
                  icon,
                  size: 45,
                  color: Colors.white,
                  )
              ]
            )

          ],
        ),
      ),
    );
  }

  Widget emptySearch(){
    return Container(
      height: 410,
      child: Center(
        child: TextLato("No results found.", Colors.white, 18, FontWeight.w400,),
      ),
    );
  }

}