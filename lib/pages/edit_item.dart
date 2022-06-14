import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../models/item.dart';
import '../services/snack_bar.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

class ItemEditPage extends StatefulWidget {

  final String? id;
  ItemEditPage({Key? key, required this.id}) : super(key: key);
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  final costController = TextEditingController();

  @override
  _ItemEditPageState createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {

  late UserPerson user;
  Item? item;
  Item itemEdit = Item();
  var db = DatabaseService();
  File? pickedFile;
  UploadTask? uploadTask;

  final formKey = GlobalKey<FormState>();

  _buttonSave(Item? itemEdit)async{
    itemEdit?.description = widget.descriptionController.text;
    itemEdit?.name = widget.nameController.text.trim();
    itemEdit?.cost = int.parse(widget.costController.text.trim());
    itemEdit?.authorId = user.id;
    //itemEdit?.author = user.name;
    if(pickedFile != null){
      final path = 'files/$pickedFile';
      final file = pickedFile;

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file!);

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      itemEdit?.imagePath = urlDownload;
    }
    await DatabaseService().addOrUpdateItem(itemEdit!);

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserPerson>(context);

    return StreamBuilder<Item>(
        stream: DatabaseService(uid: widget.id).getItemById,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Item? item = snapshot.data;
            widget.descriptionController.text = item!.description!;
            widget.nameController.text = item.name!;
            widget.costController.text = item.cost.toString();
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
                              padding: const EdgeInsets.only(bottom: 10.0, left: 30.0),
                              child: input("Введите название", widget.nameController, false, false, 1, (value) =>
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
                                  else if(item.imagePath != null)
                                    Center(
                                        child: AspectRatio(
                                          aspectRatio: 1.5,
                                          child: Image.network(
                                            item.imagePath.toString(),
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
                                  controller: widget.descriptionController,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  controller: widget.costController,
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
                                child: button("Сохранить",(){_buttonSave(item);}),
                              ),
                            )
                            // SizedBox(
                            //   height: 400,
                            //   child: PersonItemsList(authorId: user?.id,),
                            // )
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