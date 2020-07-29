import 'dart:convert';

UserModel userModelFromJson(Map<String,dynamic> json) => UserModel.fromJson(json);

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  
    String id;
    String name;
    String email;
    String phone;
    int coin;
    int isVip;

    UserModel({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.coin,
        this.isVip,
    });

    factory UserModel.fromJson(Map<String,dynamic> json) => UserModel(
        id: json["_id"],
        name: json["username"],
        email: json["email"],
        phone: json["phone"] == null ? "Add phone" : json["phone"],
        coin: json["coin"] == null ? 0 : json["coin"],
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
