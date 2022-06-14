import 'package:artty_app/models/order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../models/user.dart';

class DatabaseService{

  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('items');
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users_info');
  final CollectionReference _ordersCollection = FirebaseFirestore.instance.collection('orders');

  Future updateUserData(String? newName, String? newEmail, String? newPath) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uID = auth.currentUser?.uid.toString();
    return await _usersCollection.doc(uID).set({
      'name': newName,
      'email': newEmail,
      'imagePath' : newPath,
    });
  }

  Future addOrUpdateItem(Item item) async {
    DocumentReference itemRef = _itemsCollection.doc(item.id);
    return itemRef.set({
      'Author' : item.author,
      'Description' : item.description,
      'AuthorID' : item.authorId,
      'UserEmail' : item.userEmail,
      'Name' : item.name,
      'Cost' : item.cost,
      'ImagePath' : item.imagePath,
      'AuthorPhoto' : item.authorPhoto,
    });
  }

  Future addOrder(Order order) async {
    DocumentReference orderRef = _ordersCollection.doc(order.id);
    return orderRef.set({
      'userID' : order.userId,
      'userClientId' : order.userClientId,
      'userClientName' : order.userClientName,
      'userClientEmail' : order.userClientEmail,
      'itemId' : order.itemId,
      'itemName' : order.itemName,
      'itemDescription' : order.itemDescription,
      'itemImagePath' : order.itemImagePath,
      'itemCost' : order.itemCost,
      'AuthorPhoto' : order.authorPhoto,
      'Status' : order.status,
    });
  }

  Stream<List<Order>> getOrders(String? authorID){
    Query query;
    if(authorID != null) {
      query = _ordersCollection.where('userID', isEqualTo: authorID);
    } else {
      query = _ordersCollection;
    }
    return query.snapshots().map((QuerySnapshot data) =>
        data.docs.map((DocumentSnapshot doc) {
          return Order.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList());
  }

  Stream<List<Order>> getOrdersByClient(String clientId){
    Query query = _ordersCollection.where('userClientId', isEqualTo: clientId);
    return query.snapshots().map((QuerySnapshot data) =>
        data.docs.map((DocumentSnapshot doc) {
          return Order.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList());
  }

  Stream<Order> get getOrderById{
    return _ordersCollection.doc(uid).snapshots().map((DocumentSnapshot doc) => Order.fromJson(doc.id, doc.data() as Map<String, dynamic>));
  }

  Future deleteOrder(Order order) async {
    DocumentReference orderRef = _ordersCollection.doc(order.id);
    return orderRef.delete();
  }

  Stream<List<Item>> getItems(String? author){
    Query query;
    if(author != null) {
      query = _itemsCollection.where('AuthorID', isEqualTo: author);
    } else {
      query = _itemsCollection;
    }
    return query.snapshots().map((QuerySnapshot data) =>
        data.docs.map((DocumentSnapshot doc) {
          return Item.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList());
  }

  Stream<List<Item>> searchItem(String text) {
    if(text.isNotEmpty){
      return _itemsCollection.where((name) => name['Name'].toString().toLowerCase().contains(text.toLowerCase().toString())).snapshots().map((QuerySnapshot data) =>
          data.docs.map((DocumentSnapshot doc) {
            return Item.fromJson(doc.id, doc.data() as Map<String, dynamic>);
          }).toList());
    } else {
      return DatabaseService().getItems(null);
    }
  }


  Stream<Item> get getItemById{
    return _itemsCollection.doc(uid).snapshots().map((DocumentSnapshot doc) => Item.fromJson(doc.id, doc.data() as Map<String, dynamic>));
  }

  Future deleteItem(String itemId) async{
    DocumentReference itemRef = _itemsCollection.doc(itemId);
    return itemRef.delete();
  }

  Stream<UserData> get userData{
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uID = auth.currentUser?.uid.toString();
    return _usersCollection.doc(uID).snapshots().map((DocumentSnapshot doc) => UserData.fromJson(doc.id, doc.data() as  Map<String, dynamic>));
  }

  Stream<UserData> get getUserById{
    return _usersCollection.doc(uid).snapshots().map((DocumentSnapshot doc) => UserData.fromJson(doc.id, doc.data() as Map<String, dynamic>));
  }

}