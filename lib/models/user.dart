
class User{
  final int userID;
  final String userName;
  final String password;
  final String phone;

  User(this.userID, this.userName, this.password, this.phone);

  static final columns = ["userID", "userName", "password", "phone"];

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      data['userID'],
      data['userName'],
      data['password'],
      data['phone'],
    );
  }
  Map<String, dynamic> toMap() => {
    "userID": userID,
    "userName": userName,
    "password": password,
    "phone": phone,
  };

}