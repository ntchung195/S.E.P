import 'dart:convert';

import 'package:MusicApp/Data/songModel.dart';

Playlist playlistFromJson(String str) => Playlist.fromJson(json.decode(str));

String playlistToJson(Playlist data) => json.encode(data.toJson());

class Playlist {
    Playlist({
        this.name,
        this.songlist,
    });

    String name;
    List<SongItem> songlist;

    factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        name: json["name"],
        songlist: List<SongItem>.from(json["songlist"].map((x) => SongItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "songlist": List<dynamic>.from(songlist.map((x) => x.toJson())),
    };

}