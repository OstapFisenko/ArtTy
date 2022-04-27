import 'dart:async';
import 'dart:developer';
import 'package:artty_app/pages/edit_profile.dart';
import 'package:artty_app/widgets/person_item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../services/database.dart';

class AuthorProfilePage extends StatefulWidget {
  final String? id;
  const AuthorProfilePage({Key? key, required this.id}) : super(key: key);

  @override
  _AuthorProfilePageState createState() => _AuthorProfilePageState();
}



class _AuthorProfilePageState extends State<AuthorProfilePage> {
  UserPerson? user;
  DatabaseService db = DatabaseService();
  StreamSubscription<List<Item>>? itemsStreamSubscription;

  @override
  void dispose() {
    if(itemsStreamSubscription != null){
      log('Unsubscribing');
      itemsStreamSubscription?.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    user = Provider.of<UserPerson?>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: widget.id).getUserById,
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
                            if(userData!.imagePath != null)
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        userData.imagePath.toString(),
                                      ),
                                      fit: BoxFit.cover
                                  ),
                                ),
                              )
                            else
                              Image.asset(
                                "assets/images/person_avatar.png",
                                width: 200,
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                ),
                                child: Text(
                                  userData.name!,
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
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                ),
                                child: Text(
                                  userData.email!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 400,
                              child: PersonItemsList(authorId: widget.id,),
                            )
                          ],
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
                    ]
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
