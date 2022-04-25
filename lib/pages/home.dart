import 'package:artty_app/models/user.dart';
import 'package:artty_app/pages/orders.dart';
import 'package:artty_app/pages/profile.dart';
import 'package:artty_app/services/database.dart';
import 'package:artty_app/widgets/item_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: DatabaseService().userData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          UserData? user = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: RawMaterialButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ProfilePage()));
                },
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.0,
                      )
                  ),
                  child: Column(
                    children: [
                      if(user!.imagePath != null)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(
                                  user.imagePath.toString(),
                                ),
                                fit: BoxFit.cover
                            ),
                          ),
                        )
                      else
                        Image.asset(
                          'assets/images/profile_Icon.png',
                        ),
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              title: Image.asset(
                'assets/images/logo_title.png',
                width: 80,
              ),
              actions: [
                Container(
                  alignment: Alignment.topLeft,
                  width: 56,
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.0,
                      )
                  ),
                  child: IconButton(
                    onPressed: (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => OrdersPage()));
                    },
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                )
              ],
            ),
            body: const Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: ItemList(),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }
}