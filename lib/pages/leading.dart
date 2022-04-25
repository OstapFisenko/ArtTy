import 'package:artty_app/models/user.dart';
import 'package:artty_app/pages/auth_page.dart';
import 'package:artty_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeadingPage extends StatelessWidget {
  const LeadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserPerson?>(context);

    if(user == null){
      return AuthPage();
    } else {
      return HomePage();
    }
  }
}
