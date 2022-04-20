import 'package:artty_app/pages/profile.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: Border.all(
            width: 2
        ),
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
            child: Image.asset(
              'assets/images/profile_Icon.png',
            ),
          ),
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)
            ),
            hintText: 'Ведите название работы ...',
            hintStyle: TextStyle(
              fontSize: 15,
            ),
          ),
          cursorColor: Colors.black,
        ),
        actions: [
          Container(
            width: 56,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 2.0,
                )
            ),
            child: IconButton(
              onPressed: (){},
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.black,
                size: 40,
              ),
            ),
          )
        ],
      ),
      body: const ItemList(),
    );
  }
}