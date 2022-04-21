import 'package:artty_app/models/order.dart';
import 'package:artty_app/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item.dart';
import '../pages/auth_page.dart';
import '../services/auth.dart';
import '../services/database.dart';

class OrdersList extends StatefulWidget {

  final String? authorId;

  const OrdersList({Key? key, required this.authorId}) : super(key: key);

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  DatabaseService db = DatabaseService();
  StreamSubscription<List<Order>>? ordersStreamSubscription;


  @override
  void dispose() {
    if(ordersStreamSubscription != null){
      print('Unsubscribing');
      ordersStreamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
        stream: db.getOrders(widget.authorId),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Order>? orders = snapshot.data;
            return ListView.builder(
              itemCount: orders!.length,
              itemBuilder: (context, int i){
                if(orders.isNotEmpty){
                  return InkWell(
                    child: Container(
                      key: Key(orders[i].id.toString()),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 30),
                      child: Container(
                          decoration: const BoxDecoration(color: Colors.white,),
                          child: Column(
                            children: [
                              if(orders[i].itemImagePath != null)
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: 1.4,
                                    child: Image.network(
                                      orders[i].itemImagePath.toString(),
                                    ),
                                  ),
                                )
                              else
                                Image.asset('assets/images/work_image.png'),
                              Container(
                                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  orders[i].itemName.toString(),
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
                } else {
                  return const Center(
                    child: Text(
                      "На ваши работы нет ни одной заявки",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  );
                }
              },
            );
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        }
    );

  }
}