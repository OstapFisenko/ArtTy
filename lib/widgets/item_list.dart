import 'dart:async';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../pages/item.dart';
import '../services/database.dart';

class ItemList extends StatefulWidget {
  final Item? item;
  const ItemList({Key? key, this.item}) : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  late UserPerson user;

  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;

  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      itemsStreamSubscription?.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
        stream: DatabaseService().getItems(null),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Item>? items = snapshot.data;
            return ListView.builder(
              itemCount: items?.length,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Container(
                    key: Key(items![i].id.toString()),
                    margin: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white,),
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
                          )
                        ],
                      )
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>
                            ItemPage(id: items[i].id))
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