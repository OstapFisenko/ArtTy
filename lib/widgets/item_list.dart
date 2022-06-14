import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../pages/item.dart';
import '../services/database.dart';

class ItemList extends StatefulWidget {
  final Item? item;
  const ItemList({Key? key, this.item}) : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final _searchController = TextEditingController();
  String? text;
  List<Item> items = [];
  Timer? debouncer;

  late UserPerson user;

  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      itemsStreamSubscription?.cancel();
    }
    debouncer?.cancel();
    super.dispose();
  }

  void debounce(VoidCallback callback, {Duration duration = const Duration(milliseconds: 1000),}) {
    if(debouncer != null){
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: DatabaseService().getItems(null),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.hasData != true){
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if(_searchController.text.isEmpty || items.isEmpty){
            items = snapshot.data!;
          }
          // else if(_searchController.text.isNotEmpty && items!.isEmpty){
          // }
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Container(
                //   height: 50,
                //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(15),
                //     color: Colors.white,
                //     border: Border.all(color: Colors.black, width: 2)
                //   ),
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: TextField(
                //     controller: _searchController,
                //     decoration: InputDecoration(
                //       icon: const Icon(Icons.search, color: Colors.black,),
                //       suffixIcon: _searchController.text.isNotEmpty ? GestureDetector(
                //         child: const Icon(Icons.clear_rounded, color: Colors.black,),
                //         onTap: (){
                //           _searchController.clear();
                //           FocusScope.of(context).requestFocus(FocusNode());
                //         },
                //       ) : null,
                //       hintText: 'Введите название картины...',
                //       border: InputBorder.none,
                //     ),
                //     onSubmitted: (value) {
                //
                //       setState(() {
                //         items = items.where((item) => item.name!.toLowerCase()
                //             .contains(value.toString().trim().toLowerCase())).toList();
                //         log(items.toString());
                //       });
                //     },
                //   ),
                // ),
                if(items.length != null)
                  SizedBox(
                    height: 743,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        return InkWell(
                          child: Container(
                            key: Key(items[i].id.toString()),
                            margin: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 30),
                            child: Container(
                                decoration: const BoxDecoration(color: Color(0xfff1f2f4),),
                                padding: const EdgeInsets.only(bottom: 10),
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
                                      padding: const EdgeInsets.only(top: 5.0),
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
                          onTap: (){
                            Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) =>
                                    ItemPage(id: items[i].id))
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  const SingleChildScrollView(),
              ],
            ),
          );
        }
      },
    );
  }

}