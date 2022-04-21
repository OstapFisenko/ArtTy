import 'package:artty_app/models/order.dart';
import 'package:artty_app/services/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../widgets/button.dart';
import 'orders.dart';

class ItemPage extends StatefulWidget {

  final String? id;

  const ItemPage({Key? key, required this.id}) : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}


class _ItemPageState extends State<ItemPage> {
  UserPerson? user;
  var db = DatabaseService();
  Order order = Order();

  _orderButton(UserData userData, Item item) async {

    order.userId = item.authorId;
    order.userClientId = userData.id;
    order.userClientName = userData.name;
    order.userClientEmail = userData.email;
    order.itemId = item.id;
    order.itemName = item.name;
    order.itemDescription = item.description;
    order.itemImagePath = item.imagePath;
    order.itemCost = item.cost;
    await db.addOrder(order);
    Navigator.pop(context);
  }

  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserPerson?>(context);
    return StreamBuilder<Item>(
        stream: DatabaseService(uid: widget.id).getItemById,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Item? item = snapshot.data;
            String desc = item!.description.toString();
            String? authName = item.author;
            return StreamBuilder<UserData>(
              stream: DatabaseService().userData,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  UserData? userData = snapshot.data;
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
                                          padding: const EdgeInsets.all(20),
                                          alignment: Alignment.center,
                                          child: Text(
                                            item.name.toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        if(item.imagePath != null)
                                          Center(
                                              child: AspectRatio(
                                                aspectRatio: 1.7,
                                                child: Image.network(
                                                  item.imagePath.toString(),
                                                ),
                                              )
                                          ),
                                        if(item.imagePath == null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                            child: Image.asset(
                                              'assets/images/work_image.png',
                                              height: 220,
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(20,30,20,15),
                                          child: Container(
                                            padding: const EdgeInsets.all(13),
                                            height: 55,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(width: 2),
                                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                            ),
                                            child: Text(
                                              authName.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(13),
                                            height: 55,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(width: 2),
                                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                            ),
                                            child: Text(
                                              item.userEmail.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(width: 2),
                                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                            ),
                                            child: Text(
                                              desc,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(20, 15, 10, 15),
                                              child: Container(
                                                padding: const EdgeInsets.all(13),
                                                height: 55,
                                                width: 310,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 2),
                                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                ),
                                                child: Text(
                                                  item.cost.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: Image.asset(
                                                'assets/images/rouble_icon.png',
                                                width: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        StreamBuilder<List<Order>>(
                                          stream: db.getOrdersByClient(userData!.id.toString()),
                                          builder: (context, snapshot) {
                                            if(snapshot.hasData){
                                              List<Order>? orders = snapshot.data;
                                              try{
                                                order = orders!.firstWhere((order) => order.itemId == item.id);
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        height: 50,
                                                        width: 250,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                                        ),
                                                        child: const Text(
                                                          'Заявка оформлена',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w500,
                                                            letterSpacing: 2.0,
                                                            color: Colors.white
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                                      child: SizedBox(
                                                        height: 50,
                                                        width: 250,
                                                        child: button("Отменить заявку",(){
                                                          db.deleteOrder(order);
                                                          Utils.showSnackBar("Заявка отменена");
                                                        }),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } catch(e) {
                                                if(userData.id == item.authorId){
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 250,
                                                      child: button("Перейти к заявкам",(){
                                                        Navigator.push(
                                                            context, MaterialPageRoute(builder: (context) => const OrdersPage()));
                                                      }),
                                                    ),
                                                  );
                                                } else {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 250,
                                                      child: button("Оставить заявку",(){
                                                        _orderButton(userData, item);
                                                      }),
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                          },
                                        ),
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
                }
                else{
                  return const Center(child: CircularProgressIndicator());
                }
              }
            );
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}