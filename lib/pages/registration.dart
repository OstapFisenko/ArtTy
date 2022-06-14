import 'dart:async';
import 'dart:io';
import 'package:artty_app/pages/confirm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  File? pickedFile;
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

  Widget bottomSheetPicker() {
    return Container(
      color: const Color(0xFF737373),
      child: Container(
        height: 200.0,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Выбирите фото',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Камера',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        onPressed: (){
                          selectFile(ImageSource.camera);
                        },
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 50,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Галерея',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        onPressed: (){
                          selectFile(ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icons.photo,
                          size: 50,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future selectFile(ImageSource source) async{
    try {
      final result = await ImagePicker().pickImage(source: source);
      if(result == null) return;
      setState(() {
        pickedFile = File(result.path);
      });
    } on PlatformException catch (e) {
      Utils.showSnackBar('$e');
    }
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
          final path = 'users/${pickedFile!.path}';
          final file = pickedFile;

          final ref = FirebaseStorage.instance.ref().child(path);
          uploadTask = ref.putFile(file!);

          final snapshot = await uploadTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          imagePath = urlDownload;
        }
        await DatabaseService(uid: user.uid).updateUserData(_nameController.text.trim(), _emailController.text.trim(), imagePath);
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => ConfirmEmail()));
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
              padding: const EdgeInsets.only(top: 210),
              child: Image.asset(
                'assets/images/logo_grey.png',
                width: 200,
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
                        if(pickedFile != null)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: FileImage(
                                    pickedFile!,
                                  ),
                                  fit: BoxFit.cover
                              ),
                            ),
                          )
                        else
                          Image.asset(
                            'assets/images/person_avatar.png',
                            width: 200,
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 55.0),
                          child: IconButton(
                            icon: Image.asset(
                              'assets/images/download.png',
                            ),
                            iconSize: 75,
                            onPressed: bottomSheetPicker,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 195,bottom: 10.0),
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
