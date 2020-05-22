class Following{
  final int userID;
  final String userName;
  final String phone;
  final String password;
  final String createDate;
  final String profilePic;
  final String IMEI;
  final String QQ;
  final int sex;
  final String email;
  final String address;
  final String birthday;
  final String introduction;

  Following(this.userID, this.userName, this.phone, this.password,
      this.createDate, this.profilePic, this.IMEI, this.QQ, this.sex,
      this.email, this.address, this.birthday, this.introduction);

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

//  Map<String, dynamic> toJson() =>
//      {
//        'categoryID': categoryID,
//        'categoryName': categoryName,
//        'categoryOrder': categoryOrder,
//      };
}