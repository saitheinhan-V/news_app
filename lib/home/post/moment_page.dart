import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/page_details/moment_page_details.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:news/models/check_time.dart';
import 'package:news/home/comment_reply/comment_page.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/models/user.dart';
import 'package:news/profile/recommend_user_profile.dart';
import 'package:news/profile/user_profile_page.dart';
import 'package:news/home/post/moment_image.dart';

class MomentPage extends StatefulWidget {
  final Moment moment;
  MomentPage({Key key,this.moment});

  @override
  _MomentPageState createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {

  Moment moment;
  Following following;

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg","panda.jpg","minion.jpg",
  ];
  int totalHeight=0;
  int imgHeight=0;
  int profileHeight=50;
  int captionHeight=110;
  int likeHeight=30;
  int bottomHeight=5;
  int dividerHeight=1;
  int recommendHeight=200;
  int like=0;
  int comment=0;
  int userID;

  bool isFollowed=false;
  bool isExpanded=false;
  bool isLiked=false;
  bool isShowed=false;
  bool first=true;

  DateTime now= DateTime.now();
  DateTime created;
  String date="";
  String name='';
  TimeOfDay releaseTime = TimeOfDay(hour: 8, minute: 10);

  CarouselSlider carouselSlider;
  List<String> imgList=[];
  List<User> userList=[];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    moment=widget.moment;
    checkUser().then((value){
      userList=value;
      if(userList.length != 0){
        userID=userList[0].userID;
        print("Userid=======**"+userID.toString());
        print("Mometnid====***"+moment.momentPostID.toString());
        checkLike(userID, moment.momentPostID).then((value){
            isLiked=value;
            print("Like=========="+ isLiked.toString());
            print("Userid======="+userID.toString());
            print("Mometnid===="+moment.momentPostID.toString());
        });
      }
    });

    getCommentCount(moment.momentPostID).then((value){
      setState(() {
        comment=value;
      });
    });

    getUserInfo(moment.userID).then((value){
      setState(() {
        following=value;
        name=following.userName;
      });
    });
    var array= moment.image.split(",");
    for(int i=0;i<array.length;i++){
      imgList.add(array[i]);
    }
    if(imgList!=null){
      imgList.removeLast();
    }
    print('Imge======'+moment.image.toString());
    print("length"+imgList.length.toString());

    var arr= moment.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    like=moment.likeCount;
    date=Check().checkDate(created, now);
    imgHeight=Check().checkImage(imgList);
    totalHeight=profileHeight+captionHeight+imgHeight+likeHeight+bottomHeight+dividerHeight;
  }

  Future<int> getCommentCount(int id) async{
    int count=0;
    var res =await http.post(Api.GET_COMMENT_COUNT_URL,
    body: {
      'Postid' : id.toString(),
      'Field' : "moment",
    });
    if(res.statusCode==200){
      var data=jsonDecode(res.body);
      count= data['count'];
    }
    return count;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<Following> getUserInfo(int id) async{
    var res=await http.post(Api.USER_INFO_URL,
    body: {
      'Userid' : id.toString(),
    });
      var data=jsonDecode(res.body);
      Map userMap=data['data'];
      Following following=Following.fromJson(userMap);
    return following;
  }

  Future<bool> checkLike(int user_id, int post_id) async{
    bool checked;
    var res= await http.post(Api.LIKE_CHECK_URL,
    body: {
      'Userid' : user_id.toString(),
      'Postid' : post_id.toString(),
      'Field' : "moment",
    });
    if(res.statusCode ==200){
      var data=jsonDecode(res.body);
      if(data['data']['Id'] == 0){
        checked=false;
      }else{
        checked=true;
      }
    }
    return checked;
  }

  updateLike(int id,int count) async{
    var response= await http.put(Api.LIKECOUNT_UPDATE_URL,
    body: {
      'Momentpostid' : id.toString(),
      'Likecount' : count.toString(),
    });
    if(response.statusCode ==200){
      print("update success");
    }
  }

  insertLikeRecord(int user_id,int post_id) async{
    var response= await http.post(Api.LIKERECORD_URL,
    body: {
      'Userid' : user_id.toString(),
      'Postid' : post_id.toString(),
      'Field' : "moment",
    });
    if(response.statusCode ==200){
      print("record success");
    }
  }

  deleteLikeRecord(int user_id,int post_id) async{
    var response= await http.delete(Api.DELETELIKE_URL+user_id.toString()+"/"+post_id.toString()+"/"+"moment");
    if(response.statusCode ==200){
      print('delete success');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                image: DecorationImage(
                                  image: AssetImage('assets/minion.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    height: 50.0,
                    //padding: EdgeInsets.only(left: 8.0,right: 5.0,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                          },
                          child: Container(
                            child: Text(name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 18.0,
                          width: 120.0,
                          padding: EdgeInsets.only(top: 5.0,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(date.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
                onTap: (){
                  //_setPage(context);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 5.0,left: 10.0,right: 10.0,bottom: 5.0),
                  child: Text(moment.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          GestureDetector(
            onTap: (){
              //_setPage(context);
            },
            child: imgHeight==0 ? Container() :
            Container(
              padding: EdgeInsets.only(left: 8.0,right: 8.0),
                child: MomentImage(height: imgHeight,image: imgList,)),
          ),
          Container(
            color: Colors.black12,
            height: 1.0,
          ),
          Container(
            height: 30.0,
            padding: EdgeInsets.only(left: 10.0,right: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(Icons.thumb_up,size: 15.0,color: isLiked? Colors.blue : Colors.grey,),
                        onTap: (){
                              setState(() {
                                if(isLiked){
                                  isLikedTo(false);
                                  like=like-1;
                                  deleteLikeRecord(userID,moment.momentPostID);
                                }else{
                                  isLikedTo(true);
                                  like=like+1;
                                  insertLikeRecord(userID,moment.momentPostID);
                                }
                                updateLike(moment.momentPostID,like);
                              });
                        },
                        ),
                        SizedBox(width: 5.0,),
                        Text(like.toString(),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0
                            ),
                          ),
                      ],
                    ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CommentPage(momentID: moment.momentPostID,))
                        );
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.comment,size: 15.0,color: Colors.grey,),
                        SizedBox(width: 5.0,),
                        Text(comment.toString(),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.share,size: 15.0,color: Colors.grey,),
                      SizedBox(width: 5.0,),
                      Text('1000',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0
                          ),
                        ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 5.0,
            padding: EdgeInsets.only(top: 3.0,),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }

  void _setPage(BuildContext context) {
    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MomentPageDetails(image: imgList,follow: isFollowed,moment: moment,following: following,))
      );
    });
  }

  void isLikedTo(bool param0) {
    setState(() {
      isLiked=param0;
    });
  }

}
