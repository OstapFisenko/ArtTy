import 'package:firebase_auth/firebase_auth.dart';

class UserPerson {
  String? id;
  String? email;
  String? name;
  String? image;

  UserPerson({this.id, this.email, this.name, this.image});

  UserPerson.fromFirebase(User user){
    id = user.uid;
    email = user.email;
    image = user.photoURL;
    name = user.displayName;
  }


  UserPerson.fromJson(String uid, Map<String, dynamic> data) {
    id = uid;
    email = data['email'];
    image = data['photoUrl'];
    name = data['displayName'];
  }
}

class UserData{
  String? id;
  String? email;
  String? name;
  String? imagePath;

  UserData({this.id,this.email,this.name, this.imagePath});

  UserData.fromJson(String uid, Map<String, dynamic> data) {
    id = uid;
    email = data['email'];
    name = data['name'];
    imagePath = data['imagePath'];
  }
}