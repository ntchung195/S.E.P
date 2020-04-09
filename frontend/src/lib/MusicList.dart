import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';

var lst = new List();

void addLst() {
  lst.add("Beautiful In White-Westlife");
  lst.add("Happy Together-The Turtles");
  lst.add("Until You-Shayne Ward");
}

List split(int index) {
  return lst[index].split("-");
}

class MusicList extends StatefulWidget {
  MusicList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<String> musiclist;
  //var musiclist = new List<String>();

  @override
  void initState() {
    super.initState();
    musiclist = [];
    _initMusics();
    addLst();
  }

  Future _initMusics() async {   
    // >> To get paths you need these 2 lines
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('music/'))
        .where((String key) => key.contains('.mp3'))
        .toList();

    setState(() {
      musiclist = imagePaths;
      for (var i = 0; i < imagePaths.length; i++) {
        musiclist[i] = musiclist[i].replaceAll("music/", '').replaceAll("%20", ' ').replaceAll(".mp3", "");
        //musiclist.add(imagePaths[i].replaceAll("music/", '').replaceAll("%20", ' ').replaceAll(".mp3", ""));
      }
    });
  }

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
                  ))
                ],
              ),
            ),
            SizedBox(height: 20.0),
//--List of Mp3 File (Can be selected)
            ListTile(
              leading: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 40.0,
              ),
              title: Text(
                musiclist[0].split("-")[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                musiclist[0].split("-")[1],
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
                musicFile = musiclist[0].split("-");
                Navigator.pushNamed(context, '/1');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 40.0,
              ),
              title: Text(
                musiclist[1].split("-")[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                musiclist[1].split("-")[1],
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
                musicFile = musiclist[1].split("-");
                Navigator.pushNamed(context, '/1');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 40.0,
              ),
              title: Text(
                split(2)[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                split(2)[1],
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
                musicFile = split(2);
                Navigator.pushNamed(context, '/1');
              },
            )
          ],
        ),
      ),
    );
  }
}
