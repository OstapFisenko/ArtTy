import 'package:flutter/material.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class Utils{
  static showSnackBar(String? text){
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.redAccent,
      duration: Duration(milliseconds: 1000),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static showInfo(String? text) {
    if(text == null) return;

    final snackBarInfo = SnackBar(
      content: Text(text),
      backgroundColor: Colors.green,
      duration: const Duration(milliseconds: 1500),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBarInfo);
  }
}