class Video {
  int videoPostID;
  String videoUrl;
  String caption;
  int categoryID;
  int userPostID;
  int userID;
  String description;
  int viewCount;
  int likeCount;
  String createDate;

  static final columns = [
    "videoPostID",
    "videoUrl",
    "caption",
    "categoryID",
    "userPostID",
    "userID",
    "description",
    "viewCount",
    "likeCount",
    "createDate"
  ];

  Video.fromJson(Map<String, dynamic> json)
      : videoPostID = json['Videopostid'],
        videoUrl = json['Videourl'],
        caption = json['Caption'],
        categoryID = json['Categoryid'],
        userPostID = json['Userpostid'],
        userID = json['Userid'],
        description = json['Description'],
        viewCount = json['Viewcount'],
        likeCount = json['Likecount'],
        createDate = json['CreateDate'];

  Map<String, dynamic> toJson() =>
      {
        'videoPostID': videoPostID,
        'videoURl': videoUrl,
        'caption': caption,
        'categoryID' : categoryID,
        'userPostID' : userPostID,
        'userID' : userID,
        'description' : description,
        'viewCount' : viewCount,
        'likeCount' : likeCount,
        'createDate' : createDate,
      };


  Video(
      this.videoPostID,
      this.videoUrl,
      this.caption,
      this.categoryID,
      this.userPostID,
      this.userID,
      this.description,
      this.viewCount,
      this.likeCount,
      this.createDate);
}
