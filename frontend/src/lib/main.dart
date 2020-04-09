import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'MusicPlayer.dart';
import 'MusicList.dart';

List musicFile;

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled=false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MusicList(),
        '/1': (context) => MusicPlayer(musicFile),
      },
    );
  }
}

