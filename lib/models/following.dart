class Following{
  int userID;
  String userName;
  String phone;
  String password;
  String createDate;
  String profilePic;
  String IMEI;
  String QQ;
  int sex;
  String email;
  String address;
  String birthday;
  String introduction;



  static final columns = ["userID", "userName", "phone", "password","createDate","profilePic","IMEI","QQ","sex","email","address","birthday","introduction"];

  factory Following.fromMap(Map<String, dynamic> data) {
    return Following(
        data['userID'],
        data['userName'],
        data['phone'],
        data['password'],
        data['createDate'],
        data['profilePic'],
        data['IMEI'],
        data['QQ'],
        data['sex'],
        data['email'],
        data['address'],
        data['birthday'],
        data['introduction']
    );
  }
  Map<String, dynamic> toMap() => {
    "userID": userID,
    "userName": userName,
    "phone": phone,
    "password": password,
    "createDate" : createDate,
    "profilePic" : profilePic,
    "IMEI" : IMEI,
    "QQ" : QQ,
    "sex" : sex,
    "email" : email,
    "address" : address,
    "birthday" : birthday,
    "introduction" : introduction
  };

  Following.fromJsonMap(Map<String, dynamic> map):
        userID = map["userID"],
        userName = map["userName"],
        phone = map["phone"],
        password = map["password"],
        createDate = map["createDate"],
        profilePic = map["profilePic"],
        IMEI = map["IMEI"],
        QQ = map["QQ"],
        sex = map["sex"],
        email = map["email"],
        address = map["address"],
        birthday = map['birthday'],
        introduction = map['introduction'];

  Following.fromJson(Map<String, dynamic> json)
      : userID = json['Userid'],
        userName = json['Username'],
        phone = json['Phone'],
        password = json['Password'],
        createDate = json['Createdate'],
        profilePic = json['Profilepic'],
        IMEI = json['Imei'],
        QQ = json['Qq'],
        sex = json['Sex'],
        email = json['Email'],
        address = json['Address'],
        birthday = json['Birthday'],
        introduction = json['Introduction'];

  Following(
      this.userID,
      this.userName,
      this.phone,
      this.password,
      this.createDate,
      this.profilePic,
      this.IMEI,
      this.QQ,
      this.sex,
      this.email,
      this.address,
      this.birthday,
      this.introduction);

//  Map<String, dynamic> toJson() =>
//      {
//        'categoryID': categoryID,
//        'categoryName': categoryName,
//        'categoryOrder': categoryOrder,
//      };
}