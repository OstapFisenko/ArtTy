import 'package:artty_app/models/user.dart';
import 'package:artty_app/pages/auth_page.dart';
import 'package:artty_app/pages/edit_profile.dart';
import 'package:artty_app/pages/home.dart';
import 'package:artty_app/pages/leading.dart';
import 'package:artty_app/pages/profile.dart';
import 'package:artty_app/services/auth.dart';
import 'package:artty_app/services/snack_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserPerson?>.value(
      value: AuthService().currentUser,
      initialData: null,
      child: MaterialApp(
        scaffoldMessengerKey: messengerKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'IBM'),
        home: LeadingPage(),
      ),
    );
  }
}


