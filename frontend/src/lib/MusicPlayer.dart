import 'package:flutter/material.dart';
import 'MusicList.dart';

String song;
String singer;

class MusicPlayer extends StatefulWidget {

  MusicPlayer(List musicFile){
    song = musicFile[0];
    singer = musicFile[1];
  }

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  double value = 0.0;
  int count = 1;
  Icon icon1 = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );

  Icon icon2 = Icon(
    Icons.pause_circle_filled,
    color: Colors.white,
  );

  Icon icon3 = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 450.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 450.0,
                    decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: [Colors.black, Colors.red]),
                        image: DecorationImage(
                          image: AssetImage('images/a.jpg'),
                          fit: BoxFit.cover,
                        )),
                  ),
                  //Image Decoration for Player
                  Container(
                    height: 450.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF090e42).withOpacity(0.1),
                          Color(0xFF090e42)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100.0,
                  ),
                  //Back Button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    iconSize: 30.0,
                    
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Column(
                        children: <Widget>[
                          Spacer(),
                          Text(
                            song,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            singer,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Color(0xFF090e42),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                      child: Slider(
                        value: value,
                        onChanged: (double newvalue) {
                          setState(() {
                            value = newvalue;
                          });
                        },
                        activeColor: Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 40.0,
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.grey,
                          ),
                          onPressed: () {}),
                        IconButton(
                          iconSize: 50.0,
                          icon: icon1,
                          onPressed: () {
                            setState(() {
                              if (count % 2 == 1) {
                                icon1 = icon2;
                                count += 1;
                              } else {
                                count += 1;
                                icon1 = icon3;
                              }
                            });
                          }),
                        IconButton(
                          iconSize: 40.0,
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.grey,
                          ),
                          onPressed: () {})
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
