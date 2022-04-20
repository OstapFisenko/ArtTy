import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../models/item.dart';
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
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  final formKey = GlobalKey<FormState>();

  _buttonSave(Item? itemEdit)async{
    itemEdit?.description = widget.descriptionController.text;
    itemEdit?.name = widget.nameController.text.trim();
    itemEdit?.cost = double.parse(widget.costController.text.trim());
    itemEdit?.authorId = user.id;
    if(pickedFile != null){
      final path = 'files/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();
      itemEdit?.imagePath = urlDownload;
    }
    await DatabaseService().addOrUpdateItem(itemEdit!);

    Navigator.pop(context);
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
                                          File(pickedFile!.path!),
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
                                    child: IconButton(
                                      onPressed: selectFile,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 40,
                          ),
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