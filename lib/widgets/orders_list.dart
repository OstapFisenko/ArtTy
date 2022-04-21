import 'package:artty_app/models/order.dart';
import 'package:artty_app/pages/order_item.dart';
import 'package:artty_app/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item.dart';
import '../pages/auth_page.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../services/snack_bar.dart';

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
                          vertical: 10.0, horizontal: 20),
                      child: Container(
                        height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            border: Border.all(color: Colors.black, width: 2.0,),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if(orders[i].itemImagePath != null)
                                Container(
                                  height: 100,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(orders[i].itemImagePath.toString()),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  height: 100,
                                  width: 110,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/work_image.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Container(
                                width: 190.5,
                                decoration: const BoxDecoration(
                                  border: Border(left: BorderSide(width: 2.0, color: Colors.black)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                                      alignment: Alignment.topLeft,
                                      child: SizedBox(
                                        width: 170,
                                        child: Text(
                                          'Имя: ' + orders[i].userClientName.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                      alignment: Alignment.topLeft,
                                      child: SizedBox(
                                        width: 170,
                                        child: Text(
                                          'Email: ' + orders[i].userClientEmail.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          style: const TextStyle(
                                            fontSize: 14
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.redAccent,),
                                  onPressed: (){
                                    db.deleteOrder(orders[i]);
                                    Utils.showSnackBar("Заявка отклонена");
                                  },
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
                              OrderItem(id: orders[i].id))
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "На ваши работы нет ни одной заявки",
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