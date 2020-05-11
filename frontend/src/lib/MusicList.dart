import 'package:flutter/material.dart';
import 'dart:convert';
import 'main.dart';

var song = {"Beautiful In White", "Happy Together"};
var singer = {"Westlife", "The Turtles"};

class MusicList extends StatefulWidget {
  MusicList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  // List<Map<String, String>> musicLst = [{"Song": "Loading...", "Singer": "Loading..."}];

  @override
  void initState() {
    super.initState();
    // getMusicList();
  }

// Get Music List from Json File
  // Future<dynamic> getMusicList() async{
  //   try {
  //     String data = await DefaultAssetBundle.of(context).loadString("assets/music.json");
  //     var showData = await json.decode(data);
  //     setState(() {
  //       musicLst = List<Map<String, String>>.from(showData.map((i) => Map<String, String>.from(i)));
  //     });
  //   }
  //   catch(e){
  //     print("Caught Error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF090e42),
      body: SafeArea(
        child: Column(
          children: <Widget>[
//--Search Bar
            Container(
              height: 40.0,
              color: Colors.grey.withOpacity(0.16),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 5.0),
                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search music...',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.75,
                        ),
                      border: InputBorder.none,
                      ),
                    showCursor: true,
                    cursorColor: Colors.black,
                    )
                  )
                ],
              ),
            ),
            SizedBox(height: 20.0),
//--List of Mp3 File (Can be selected)
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index){                      
                  return ListTile(
                      leading: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      title: Text(
                        "Song $index",
                        // musicLst[index]['Song'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Singer $index",
                        // musicLst[index]['Singer'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onTap: () {
                        Music.song = "Song $index"; // musicLst[index]['Song'];
                        Music.singer = "Singer $index"; // musicLst[index]['Singer'];
                        Navigator.pushNamed(context, '/1');
                      },
                    );
                  },
                itemCount: 5 // musicLst.length
              )
            ),
          ],
        ),
      ),
    );
  }
}