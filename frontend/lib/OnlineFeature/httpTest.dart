import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> createAlbum() async {
  final http.Response response = await http.post(
    'http://10.127.29.30:5000/register',
    body: {
      'username': 'sangNguyen',
      'password': '12345',
    },
  );

  if (response.statusCode == 201) {
    return Album.fromJson(json.decode(response.body));
  } else {
    print("Respone status ${response.statusCode}");
    print("Respone body ${response.body}");
    print("Respone headers ${response.headers}");
    return null;
  }
}

class Album {
  final String username;
  final String password;

  Album({this.username, this.password});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      username: json['username'],
      password: json['password'],
    );
  }
}

class MyAppTest extends StatefulWidget {
  MyAppTest({Key key}) : super(key: key);

  @override
  _MyAppTestState createState() {
    return _MyAppTestState();
  }
}

class _MyAppTestState extends State<MyAppTest> {
  //final TextEditingController _controller = TextEditingController();
  Future<Album> _futureAlbum;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureAlbum == null)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Create Data'),
                      onPressed: () {
                        setState(() {
                          _futureAlbum = createAlbum();
                        });
                      },
                    ),
                  ],
                )
              : FutureBuilder<Album>(
                  future: _futureAlbum,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.username);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
        ),
      ),
    );
  }
}