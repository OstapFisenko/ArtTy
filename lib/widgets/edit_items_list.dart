import 'package:artty_app/pages/edit_item.dart';
import 'package:artty_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item.dart';
import '../pages/add_item.dart';
import '../services/database.dart';
import '../services/snack_bar.dart';

class UserItemsEdit extends StatefulWidget {

  final String? authorId;
  final String? authorName;
  const UserItemsEdit({Key? key, required this.authorId, required this.authorName}) : super(key: key);

  @override
  State<UserItemsEdit> createState() => _UserItemsEditState();
}

class _UserItemsEditState extends State<UserItemsEdit> {
  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;


  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      print('Unsubscribing');
      itemsStreamSubscription?.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
        stream: DatabaseService().getItems(widget.authorId),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Item>? items = snapshot.data;
            return ListView.builder(
              itemCount: items!.length+1,
              itemBuilder: (context, int i){
                if(i == items.length){
                  return Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 90),
                    child: button("Добавить работу", (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => AddItem()));
                    })
                  );
                }
                return InkWell(
                  child: Container(
                    key: Key(items[i].id.toString()),
                    margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30),
                    child: Container(
                        decoration: const BoxDecoration(color: Color(0xfff1f2f4),),
                        child: Column(
                          children: [
                            if(items[i].imagePath != null)
                              Center(
                                child: AspectRatio(
                                  aspectRatio: 1.4,
                                  child: Image.network(
                                    items[i].imagePath.toString(),
                                  ),
                                ),
                              )
                            else
                              Image.asset('assets/images/work_image.png'),
                            Container(
                              padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                              alignment: Alignment.topLeft,
                              child: Text(
                                items[i].name.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 40,
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.redAccent, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(25.0))
                              ),
                              child: MaterialButton(
                                onPressed: (){
                                  db.deleteItem(items[i]);
                                  Utils.showSnackBar("Успешно удалено");
                                },
                                minWidth: double.infinity,
                                child: const Text(
                                  "Удалить",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>
                            ItemEditPage(id: items[i].id))
                    );
                  },
                );
              },
            );
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}
