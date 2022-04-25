import 'package:artty_app/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item.dart';
import '../pages/auth_page.dart';
import '../services/auth.dart';
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
      print('Unsubscribing');
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
              itemCount: items!.length+1,
              itemBuilder: (context, int i){
                if(i == items.length){
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 90),
                    height: 50,
                    child: button("Выйти", (){
                      AuthService().logOut();
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => AuthPage()));
                    })
                  );
                }
                return InkWell(
                  child: Container(
                    key: Key(items[i].id.toString()),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 30),
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
                            )
                          ],
                        )
                    ),
                  ),
                  onTap: (){
                    // Navigator.push(
                    //     context, MaterialPageRoute(
                    //     builder: (context) =>
                    //         ItemPage(id: items[i].id))
                    // );
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