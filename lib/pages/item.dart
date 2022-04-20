import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';
import '../widgets/button.dart';
import 'home.dart';

class ItemPage extends StatefulWidget {

  final String? id;

  const ItemPage({Key? key, required this.id}) : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}


class _ItemPageState extends State<ItemPage> {
  UserPerson? user;
  var db = DatabaseService();
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
            return Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
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
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 10, 20, 10),
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
                                  item.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Image.asset(
                                'assets/images/work_image.png',
                                height: 220,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                height: 50,
                                width: 200,
                                child: button("Купить",(){
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => const HomePage())
                                  );
                                }),
                              ),
                            )
                            // SizedBox(
                            //   height: 400,
                            //   child: PersonItemsList(authorId: user?.id,),
                            // )
                          ],
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
              ),
            );
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        }
    );

  }
}