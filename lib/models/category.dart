// class Category{
//   int categoryID;
//   String categoryName;

//   Category(this.categoryID, this.categoryName);

// }

class Category {
  int categoryID;
  String categoryName;
  int categoryOrder;

  Category(this.categoryID, this.categoryName, this.categoryOrder);
  static final columns = ["categoryID", "categoryName", "categoryOrder"];
  Category.fromJson(Map<String, dynamic> json) {
    categoryID = json['Categoryid'];
    categoryName = json['Categoryname'];
    categoryOrder = json['Categoryorder'];
  }

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      data['Categoryid'],
      data['Categoryname'],
      data['Categoryorder'],
    );
  }
  Map<String, dynamic> toMap() => {
        "Categoryid": categoryID,
        "Categoryname": categoryName,
        "Categoryorder": categoryOrder,
      };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CategoryId'] = this.categoryID;
    data['CategoryName'] = this.categoryName;
    data['CategoryOrder'] = this.categoryOrder;
    return data;
  }
}
