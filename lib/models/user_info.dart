class UserInfo {
  final int uid, gender;
  final String userName, avatorImage, introduction, birthday, phone;

  UserInfo(this.uid, this.userName, this.avatorImage, this.introduction,
      this.gender, this.birthday, this.phone);

  static final columns = [
    "uid",
    "userName",
    "avatorImage",
    "introduction",
    "birthday",
    "phone",
    "gender"
  ];

  factory UserInfo.fromMap(Map<String, dynamic> data) {
    return UserInfo(
      data['uid'],
      data['userName'],
      data['avatorImage'],
      data['introduction'],
      data['gender'],
      data['birthday'],
      data['phone'],
    );
  }

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "userName": userName,
        "avatorImage": avatorImage,
        "introduction": introduction,
        "gender": gender,
        "birthday": birthday,
        "phone": phone,
      };

  UserInfo.fromJson(Map<String, dynamic> json)
      : uid = json['id'],
        userName = json['name'],
        avatorImage = json['image'],
        introduction = json['introduction'],
        gender = json['gender'],
        birthday = json['birthday'],
        phone = json['phone'];

  Map<String, dynamic> toJson() => {
        'id': uid,
        'name': userName,
        'image': avatorImage,
        'introduction': introduction,
        'gender': gender,
        'birthday': birthday,
        'phone': phone,
      };
}
