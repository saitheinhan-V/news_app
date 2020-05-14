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

  //static final columns = ["us", "userName", "password", "phone"];

  factory Following.fromMap(Map<String, dynamic> data) {
    return Following(
      data['userID'],
      data['userName'],
      data['password'],
      data['phone'],
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
    "password": password,
    "phone": phone,
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
}