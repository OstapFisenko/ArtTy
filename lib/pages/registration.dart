import 'dart:async';
import 'dart:io';

import 'package:artty_app/pages/auth_page.dart';
import 'package:artty_app/pages/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../services/snack_bar.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordChekController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late UserPerson? user;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  var db = DatabaseService(uid: '');
  StreamSubscription<List<Item>>? itemsStreamSubscription;
  var items = <Item>[];
  String? imagePath;

  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      print('Unsubscribing');
      itemsStreamSubscription?.cancel();
    }

    super.dispose();
  }

  Future<void> loadData() async{
    var stream = db.getItems(null);

    itemsStreamSubscription = stream.listen((List<Item> data) {
      setState(() {
        items = data;
      });
    });
  }
  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserPerson?>(context);

    Future _buttonReg() async{
      final isValid = formKey.currentState!.validate();
      if(!isValid) return;

      try {
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User user = result.user!;
        if(pickedFile != null){
          final path = 'users/${pickedFile!.name}';
          final file = File(pickedFile!.path!);

          final ref = FirebaseStorage.instance.ref().child(path);
          uploadTask = ref.putFile(file);

          final snapshot = await uploadTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          imagePath = urlDownload;
        }
        await DatabaseService(uid: user.uid).updateUserData(_nameController.text.trim(), _emailController.text.trim(), imagePath);
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomePage()));
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _passwordChekController.clear();
        return UserPerson.fromFirebase(user);
      } on FirebaseAuthException catch (e) {
        print(e);

        Utils.showSnackBar(e.message);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Stack(
          children: [

            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 220),
              child: Image.asset(
                'assets/images/logo_grey.png',
                width: 240,
              ),
            ),
            SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: [
                        if(pickedFile == null)
                          Image.asset(
                            'assets/images/person_avatar.png',
                            width: 200,
                          ),
                        if(pickedFile != null)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(
                                  File(pickedFile!.path!),
                                ),
                                fit: BoxFit.cover
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 55.0),
                          child: IconButton(
                            icon: Image.asset(
                              'assets/images/download.png',
                            ),
                            iconSize: 75,
                            onPressed: selectFile,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 190,bottom: 10.0),
                    child: input('Имя', _nameController, false, false, 1, (value) =>
                    value != null && value.length < 3
                        ? 'Слишком короткое имя'
                        : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: input('Email', _emailController, false, false, 1, (email) => !isEmail(email)
                        ? 'Введите корректный email'
                        : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: input('Пароль', _passwordController, true, false, 1, (value) =>
                    value != null && value.length < 6
                        ? 'Слишком короткий пароль'
                        : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: input('Повторите пароль', _passwordChekController, true, false, 1, (value) =>
                    value.isEmpty || (value != null && value != _passwordController.text)
                        ? 'Пароли отличаются'
                        : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      height: 50,
                      width: 240,
                      child: button('Регистрация', _buttonReg),
                    ),
                  ),
                ],
              ),
            ),
          ),
            IconButton(
              onPressed: (){
                Navigator.pop(context);
                _nameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _passwordChekController.clear();
                },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 40,
              ),
            ),
          ]
        ),
      ),
    );
  }
}
