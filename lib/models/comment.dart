
class Comment{
   int commentID;
   int userID;
   int postID;
   String field;
   String userName;
   String text;
   int likeCount;
   String createDate;


  static final columns = ["commentID", "userID", "postID","field","userName", "text", "likeCount","createDate"];

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      data['commentID'],
      data['userID'],
      data['postID'],
      data['field'],
      data['userName'],
      data['text'],
      data['likeCount'],
      data['createDate']
    );
  }
  Map<String, dynamic> toMap() => {
    "commentID": commentID,
    "userID": userID,
    "postID": postID,
    "field" : field,
    "userName" : userName,
    "text": text,
    "likeCount" : likeCount,
    "createDate" : createDate
  };

  Comment.fromJson(Map<String, dynamic> json)
      : commentID = json['Commentid'],
        userID = json['Userid'],
        postID = json['Postid'],
        field = json['Field'],
        userName = json['Username'],
        text = json['Text'],
        likeCount = json['Likecount'],
        createDate = json['Createdate'];

  Map<String, dynamic> toJson() =>
      {
        'commentID': commentID,
        'userID': userID,
        'postID': postID,
        'field' : field,
        'userName' : userName,
        'text' : text,
        'likeCount' : likeCount,
        'createDate' : createDate
      };

  Comment(this.commentID, this.userID, this.postID,this.field,this.userName, this.text, this.likeCount, this.createDate);
}