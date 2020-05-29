class Article{
  int articlePostID;
  int userPostID;
  int userID;
  int categoryID;
  String caption;
  String content;
  String cover;
  int viewCount;
  int likeCount;
  String createDate;

  Article(
      this.articlePostID,
      this.userPostID,
      this.userID,
      this.categoryID,
      this.caption,
      this.content,
      this.cover,
      this.viewCount,
      this.likeCount,
      this.createDate);

  static final columns = ["articlePostID", "userPostID", "userID", "categoryID","caption","content","cover","viewCount","likeCount","createDate"];


  Article.fromJson(Map<String, dynamic> json)
      : articlePostID = json['Articlepostid'],
        userPostID = json['Userpostid'],
        userID = json['Userid'],
        categoryID = json['Categoryid'],
        caption = json['Caption'],
        content = json['Content'],
        cover = json['Cover'],
        viewCount = json['Viewcount'],
        likeCount = json['Likecount'],
        createDate = json['Createdate'];

  Map<String, dynamic> toJson() =>
      {
        'articlePostID': articlePostID,
        'userPostID': userPostID,
        'userID': userID,
        'categoryID' : categoryID,
        'caption' : caption,
        'content' : content,
        'cover' : cover,
        'viewCount' : viewCount,
        'likeCount' : likeCount,
        'createDate' : createDate,
      };
}