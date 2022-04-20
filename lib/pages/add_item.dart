import 'package:artty_app/widgets/button.dart';
import 'package:flutter/material.dart';
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

  final _description = TextEditingController();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  late UserPerson user;
  late UserData? userData;
  Item itemEdit = Item();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.item != null) itemEdit = widget.item!.copy();
    super.initState();
  }


  _saveButton(String? name, String? email) async {
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    itemEdit.author = name;
    itemEdit.authorId = user.id;
    itemEdit.description = _description.text.trim();
    itemEdit.userEmail = email;
    itemEdit.name = _nameController.text.trim();
    itemEdit.cost = double.parse(_costController.text);


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
                            Form(
                              key: formKey,
                              child: Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 10.0, left: 30.0),
                                child: input("Введите название", _nameController, false, false, 1, (value) =>
                                  value != null && value.length < 3
                                      ? 'Слишком короткое название'
                                      : null),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  border: Border.all(width: 2)
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Text(
                                        "Загрузить изображение",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Image.asset(
                                        'assets/images/download.png',
                                        width: 70,
                                      ),
                                    ),
                                  ],
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
                                  controller: _description,
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
                                  controller: _costController,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                height: 50,
                                width: 200,
                                child: button("Сохранить",(){_saveButton(userData.name, userData.email);}),
                              ),
                            ),
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
// return Scaffold(
// backgroundColor: Colors.white,
// body: SingleChildScrollView(
// child: Column(
// children: [
// Row(
// children: [
// Padding(
// padding: EdgeInsets.symmetric(vertical: 40),
// child: IconButton(
// onPressed: (){
// Navigator.pop(context);
// },
// icon: const Icon(
// Icons.arrow_back_ios_new_rounded,
// size: 40,
// ),
// ),
// ),
// input("Название", _nameController, false, false, 1, null, (value) =>
// value != null && value.length < 3
// ? 'Слишком короткое название'
//     : null)
// ],
// ),
//
// Padding(
// padding: const EdgeInsets.only(top: 30.0),
// child: LayoutBuilder(
// builder: (context, constraints) {
// return SizedBox(
// // height: constraints.maxHeight / 9,
// child: input('Описание', _description, false, true, null, null, null)
// );
// }),
// ),
//
// Padding(
// padding: const EdgeInsets.symmetric(vertical: 20.0),
// child: button("Save",(){_saveButton(userData!.name, userData.email);}),
// )
// ],
// ),
// ),
// );