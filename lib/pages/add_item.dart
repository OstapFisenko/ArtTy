import 'dart:developer';
import 'dart:io';
import 'package:artty_app/services/snack_bar.dart';
import 'package:artty_app/widgets/button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../widgets/input.dart';
import 'package:flutter/services.dart';

class AddItem extends StatefulWidget {
  final Item? item;

  const AddItem({Key? key, this.item}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {

  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  late UserPerson user;
  late UserData? userData;
  Item itemEdit = Item();
  File? pickedFile;
  UploadTask? uploadTask;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.item != null) itemEdit = widget.item!.copy();
    super.initState();
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
                        onPressed: () {
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
    } on Exception catch (e) {
      Utils.showSnackBar('$e');
      log('$e');
    }
  }

  _saveButton(String? name, String? email, String? authorPhoto) async {
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    itemEdit.author = name;
    itemEdit.authorId = user.id;
    itemEdit.description = _descriptionController.text.trim();
    itemEdit.userEmail = email;
    itemEdit.name = _nameController.text.trim();
    itemEdit.authorPhoto = authorPhoto;
    itemEdit.cost = int.parse(_costController.text);

    if(pickedFile != null){
      final path = 'files/${pickedFile!.path}';
      final file = pickedFile;

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file!);

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      itemEdit.imagePath = urlDownload;
    }

    await DatabaseService().addOrUpdateItem(itemEdit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserPerson>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: null).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            UserData? userData = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 10.0, left: 30.0),
                                child: input("Введите название", _nameController, false, false, 1, (value) =>
                                  value != null && value.length < 3
                                      ? 'Слишком короткое название'
                                      : null),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Stack(
                                  children: [
                                    if(pickedFile != null)
                                      Center(
                                          child: AspectRatio(
                                            aspectRatio: 1.5,
                                            child: Image.file(
                                              pickedFile!,
                                            ),
                                          )
                                      )
                                    else
                                      Container(
                                        alignment: Alignment.topCenter,
                                        width: double.infinity,
                                        height: 235,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            border: Border.all(width: 2)
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Text(
                                            "Загрузить изображение",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 65.0, horizontal: 65.0),
                                      child: IconButton(
                                        onPressed: (){
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
                                  ],
                                ),
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
                                    userData!.name!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                      border: Border.all(width: 2)
                                  ),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                          color: Colors.black,
                                      ),
                                      hintText: "Введите описание",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent, width: 0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent, width: 0),
                                      ),
                                    ),
                                    maxLines: null,
                                    controller: _descriptionController,
                                    cursorColor: Colors.black,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                      border: Border.all(width: 2)
                                  ),
                                  child: TextFormField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      hintText: "Введите цену",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent, width: 0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent, width: 0),
                                      ),
                                    ),
                                    controller: _costController,
                                    cursorColor: Colors.black,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) =>
                                    value!.isEmpty
                                        ? 'Цена не может быть пустой'
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  height: 50,
                                  width: 200,
                                  child: button("Сохранить",(){_saveButton(userData.name, userData.email, userData.imagePath);}),
                                ),
                              ),
                            ],
                          ),
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