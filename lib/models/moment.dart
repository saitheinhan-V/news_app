
class Moment{
  int momentPostID;
  int userID;
  int userPostID;
  String caption;
  String image;
  String likeCount;
  String createDate;

  Moment(this.momentPostID, this.userID, this.userPostID, this.caption,
      this.image, this.likeCount, this.createDate);

  static final columns = ["momentPostID", "userID", "userPostID", "caption","image","likeCount","createDate"];

//  factory User.fromMap(Map<String, dynamic> data) {
//    return User(
//      data['userID'],
//      data['userName'],
//      data['password'],
//      data['phone'],
//    );
//  }
//  Map<String, dynamic> toMap() => {
//    "userID": userID,
//    "userName": userName,
//    "password": password,
//    "phone": phone,
//  };

  Moment.fromJson(Map<String, dynamic> json)
      : momentPostID = json['Momentpostid'],
        userID = json['Userid'],
        userPostID = json['Userpostid'],
        caption = json['Caption'],
        image = json['Image'],
        likeCount = json['Likecount'],
        createDate = json['Createdate'];

  Map<String, dynamic> toJson() =>
      {
        'momentPostID': momentPostID,
        'userID': userID,
        'userPostID': userPostID,
        'caption' : caption,
        'image' : image,
        'likeCount' : likeCount,
        'createDate' : createDate,
      };
}