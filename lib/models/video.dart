class Video {
  int videoid;
  String videourl;
  String caption;
  int categoryid;
  int userpostid;
  int userid;
  int viewcount;
  int likecount;
  String createdate;

  Video(
      this.videoid,
      this.videourl,
      this.caption,
      this.categoryid,
      this.userpostid,
      this.userid,
      this.viewcount,
      this.likecount,
      this.createdate);

  Video.fromJson(Map<String, dynamic> json) {
    videoid = json['Videoid'];
    videourl = json['Videourl'];
    caption = json['Caption'];
    categoryid = json['Categoryid'];
    userpostid = json['Userpostid'];
    userid = json['Userid'];
    viewcount = json['Viewcount'];
    likecount = json['Likecount'];
    createdate = json['Createdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Videoid'] = this.videoid;
    data['Videourl'] = this.videourl;
    data['Caption'] = this.caption;
    data['Categoryid'] = this.categoryid;
    data['Userpostid'] = this.userpostid;
    data['Userid'] = this.userid;
    data['Viewcount'] = this.viewcount;
    data['Likecount'] = this.likecount;
    data['Createdate'] = this.createdate;
    return data;
  }
}
