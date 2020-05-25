import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news/api.dart';
import 'package:news/models/following.dart';
import 'package:news/models/user.dart';
import 'package:news/profile/register/login_page.dart';
import 'package:news/database/database.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:news/models/follow.dart';

class ProfilePage extends StatefulWidget {

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String userName;
  int userID=0;
  int follower=0;
  int following=0;
  int post=0;
  int video=0;
  bool logIn=false;
  List<User> userList=new List<User>();
  List<Follow> followerList=new List<Follow>();
  List<Following> followingList = new List<Following>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      checkUser().then((value){
        setState(() {
          userList=value;
          print('User count===='+userList.length.toString());
          if(userList.length==0){
            userName='first';
            print("Result====="+userName);
          }else{
            User user=userList[0];
            userName=user.userName;
            userID=user.userID;
            print("Result======== "+userName + userID.toString());
            if(userID!=0){
                getFollowerList().then((value){
                  setState(() {
                    followerList=value;
                    follower=followerList.length;
                  });
                });
                checkFollowing(userID).then((value){
                  setState(() {
                    followingList=value;
                    following=followingList.length;
                  });
                });
                getTotalPost(userID).then((value){
                  setState(() {
                    post= value;
                  });
                });
            }else{
              follower=0;
            }
          }
          print("Result====="+userName);
        });
      });
    });
  }

  Future<int> getTotalPost(int id) async{
    int count=0;
    var response= await http.post(Api.USERPOST_COUNT_URL,
    body: {
      'Userid' : id.toString(),
    });
    if(response.statusCode ==200){
      var data=jsonDecode(response.body);
      count= data['count'];
    }
    return count;
  }

  Future<List<Follow>> getFollowerList() async{
    Future<List<Follow>> follows = SQLiteDbProvider.db.getFollower();
    List<Follow> followLists= await follows;
    return followLists;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

//  Future<List<Follow>> checkFollower(int id) async{
//    List<Follow> followers=List<Follow>();
//    //var followURL='https://firstgitlesson.000webhostapp.com/follower.php';
////    var response= await http.post(followURL,body: {
////      "userID" : userID.toString(),
////    });
//    var response=await http.post(baseUrl+"/"+id.toString());
//    var data=jsonDecode(response.body);
//    print('Data Length===='+data.length.toString());
//    for(int j=0;j<data.length;j++){
//      //User user=User(j,'null','000','000');
//      Follow follow=new Follow(data[j]['Followid'],data[j]['Userid'],data[j]['Followerid'],data[j]['Followdate']);
//      SQLiteDbProvider.db.deleteFollower();
//      SQLiteDbProvider.db.insertFollower(follow);
//      followers.add(follow);
//    }
//    print("Follower Length=-==="+followers.length.toString());
//    return followers;
//  }

  insertFollower(int id) async{
    var response=await http.post(Api.GETFOLLOWER_URL,
        body: {
          "Userid" : id.toString(),
        }
    );
    if(response.statusCode ==200){
      var body=jsonDecode(response.body);
      var data=body['data']['follower'];
      print('Data Length===='+data.length.toString());
      SQLiteDbProvider.db.deleteFollower();
      for(int j=0;j<data.length;j++){
        //User user=User(j,'null','000','000');
        Follow follow=new Follow(data[j]['Followid'],data[j]['Userid'],data[j]['Followerid'],data[j]['Followdate']);
        SQLiteDbProvider.db.insertFollower(follow);
      }
    }
  }

  _movedToLoginPage(BuildContext context, LoginPage loginPage) async{
    User user=await Navigator.push(context, MaterialPageRoute(builder: (context)=> loginPage)) as User;
    userName=user.userName;
    userID=user.userID;
    insertFollower(userID);
    getFollowerList().then((value){
      setState(() {
        followerList=value;
        follower=followerList.length;
      });
    });

    checkFollowing(userID).then((value){
      setState(() {
        followingList=value;
        following=followingList.length;
      });
    });
  }

  Future<List<Follow>> getFollower(int userId) async{
    List<Follow> follows= List<Follow>();
    var response=await http.post(Api.GETFOLLOWING_URL,body: {
      "Followerid" : userId.toString(),
    });
    if(response.statusCode ==200){
      var body=jsonDecode(response.body);
      var data=body['data']['following'];
      print('Data Length====*****'+data.length.toString());
      for(var n=0;n<data.length;n++){
        Follow follow=new Follow(data[n]['Followid'],data[n]['Userid'],data[n]['Followerid'],data[n]['Followdate']);
        follows.add(follow);
      }
    }

    return follows;
  }

  Future<List<Following>> checkFollowing(int id) async{
    List<Following> followings= await SQLiteDbProvider.db.getFollowing();//check currently following user from sqflite database
    if(followings.length == 0){
      List<Follow> followList= await getFollower(id);//get following list from server
      SQLiteDbProvider.db.deleteFollowing();
      List<Following> followingLists=new List<Following>();
      for(var i=0;i<followList.length;i++){
        Follow follow=followList[i];
        var res= await http.post(Api.USER_INFO_URL,body: {
          "Userid" : follow.userID.toString(),
        });
        print(res.body.toString());
        if(res.statusCode ==200){
          var body=jsonDecode(res.body);
          var dataUser=body['data'];
          Following following=new Following(dataUser['Userid'],dataUser['Username'],dataUser['Phone'],dataUser['Password'],
              dataUser['Createdate'],dataUser['Profilepic'],dataUser['Imei'],dataUser['Qq'],dataUser['Sex'],dataUser['Email'],
              dataUser['Address'],dataUser['Birthday'],dataUser['Introduction']);
          SQLiteDbProvider.db.insertFollowing(following);

          followingLists.add(following);
          res=null;
          body=null;
          dataUser=null;
        }
      }
      return followingLists;
    }else{
      return followings;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            // Circular Login Button
            userName=='first'? Container(
              height: 200,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.blueAccent,
                      child: InkWell(
                        splashColor: Colors.blue,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3366FF),
                                    const Color(0xFF00CCFF),
                                  ],
                                  begin: const FractionalOffset(0.0, 0.0),
                                  end: const FractionalOffset(1.0, 0.0),
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp),
                            ),
                            child: Center(
                              child: Text(
                                '登陆',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _movedToLoginPage(context,LoginPage());
                          });
                          //Navigator.pushNamed(context, "/login");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(
              height: 100.0,
              child: Container(
                padding: EdgeInsets.only(
                    top: 10.0,
                    right: 10.0,
                    left: 20.0,
                    bottom: 10.0
                ),
                child: Row(
                  children: <Widget>[
                    // 头像
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/minion.jpg'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    // 作者信息
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10.0,
                            right: 10.0,
                            left: 10.0,
                            bottom: 10.0
                        ),
                        child: Column(
                          children: <Widget>[
                            // 人气
                            Row(
                              children: <Widget>[
                                Text(userName.toString(),
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        post.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Post',
                                        style: TextStyle(
                                          color: Color.fromRGBO(128, 128, 128, 1.0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0,right: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        video.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Video',
                                        style: TextStyle(
                                          color: Color.fromRGBO(128, 128, 128, 1.0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0,right: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        follower.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Follower',
                                        style: TextStyle(
                                          color: Color.fromRGBO(128, 128, 128, 1.0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0,right: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        following.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Following',
                                        style: TextStyle(
                                          color: Color.fromRGBO(128, 128, 128, 1.0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 订阅
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 5.0,
              color: Colors.black12,
            ),
            IconBadges(),
            Container(
              height: 5.0,
              color: Colors.black12,
            ),
            ListItem(),
          ],
        ),
      ),
    );
  }


}

Container displayProfile(BuildContext context){
  return Container(
    height: 100.0,
    child: Container(
      padding: EdgeInsets.only(
        top: 10.0,
        right: 10.0,
        left: 20.0,
        bottom: 10.0
      ),
      child: Row(
        children: <Widget>[
          // 头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/minion.jpg'),
              ),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          // 作者信息
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                  top: 10.0,
                  right: 10.0,
                  left: 10.0,
                  bottom: 10.0
              ),
              child: Column(
                children: <Widget>[
                  // 人气
                  Row(
                    children: <Widget>[
                      Text('',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '1.3k',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Post',
                              style: TextStyle(
                                color: Color.fromRGBO(128, 128, 128, 1.0),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5.0,right: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '98',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: Color.fromRGBO(128, 128, 128, 1.0),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5.0,right: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '1.2k',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Follower',
                              style: TextStyle(
                                color: Color.fromRGBO(128, 128, 128, 1.0),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 订阅
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


class CircularLoginButton extends StatefulWidget {
  @override
  _CircularLoginButtonState createState() => _CircularLoginButtonState();
}

class _CircularLoginButtonState extends State<CircularLoginButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
            child: Material(
              color: Colors.blueAccent,
              child: InkWell(
                splashColor: Colors.blue,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3366FF),
                            const Color(0xFF00CCFF),
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: Center(
                      child: Text(
                        '登陆',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    User user=Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())) as User;

                  });
                  //Navigator.pushNamed(context, "/login");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class IconBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.notifications_active,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('关注')
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.star,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('收藏')
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.notifications_active,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('作品')
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.history,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('历史')
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.star,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('广告推广')
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.notifications_active,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('消息通知')
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(
              '账号管理',
              style: TextStyle(),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/accountmanagement");
            },
          ),
          Divider(
            indent: 16.0,
            endIndent: 16.0,
          ),
          ListTile(
            leading: Icon(Icons.subject),
            title: Text(
              '用户反馈',
              style: TextStyle(),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/feedback");
            },
          ),
          Divider(
            indent: 16.0,
            endIndent: 16.0,
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            title: Text(
              '关于我们',
              style: TextStyle(),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () { Navigator.pushNamed(context, "/sample");},
          ),
          Divider(
            indent: 16.0,
            endIndent: 16.0,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              '系统设置',
              style: TextStyle(),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/setting");
            },
          ),
          Divider(
            indent: 16.0,
            endIndent: 16.0,
          ),
        ],
      ),
    );
  }
}
