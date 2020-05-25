import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:news/api.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/home/post/three_page.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/search/search_people.dart';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class FollowPageContent extends StatefulWidget {
  final int userID;

  FollowPageContent({Key key,this.userID}):super(key: key);

  @override
  _FollowPageContentState createState() => _FollowPageContentState();
}

class _FollowPageContentState extends State<FollowPageContent> {

  List<Following> followingList=List<Following>();
  List<Moment> momentList=List<Moment>();
  List<User> userList=List<User>();
  List<Widget> list=[];
  int userID=0;
  var refreshKey=GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list=List<Widget>()..add(buildAddButton());

    checkUser().then((value){
      setState(() {
        userList=value;
        if(userList.length==0){
          userID=0;
        }else{
          User user=userList[0];
          userID=user.userID;
          print("Result========****"+userID.toString());
          if(userID !=0){
            checkFollowing(userID).then((value){
              setState(() {
                followingList=value;
                print('Following=====*****'+followingList.length.toString());
                //print(followingList[0].userName+followingList[1].userName+followingList[2].userName);
                for(int i=0;i<followingList.length;i++){
                  list.insert(list.length-1, _buildFollowingProfile(followingList[i].userName));
                }
//                getMoment(followingList).then((value){
//                  setState(() {
//                    momentList=value;
//                    print("Moment******"+momentList.length.toString());
//                  });
//                });
              });
            });
          }
        }
      });
      });

  }

  Future<Null> refreshList() async{
    refreshKey.currentState?.show(atTop: false);
    momentList=await getMoment(followingList);
    return null;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<List<Following>> checkFollowing(int id) async{

    List<Following> followings= await SQLiteDbProvider.db.getFollowing();//check currently following user from sqflite database
    if(followings == null){
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
          //print('Data <<<<<<<'+dataUser.length.toString());
          //followers.add(dataUser['Username']);
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

  Future<List<Moment>> getMoment(List<Following> followings) async{
    List<Moment> moments=[];
    for(int i=0;i<followings.length;i++){
      Following following=followings[i];
      var response= await http.post(Api.GETMOMENTPOST_URL,
          body: {
            'Userid' : following.userID.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: refreshKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //FollowingContent(id: userID,),
                Container(
                  height: 100.0,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: list,
                    ),
                  ),
                ),
                Container(
                      height: 5.0,
                      color: Colors.black12,
                    ),
                Container(
                  child: FutureBuilder<List<Moment>>(
                    future: getMoment(followingList),
                    builder: (context , snapshot){
                      if(snapshot.hasError){
                        return Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 50.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.error,size: 50.0,color: Colors.grey,),
                                SizedBox(height: 10.0,),
                                Text('Network Error, check your connection!',style: TextStyle(color: Colors.red,fontSize: 15.0,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        );
                      }else if(snapshot.hasData){
                        List<Moment> moments=snapshot.data;
                        return ListView.builder(
                            itemCount: moments.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context ,index){
                              return MomentPage(moment: moments[index],);
                            }
                        );
                      }
//                      else if(snapshot.data == null){
//                        return Container(
//                          height: 200.0,
//                          child: Center(child: Text('Follow people to be able to see theirs posts or information')),
//                        );
//                      }
                      return Center(
                          child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        onRefresh: refreshList,
      ),
    );
  }

  List<Widget> getDelegate(List<Moment> moments) {
    List<Widget> _generalDelegates = List<Widget>();
    for(Moment moment in moments){
      _generalDelegates.add(MomentPage(moment: moment,));
    }
      //_generalDelegates.add(DisplayThreeContent());
    return _generalDelegates;
  }
}

class FollowingContent extends StatefulWidget {
  final List<Following> followings;
  final int id;

  FollowingContent({Key key,this.followings,this.id}):super(key: key);

  @override
  _FollowingContentState createState() => _FollowingContentState();
}

class _FollowingContentState extends State<FollowingContent> {

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg",
  ];

  List<Widget> list=[];
  List<User> userList=List<User>();
  List<Following> followingList=[];
  int userID=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list=List<Widget>()..add(buildAddButton());
    userID=widget.id;
    print('userid=========='+userID.toString());
    checkUser().then((value){
      setState(() {
        userList=value;
        if(userList.length!=0){
          userID=userList[0].userID;
          if(userID !=0){
            checkFollowing(userID).then((value){
              setState(() {
                followingList=widget.followings;
                print('Following====='+followingList.length.toString());
                for(int i=0;i<followingList.length;i++){
                  list.insert(list.length-1, _buildFollowingProfile("EX"));
                }
              });
            });
          }
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

    List<Following> followings= await SQLiteDbProvider.db.getFollowing();//check currently following user from sqflite database
    if(followings == null){
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
          //print('Data <<<<<<<'+dataUser.length.toString());
          //followers.add(dataUser['Username']);
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
