import 'package:firebase_auth/firebase_auth.dart';

class UserPerson {
  String? id;
  String? email;

  UserPerson({this.id, this.email});

  UserPerson.fromFirebase(User user){
    id = user.uid;
    email = user.email;
  }


  UserPerson.fromJson(String uid, Map<String, dynamic> data) {
    id = uid;
    email = data['email'];
  }
}

class UserData{
  String? id;
  String? email;
  String? name;
  String? desc;

  UserData({this.id,this.email,this.name, this.desc});

  UserData.fromJson(String uid, Map<String, dynamic> data) {
    id = uid;
    email = data['email'];
    name = data['name'];
    desc = data['desc'];
  }
}