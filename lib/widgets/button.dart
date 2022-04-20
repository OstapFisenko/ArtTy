import 'package:flutter/material.dart';

Widget button(String text, void func()){
  return MaterialButton(
    padding: const EdgeInsets.all(0.0),
    splashColor: Colors.grey,
    elevation: 0,
    highlightColor: Colors.grey,
    color: Colors.white,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
      borderSide: BorderSide(width: 2.0)
    ),
    child: Text(
      text,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
      ),
    ),
    onPressed: (){
      func();
    },
  );
}