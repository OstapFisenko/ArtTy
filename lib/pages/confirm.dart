import 'dart:async';

import 'package:artty_app/models/user.dart';
import 'package:artty_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({Key? key}) : super(key: key);

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  User? user;
  final auth = FirebaseAuth.instance;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser;
    try{
      user?.sendEmailVerification();
    } catch (e) {
      print(e);
    }
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      chekEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_title.png',
          width: 80,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2)
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    'На электронные почту ${user?.email} было отправлено письмо. Для завершения регистрации перейдитие по ссылке в письме и подтвердите вашу почту.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Future<void> chekEmailVerified() async{
    user = auth.currentUser;
    await user?.reload();
    if(user!.emailVerified){
      timer?.cancel();
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomePage()));
    }
    else{
      print('email verified = false');
    }
  }
}
