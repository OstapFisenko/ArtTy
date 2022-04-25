import 'package:artty_app/models/order.dart';
import 'package:artty_app/services/database.dart';
import 'package:artty_app/services/snack_bar.dart';
import 'package:artty_app/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderItem extends StatefulWidget {
  final String? id;
  const OrderItem({Key? key, required this.id}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Order>(
      stream: DatabaseService(uid: widget.id).getOrderById,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Order? order = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              padding: const EdgeInsets.only(top: 50),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 80),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if(order!.itemImagePath != null)
                                  Container(
                                    height: 200,
                                    width: 350,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(order.itemImagePath.toString()),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    height: 200,
                                    width: 350,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black, width: 2),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/work_image.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 3, left: 10),
                            child: Text(
                              "Имя покупателя: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20,30,20,15),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      "assets/images/person_avatar.png",
                                      width: 50,
                                    ),
                                    if(order.authorPhoto != null)
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                order.authorPhoto.toString(),
                                              ),
                                              fit: BoxFit.cover
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,30,20,15),
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  height: 55,
                                  width: 282,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 2),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: Text(
                                    order.userClientName.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 3, left: 10),
                            child: Text(
                              "Email покупателя: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(13),
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Text(
                              order.userClientEmail!,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 3, left: 10),
                            child: Text(
                              "Цена: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
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
                                    order.itemCost.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/rouble_icon.png',
                                width: 30,
                              ),
                            ],
                          ),
                          if(order.status == 'considered')
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              alignment: Alignment.center,
                              child: button('Принять', () async{
                                order.status = 'approved';
                                await DatabaseService().addOrder(order);
                                Utils.showInfo('Заявка принята, покупателю на почту отправленно письмо');
                              }),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 230,
                              height: 45,
                              child: MaterialButton(
                                splashColor: Colors.red,
                                elevation: 0,
                                highlightColor: Colors.red,
                                color: Colors.white,
                                shape: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                    borderSide: BorderSide(width: 2.0, color: Colors.redAccent)
                                ),
                                child: const Text(
                                  "Удалить заявку",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.redAccent,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                onPressed: (){
                                  DatabaseService().deleteOrder(order);
                                  Utils.showSnackBar("Заявка успешно удалена");
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
                    child: Text(
                      order.itemName!,
                      style: const TextStyle(
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
          return const Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}
