import 'package:flutter/material.dart';
import 'main.dart';

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  String song = Music.song;
  String singer = Music.singer;
  double value = 0.0; // Track current music
  bool pause = true;
// Button play (temporary)
  Icon icon1 = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );
// Button pause
  Icon icon2 = Icon(
    Icons.pause_circle_filled,
    color: Colors.white,
  );
// Button play
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
//--Wallpaper
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
                      )
                    ),
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
                  //Button Sets
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
                        // Button "Back Music"
                        IconButton(
                          iconSize: 40.0,
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.grey,
                          ),
                          onPressed: () {}),
                        // Button "Pause/Play"
                        IconButton(
                          iconSize: 50.0,
                          icon: icon1,
                          onPressed: () {
                            setState(() {
                              if (pause == true) {
                                icon1 = icon2;
                                pause = false;
                              } else {
                                icon1 = icon3;
                                pause = true;
                              }
                            });
                          }),
                        // Button "Next Music"
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
