import 'package:flutter/material.dart';

Widget input(String hint, TextEditingController controller, bool obscure, bool expand, final maxLines, final validator){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        border: Border.all(width: 2)
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
          hintStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.black
          ),
          hintText: hint,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),
        ),
        expands: expand,
        maxLines: maxLines,
        controller: controller,
        obscureText: obscure,
        cursorColor: Colors.black,
        style: const TextStyle(
          fontSize: 18,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
      ),
    ),
  );
}