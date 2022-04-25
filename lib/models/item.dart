class Item {
  String? name;
  String? description;
  String? author;
  String? id;
  String? userEmail;
  String? authorId;
  String? authorPhoto;
  double? cost;
  String? imagePath;

  Item({this.id, this.author, this.description, this.name, this.authorId, this.authorPhoto, this.userEmail, this.cost, this.imagePath});

  Item.fromJson(String uid, Map<String, dynamic> data) {
    id = uid;
    author = data['Author'];
    description = data['Description'];
    name = data['Name'];
    authorId = data['AuthorID'];
    authorPhoto = data['AuthorPhoto'];
    userEmail = data['UserEmail'];
    cost = data['Cost'];
    imagePath = data['ImagePath'];
  }


  @override
  String toString() {
    return 'Item{description: $description, author: $author, id: $id, authorId: $authorId}';
  }

  Item copy(){
    final copiedAuthor = author;
    final copiedDecs = description;
    final copiedUserEmail = userEmail;
    final copiedName = name;
    final copiedPath = imagePath;
    final copiedAuthorPhoto = authorPhoto;
    final copiedAuthorId = authorId;

    return Item(id: id, author: copiedAuthor, description: copiedDecs, userEmail: copiedUserEmail, name: copiedName, imagePath: copiedPath, authorPhoto: copiedAuthorPhoto, authorId: copiedAuthorId);
  }
}