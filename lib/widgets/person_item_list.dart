import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item.dart';
import '../pages/item.dart';
import '../services/database.dart';

class PersonItemsList extends StatefulWidget {

  final String? authorId;

  const PersonItemsList({Key? key, required this.authorId}) : super(key: key);

  @override
  State<PersonItemsList> createState() => _PersonItemsListState();
}

class _PersonItemsListState extends State<PersonItemsList> {
  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;


  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      log('Unsubscribing');
      itemsStreamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
        stream: db.getItems(widget.authorId),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Item>? items = snapshot.data;
            return ListView.builder(
              itemCount: items!.length,
              itemBuilder: (context, int i){
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                    child: Container(
                      key: Key(items[i].id.toString()),
                      child: Container(
                          decoration: const BoxDecoration(color: Color(0xfff1f2f4),),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Stack(
                                  children: [
                                    Image.asset('assets/images/work_image.png'),
                                    if(items[i].imagePath != null)
                                      Center(
                                        child: AspectRatio(
                                          aspectRatio: 1.4,
                                          child: Image.network(
                                            items[i].imagePath.toString(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.topCenter,
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