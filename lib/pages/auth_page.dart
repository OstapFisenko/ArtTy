import 'package:artty_app/pages/home.dart';
import 'package:artty_app/pages/registration.dart';
import 'package:artty_app/services/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import '../models/user.dart';
import '../services/auth.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService _authService = AuthService();

  // bool showLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _regButton(){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Register()));
    _passwordController.clear();
    _emailController.clear();
  }


  @override
  Widget build(BuildContext context) {

    Future<UserPerson?> _buttonEnter() async {

      try {
        UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),);
        User user = result.user!;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage())
        );
        return UserPerson.fromFirebase(user);
      } on FirebaseAuthException catch (e) {
        print(e);
        Utils.showSnackBar(e.message);
        return null;
      }
      // navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }



    Widget _form(){
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 190, bottom: 15),
            child: input("EMAIL", _emailController, false, false, 1, (email) => !isEmail(email)
                ? 'Введите корректный email'
                : null),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: input("PASSWORD", _passwordController, true, false, 1, null),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: SizedBox(
              height: 50,
              width: 200,
              child: button("Войти", _buttonEnter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SizedBox(
              height: 50,
              width: 200,
              child: button("Регистрация", _regButton),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/images/logo_white.png',
                width: 240,
              ),
            ),
            SingleChildScrollView(child: Padding(
              padding: const EdgeInsets.only(top: 270),
              child: _form(),
            ))
          ],
        ),
      ),
    );
  }
}