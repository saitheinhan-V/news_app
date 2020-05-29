import 'dart:convert';

import 'models/article.dart';
import 'models/category.dart';
import 'package:http/http.dart' as http;

import 'models/check_time.dart';
import 'models/follow.dart';
import 'models/moment.dart';

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
//        var createdDate = data[i]['Createdate'];
//        var arr= createdDate.split('-');
//        var arr1= arr[2].split(':');
//        var arr2= arr1[0].split('T');
//        DateTime created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));
//        DateTime now=DateTime.now();
//        String date=Check().checkDate(created, now);
//
//        Article article = new Article(data[i]['Articlepostid'], data[i]['Userpostid'], data[i]['Userid'], data[i]['Categoryid'], data[i]['Caption'], data[i]['Content'], data[i]['Cover'], data[i]['Viewcount'], data[i]['Likecount'], date);
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
      for(int i=0;i<data.length;i++){
        Category category=new Category(data[i]['Categoryid'], data[i]['Categoryname'], data[i]['Categoryorder']);
        categoryLists.add(category);
      }
    }
    return categoryLists;
  }

  static Future fetchMoments({int id}) async{
    await Future.delayed(Duration(seconds: 2));
    List<Moment> moments=[];
    List<Follow> followList=[];

    var res=await http.post(GETFOLLOWING_URL,body: {
      "Followerid" : id.toString(),
    });
    if(res.statusCode ==200){
      var body=jsonDecode(res.body);
      var data=body['data']['following'];
      for(var n=0;n<data.length;n++){
        Follow follow=new Follow(data[n]['Followid'],data[n]['Userid'],data[n]['Followerid'],data[n]['Followdate']);
        followList.add(follow);
      }
    }
    print('Following list***'+followList.length.toString()+"****"+id.toString());

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

//  static Future getFollower(int userId) async{
//    List<Follow> follows= List<Follow>();
//    var response=await http.post(GETFOLLOWING_URL,body: {
//      "Followerid" : userId.toString(),
//    });
//    if(response.statusCode ==200){
//      var body=jsonDecode(response.body);
//      var data=body['data']['following'];
//      for(var n=0;n<data.length;n++){
//        Follow follow=new Follow(data[n]['Followid'],data[n]['Userid'],data[n]['Followerid'],data[n]['Followdate']);
//        follows.add(follow);
//      }
//    }
//
//    return follows;
//  }


}
