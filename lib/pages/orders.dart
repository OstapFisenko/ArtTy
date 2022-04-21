import 'dart:async';

import 'package:artty_app/widgets/orders_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  UserPerson? user;
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

    user = Provider.of<UserPerson?>(context);

    return StreamBuilder<UserData>(
      stream: db.userData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          UserData? userData = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              padding: const EdgeInsets.only(top: 50),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    height: MediaQuery.of(context).size.height,
                    child: OrdersList(authorId: userData!.id),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(width: 2, color: Colors.black))
                    ),
                    child: const Text(
                      "Заявки",
                      style: TextStyle(
                        fontSize: 20,
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
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}
