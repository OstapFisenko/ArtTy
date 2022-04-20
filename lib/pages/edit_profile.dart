import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:artty_app/widgets/input.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
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
  PlatformFile? pickedFile;
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

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  _buttonSave(String? name, String? email, String? imagePath)async{
    if(pickedFile != null){
      final path = 'files/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

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
            widget.nameController.text = userData!.name!;
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
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/images/person_avatar.png',
                                    width: 200,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 65.0),
                                    child: Image.asset(
                                      'assets/images/download.png',
                                      width: 70,
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
