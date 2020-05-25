class Reply{
  int replyID;
  int commentID;
  int userID;
  String userName;
  String text;
  int likeCount;
  String createDate;

  Reply(this.replyID, this.commentID, this.userID, this.userName, this.text,
      this.likeCount, this.createDate);

  static final columns = ["replyID", "commentID", "userID","userName", "text", "likeCount","createDate"];

  factory Reply.fromMap(Map<String, dynamic> data) {
    return Reply(
        data['replyID'],
        data['commentID'],
        data['userID'],
        data['userName'],
        data['text'],
        data['likeCount'],
        data['createDate']
    );
  }
  Map<String, dynamic> toMap() => {
    "replyID": replyID,
    "commentID": commentID,
    "userID": userID,
    "userName" : userName,
    "text": text,
    "likeCount" : likeCount,
    "createDate" : createDate
  };

  Reply.fromJson(Map<String, dynamic> json)
      : replyID = json['Replyid'],
        commentID = json['Commentid'],
        userID = json['Userid'],
        userName = json['Username'],
        text = json['Text'],
        likeCount = json['Likecount'],
        createDate = json['Createdate'];

  Map<String, dynamic> toJson() =>
      {
        'replyID': replyID,
        'commentID': commentID,
        'userID': userID,
        'userName' : userName,
        'text' : text,
        'likeCount' : likeCount,
        'createDate' : createDate
      };

}