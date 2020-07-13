import 'dart:convert';

Favourite favouriteFromJson(String str) => Favourite.fromJson(json.decode(str));

String favouriteToJson(Favourite data) => json.encode(data.toJson());

class Favourite {
    Favourite({
        this.favourite,
    });

    List<SongItem> favourite;

    factory Favourite.fromJson(Map<String, dynamic> json) => Favourite(
        favourite: List<SongItem>.from(json["favourite"].map((x) => SongItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "favourite": List<dynamic>.from(favourite.map((x) => x.toJson())),
    };
}

class SongItem {
    SongItem({
        this.title,
        this.artist,
        this.id,
    });

    String id;
    String title;
    String artist;

    factory SongItem.fromJson(Map<String, dynamic> json) => SongItem(
        id: json["_id"],    
        title: json["title"] == null ? "Unknown" : json["title"],
        artist: json["artist"] == null ? "Unknown" : json["artist"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "artist": artist,
    };
}