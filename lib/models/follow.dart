class Follow{
  final int followID;
  final int userID;
  final int followerID;
  final String followDate;

  Follow(this.followID,this.userID,this.followerID,this.followDate);

  static final columns = ["followID", "userID", "followerID", "followDate"];

  factory Follow.fromMap(Map<String, dynamic> data) {
    return Follow(
      data['followID'],
      data['userID'],
      data['followerID'],
      data['followDate'],
    );
  }
  Map<String, dynamic> toMap() => {
    "followID" : followerID,
    "userID": userID,
    "followerID": followerID,
    "followDate": followDate,
  };

}