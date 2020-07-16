import 'package:flutter/material.dart';
import 'dart:convert';

class AccessJson extends StatefulWidget {
  @override
  _AccessJsonState createState() => _AccessJsonState();
}

class _AccessJsonState extends State<AccessJson> {


  List<Map<String, String>> musicLst;

  @override
  void initState() {
    super.initState();
    // getMusicList();
  }

  Future<dynamic> getMusicList() async{
    try {
      String data = await DefaultAssetBundle.of(context).loadString("assets/music.json");
      var showData = await json.decode(data);
      setState(() {
        musicLst = List<Map<String, String>>.from(showData.map((i) => Map<String, String>.from(i)));
      });
    }
    catch(e){
      print("Caught Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}