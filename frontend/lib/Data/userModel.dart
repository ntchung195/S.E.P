import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    String name;
    String email;
    String phone;
    int coin;
    int isVip;

    UserModel({
        this.name,
        this.email,
        this.phone,
        this.coin,
        this.isVip,
    });

    factory UserModel.fromJson(Map<String,dynamic> json) => UserModel(
        name: json["username"],
        email: json["email"],
        phone: json["phone"] == null ? "Add phone" : json["phone"],
        coin: json["coin"] == null ? "Add coin" : json["title"],
        isVip: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "username": name,
        "email": email,
        "phone": phone,
        "status": isVip,
    };

    void printAll(){
      print("Name: ${this.name}");
      print("Email: ${this.email}");
    }

}
