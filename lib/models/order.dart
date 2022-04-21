class Order{
  String? id;
  String? userId;
  String? userClientId;
  String? userClientName;
  String? userClientEmail;
  String? itemId;
  String? itemName;
  String? itemDescription;
  String? itemImagePath;
  double? itemCost;

  Order({this.userId, this.userClientId, this.userClientName, this.userClientEmail, this.itemId, this.itemName, this.itemDescription, this.itemImagePath , this.itemCost});

  Order.fromJson(String uid, Map<String, dynamic> data){
    id = uid;
    userId = data['userID'];
    userClientId = data['userClientId'];
    userClientName = data['userClientName'];
    userClientEmail = data['userClientEmail'];
    itemId = data['itemId'];
    itemName = data['itemName'];
    itemDescription = data['itemDescription'];
    itemImagePath = data['itemImagePath'];
    itemCost = data['itemCost'];
  }
}