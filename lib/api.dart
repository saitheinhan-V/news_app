import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:news/models/video.dart';

import 'database/database.dart';
import 'models/article.dart';
import 'models/category.dart';
import 'package:http/http.dart' as http;

import 'models/check_time.dart';
import 'models/follow.dart';
import 'models/moment.dart';
import 'models/user.dart';

class Api {
  // iconName 首页
  static const BASIC_URL = "http://192.168.0.119:3000/";

  static const LOGIN_URL = BASIC_URL + "/api/auth/login";

  static const REGISTER_URL = BASIC_URL + "/api/auth/register";

  static const INFO_URL = BASIC_URL + "/api/auth/info"; // user info using token

  static const USER_INFO_URL = BASIC_URL + "/api/user/info"; // user info using id

  static const UPLOAD_URL = BASIC_URL + "/api/auth/upload";

  static const MULTIPLEUPLOAD_URL = BASIC_URL + "/api/auth/multipleupload";

  static const NEWPOST_URL = BASIC_URL + "/api/userpost";

  static const USERPOSTINFO_URL = BASIC_URL + "/api/userpost/info";

  static const NEWMOMENTPOST_URL = BASIC_URL + "/api/momentpost";

  static const GETMOMENTPOST_URL = BASIC_URL + "/api/all/momentpost";//get all moment post

  static const GET_ARTICLE_URL = BASIC_URL + "/api/all/articlepost";//get all article post

  static const NEWARTICLEPOST_URL = BASIC_URL + "/api/articlepost";

  static const UPDATE_ARTICLE_LIKE_URL = BASIC_URL + "/api/article/like/update";

  static const GETFOLLOWER_URL = BASIC_URL + "/api/follower";

  static const GETFOLLOWING_URL = BASIC_URL + "/api/following";

  static const GETCATEGORY_URL = BASIC_URL + "/api/category";

  static const UPLOADFILE_URL = BASIC_URL + "/api/upload";

  static const USERPOST_COUNT_URL = BASIC_URL + "/api/userpost/count";

  static const LIKECOUNT_UPDATE_URL = BASIC_URL + "/api/update/moment/like";

  static const LIKE_CHECK_URL = BASIC_URL + "/api/like/record/check";

  static const LIKERECORD_URL = BASIC_URL + "/api/like/record";// add userid and postid to likerecord

  static const DELETELIKE_URL = BASIC_URL + "/api/like/record/delete/"; // delete likerecord field

  static const ADD_COMMENT_URL = BASIC_URL + "/api/comment/record";

  static const DELETE_COMMENT_URL = BASIC_URL + "/api/comment/record/delete/";

  static const GET_COMMENT_URL = BASIC_URL + "/api/comment/all";

  static const LIKE_COMMENT_UPDATE_URL = BASIC_URL + "/api/update/comment/like";

  static const DELETE_COMMENT_LIKE_RECORD_URL = BASIC_URL + "/api/comment/like/record/delete/";

  static const GET_COMMENT_COUNT_URL = BASIC_URL + "/api/comment/count";

  static const ADD_REPLY_URL = BASIC_URL + "/api/reply/record";

  static const GET_REPLY_URL = BASIC_URL + "/api/reply/all";

  static const GET_REPLY_COUNT_URL = BASIC_URL + "/api/reply/count";

  static const DELETE_REPLY_URL = BASIC_URL + "/api/reply/delete/";

  static const DELETE_REPLY_LIKE_URL = BASIC_URL + "/api/reply/like/delete/";

  static const UPDATE_REPLY_LIKE_URL = BASIC_URL + "/api/reply/like/update";

  static const ADD_FOLLOWER_URL = BASIC_URL + "/api/follower/add";

  static const DELETE_FOLLOWER_URL = BASIC_URL + "/api/follower/delete/";

  //  俺老孙自己的
  static const USER_PROFILE_INFO_URL = BASIC_URL + "api/auth/user/info";

  static const FEEDBACK_URL = BASIC_URL + "api/auth/feedback";

  static const UPDATE_USER_NAME_URL = BASIC_URL + "api/auth/user/update/name";

  static const UPDATE_USER_PROFILE_IMAGE_URL = BASIC_URL + "api/auth/user/update/profileimage";

  static const UPDATE_USER_INTRODUCTION_URL = BASIC_URL + "api/auth/user/update/introduction";

  static const UPDATE_USER_GENDER_URL = BASIC_URL + "api/auth/user/update/gender";

  static const UPDATE_USER_BIRTHDAY_URL = BASIC_URL + "api/auth/user/update/birthday";

  static const GET_USER_ARTICLE_PRODUCT = BASIC_URL + "api/auth/user/product/article";

  static const GET_VIDEO_URL = BASIC_URL + "/api/video/all";
  static const POST_VIDEOS = BASIC_URL + "api/videopost";


  // 文章
  static Future fetchArticles(int pageNum, {int cid}) async {
    await Future.delayed(Duration(seconds: 1)); //增加动效
    List<Article> articles=[];
    var response= await http.post("http://192.168.0.119:3000//api/all/articlepost",
        body: {
          "Categoryid" : cid.toString(),
        });
    if(response.statusCode ==200){
      var body= jsonDecode(response.body);
      var data= body['data'];
      for(int i=0;i<data.length;i++){
        Map map= data[i];
        Article article=Article.fromJson(map);
        articles.add(article);
      }
    }
    print("Article list*****"+articles.length.toString());
    return articles;
  }

  // 项目分类
  static Future fetchTreeCategories() async {
    var response = await http.get('tree/json');
    //return response.data.map<Tree>((item) => Tree.fromJsonMap(item)).toList();
  }

  // 体系分类
  static Future fetchProjectCategories() async {
    await Future.delayed(Duration(seconds: 1));
    List<Category> categoryLists=[];
    var res = await http.get(GETCATEGORY_URL);
    if(res.statusCode ==200){
      var body= jsonDecode(res.body);
      var data=body['data']['category'];
      print("--------" + data.length.toString());
      SQLiteDbProvider.db.deleteCategory();
      for(int i=0;i<data.length;i++){
        Category category=new Category(data[i]['Categoryid'], data[i]['Categoryname'], data[i]['Categoryorder']);
        categoryLists.add(category);
        SQLiteDbProvider.db.insertCategory(category);
      }
    }
    return categoryLists;
  }

  static Future fetchMoments() async{
    await Future.delayed(Duration(seconds: 2));
    List<Moment> moments=[];
    List<Follow> followList=[];
    int userID=0;

    List<User> userLists = await SQLiteDbProvider.db.getUser();
    if(userLists.length != 0){
      userID=userLists[0].userID;
    }
    followList= await getFollower(userID);
    print('Following list***'+followList.length.toString()+"****"+userID.toString());

    for(int i=0;i<followList.length;i++){
      Follow follow=followList[i];
      var response= await http.post(GETMOMENTPOST_URL,
          body: {
            'Userid' : follow.userID.toString(),
          });
      if(response.statusCode ==200){
        var body= jsonDecode(response.body);
        var data= body['data'];
        for(int i=0;i<data.length;i++){
          Moment moment=Moment(data[i]['Momentpostid'],data[i]['Userid'],data[i]['Userpostid'],data[i]['Caption'],data[i]['Image'],data[i]['Likecount'],data[i]['Createdate']);
          moments.add(moment);
        }
      }
      response=null;
    }
    return moments;
  }

  static Future getFollower(int userId) async{
    List<Follow> follows= List<Follow>();
    var response=await http.post(GETFOLLOWING_URL,body: {
      "Followerid" : userId.toString(),
    });
    if(response.statusCode ==200){
      var body=jsonDecode(response.body);
      var data=body['data']['following'];
      for(var n=0;n<data.length;n++){
        Follow follow=new Follow(data[n]['Followid'],data[n]['Userid'],data[n]['Followerid'],data[n]['Followdate']);
        follows.add(follow);
      }
    }

    return follows;
  }

  static Future checkUser() async {
    Future<List<User>> futureList = SQLiteDbProvider.db.getUser();
    List<User> userLists = await futureList;
    return userLists;
  }

  static Future getVideo({int cid}) async {
    List<Video> videos = List<Video>();
    await Future.delayed(Duration(seconds: 2));

    var response =await http.post(GET_VIDEO_URL,body: {
      'Categoryid' : cid.toString(),
    });

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var data= body['data'];
      for (int i = 0; i < data.length; i++) {
        Map map=data[i];
        Video video= Video.fromJson(map);
        videos.add(video);
//        Video video = Video(
//            data[i]['Videopostid'],
//            data[i]['Videourl'],
//            data[i]['Caption'],
//            data[i]['Categoryid'],
//            data[i]['Userpostid'],
//            data[i]['Userid'],
//            data[i]['Description'],
//            data[i]['Viewcount'],
//            data[i]['Likecount'],
//            data[i]['Createdate']);

      }
    }
    print("Video length*******" + videos.length.toString());
    return videos;
  }


}
