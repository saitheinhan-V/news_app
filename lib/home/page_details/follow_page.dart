import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/home/post/three_page.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/search/search_people.dart';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class FollowPageContent extends StatefulWidget {
  @override
  _FollowPageContentState createState() => _FollowPageContentState();
}

class _FollowPageContentState extends State<FollowPageContent> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FollowingContent(),
                Container(
                  height: 5.0,
                  color: Colors.black12,
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              getDelegate(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getDelegate() {
    List<Widget> _generalDelegates = List<Widget>();
    //_generalDelegates.clear();
    for (var i = 0; i < 2; i++) {
      _generalDelegates.add(MomentPage());
      _generalDelegates.add(DisplayThreeContent());
    }
    return _generalDelegates;
  }
}

class FollowingContent extends StatefulWidget {
  @override
  _FollowingContentState createState() => _FollowingContentState();
}

class _FollowingContentState extends State<FollowingContent> {

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg",
  ];

  List<Widget> list=[];
  List<User> userList=List<User>();
  List<Following> followingList=List<Following>();
  int userID=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list=List<Widget>()..add(buildAddButton());
    setState(() {
      checkUser().then((value){
        userList=value;
        if(userList.length==0){
          userID=0;
        }else{
          User user=userList[0];
          userID=user.userID;
          print("Result========"+userID.toString());
        }
        if(userID!=0){
          setState(() {
//            checkFollowing(userID).then((value){
//              setState(() {
//                followingList=value;
//                print('Follower====='+followingList.length.toString());
//                for(int i=0;i<followingList.length;i++){
//                    list.insert(list.length-1, _buildFollowingProfile(followingList[i].userName));
//                }
//              });
//            });
          });
        }
      });
    });
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<List<Following>> checkFollowing(int id) async{

//    var followURL='https://firstgitlesson.000webhostapp.com/follower.php';
//    var response= await http.post(followURL,body: {
//      "userID" : userID.toString(),
//    });
    List<Following> followings= await SQLiteDbProvider.db.getFollowing();//check currently following user from sqflite database
    if(followings == null){
      List<Follow> followList= await getFollower(id);//get following list from server
      SQLiteDbProvider.db.deleteFollowing();
      List<Following> followingLists=new List<Following>();
      for(var i=0;i<followList.length;i++){
        Follow follow=followList[i];
        var res= await http.post("http://192.168.0.110:8081/data/"+follow.userID.toString());
        print(res.body.toString());
        var dataUser=jsonDecode(res.body);
        //print('Data <<<<<<<'+dataUser.length.toString());
        //followers.add(dataUser['Username']);
        Following following=new Following(dataUser['Userid'],dataUser['Username'],dataUser['Phone'],dataUser['Password'],
            dataUser['Createdate'],dataUser['Profilepic'],dataUser['Imei'],dataUser['Qq'],dataUser['Sex'],dataUser['Email'],
            dataUser['Address'],dataUser['Birthday'],dataUser['Introduction']);
        SQLiteDbProvider.db.insertFollowing(following);

        followingLists.add(following);
        res=null;
        dataUser=null;
      }
      return followingLists;
    }else{
      return followings;
    }

  }

  Future<List<Follow>> getFollower(int userId) async{
    List<Follow> follows= List<Follow>();
    var response=await http.post("http://192.168.0.110:8081/follow/"+userId.toString());
    var data=jsonDecode(response.body);
    print('Data Length====*****'+data.length.toString());
    for(var n=0;n<data.length;n++){
      Follow follow=new Follow(data[n]['Followid'],data[n]['Userid'],data[n]['Followerid'],data[n]['Followdate']);
      follows.add(follow);
    }
    return follows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: list,
        ),
      ),
    );
  }

  Widget buildAddButton(){
    return Container(
      height: 100.0,width: 100.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                 onTap: (){
                   setState(() {
                     //_addFollowing();
                    // showSearch(context: context, delegate: SearchPeople());
                     Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomSearchPeople()));
                   });
                 },
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                          style: BorderStyle.solid),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[100],
                          offset: Offset(0.0, 7.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  height: 20.0,
                  child: Center(
                    child: Text('Add People',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

//  _addFollowing() {
//    setState(() {
//      if(list.length<9){
//        list.insert(list.length-1, _buildFollowingProfile());
//      }
//    });
//  }

  Widget _buildFollowingProfile(String name) {
    return Container(
      height: 100.0,width: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: (){
             // _addFollowing();
            },
            child: Container(
              width: 60.0,height: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                  color: Colors.blue,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[100],
                    offset: Offset(0.0, 7.0),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Container(
                height: 50.0,width: 50.0,
                margin: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/panda.jpg',),
                    fit: BoxFit.cover,
                  ),
                ),
                  //child: Image.asset('assets/panda.jpg',fit: BoxFit.cover,),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            height: 20.0,
            child: Center(
              child: Text(name.toString(),
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
