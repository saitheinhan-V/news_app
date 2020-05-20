
class Category{
  int categoryID;
  String categoryName;
  int categoryOrder;

  Category(this.categoryID, this.categoryName,this.categoryOrder);

  static final columns = ["categoryID", "categoryName", "categoryOrder"];

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      data['categoryID'],
      data['categoryName'],
      data['categoryOrder'],
    );
  }
  Map<String, dynamic> toMap() => {
    "categoryID": categoryID,
    "categoryName": categoryName,
    "categoryOrder": categoryOrder,
  };

  Category.fromJson(Map<String, dynamic> json)
      : categoryID = json['categoryID'],
        categoryName = json['categoryName'],
        categoryOrder = json['categoryOrder'];

  Map<String, dynamic> toJson() =>
      {
        'categoryID': categoryID,
        'categoryName': categoryName,
        'categoryOrder': categoryOrder,
      };

}