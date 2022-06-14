import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:artty_app/widgets/input.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../services/snack_bar.dart';
import '../widgets/edit_items_list.dart';

class ProfileEdit extends StatefulWidget {
  ProfileEdit({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();

  @override
  _ProfileEditState createState() => _ProfileEditState();
}



class _ProfileEditState extends State<ProfileEdit> {


  late UserPerson user;
  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;
  File? pickedFile;
  UploadTask? uploadTask;

  String? imagePath;

  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      log('Unsubscribing');
      itemsStreamSubscription?.cancel();
    }
    super.dispose();
  }
  Widget bottomSheetPicker() {
    return Container(
      color: const Color(0xFF737373),
      child: Container(
        height: 220.0,
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
              'Загрузить изображение',
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

  _buttonSave(String? name, String? email, String? imagePath)async{
    if(pickedFile != null){
      final path = 'users/$pickedFile';
      final file = pickedFile;

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file!);

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      imagePath = urlDownload;
    }
    await DatabaseService().updateUserData(name, email, imagePath);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {

    user = Provider.of<UserPerson>(context);


    return StreamBuilder<UserData>(
        stream: DatabaseService().userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            UserData? userData = snapshot.data;
            imagePath = userData!.imagePath;
            widget.nameController.text = userData.name!;
            return Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
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
                                  else if(userData.imagePath != null)
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              userData.imagePath.toString(),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 65.0, horizontal: 60.0),
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            enableDrag: false,
                                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                            builder: ((builder) => bottomSheetPicker()),
                                          );
                                        },
                                        icon: Image.asset('assets/images/download.png'),
                                        iconSize: 70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: input('', widget.nameController, false, false, 1, (value) =>
                              value != null && value.length < 3
                                  ? 'Слишком короткое имя'
                                  : null),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                ),
                                child: Text(
                                  userData.email!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 400,
                              child: UserItemsEdit(authorId: user.id, authorName: userData.name),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 40,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          onPressed: (){
                            _buttonSave(widget.nameController.text, userData.email, imagePath);
                          },
                          icon: const Icon(
                            Icons.save_outlined,
                            size: 40,
                          ),
                        ),
                      )
                    ]
                ),
              ),
            );
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}
