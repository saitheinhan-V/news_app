import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:news/api.dart';
import 'package:news/helper/refresh_helper.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/home/widgets/article_skeleton.dart';
import 'package:news/home/widgets/skeleton.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/provider/provider_widget.dart';
import 'package:news/search/search_people.dart';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:news/view_models/structure_model.dart';
import 'package:news/view_models/view_state_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowMainPage extends StatefulWidget {
  @override
  _FollowMainPageState createState() => _FollowMainPageState();
}

class _FollowMainPageState extends State<FollowMainPage> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: <Widget>[
              FollowingContent(),
              Container(
                height: 5.0,
                color: Colors.black12,
              ),
              FollowPageContent(),
            ],
          ),
        ),
      )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}


class FollowPageContent extends StatefulWidget {


  @override
  _FollowPageContentState createState() => _FollowPageContentState();
}

class _FollowPageContentState extends State<FollowPageContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Following> followingList = List<Following>();
  List<Moment> momentList = List<Moment>();
  List<User> userList = List<User>();
  List<Widget> list = [];
  int userID = 0;
  //var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    checkUser().then((value) {
//      setState(() {
//        userList = value;
//        if (userList.length == 0) {
//          userID = 0;
//        } else {
//          User user = userList[0];
//          userID = user.userID;
//          print("Result========****" + userID.toString());
//          if (userID != 0) {
//
////            checkFollowing(userID).then((value) {
////              setState(() {
////                followingList = value;
////                print('Following=====*****' + followingList.length.toString());
////                //print(followingList[0].userName+followingList[1].userName+followingList[2].userName);
////                for (int i = 0; i < followingList.length; i++) {
////                  list.insert(list.length - 1,
////                      _buildFollowingProfile(followingList[i].userName));
////                }
//////                getMoment(followingList).then((value){
//////                  setState(() {
//////                    momentList=value;
//////                    print("Moment******"+momentList.length.toString());
//////                  });
//////                });
////              });
////            });
//          }
//        }
//      });
//    });
  }

  Future<Null> refreshList() async {
    //refreshKey.currentState?.show(atTop: false);
    momentList = await getMoment(followingList);
    return null;
  }

  Future<List<User>> checkUser() async {
    Future<List<User>> futureList = SQLiteDbProvider.db.getUser();
    List<User> userLists = await futureList;
    return userLists;
  }

  Future<List<Follow>> getFollower(int userId) async {
    List<Follow> follows = List<Follow>();
    var response = await http.post(Api.GETFOLLOWING_URL, body: {
      "Followerid": userId.toString(),
    });
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var data = body['data']['following'];
      print('Data Length====*****' + data.length.toString());
      for (var n = 0; n < data.length; n++) {
        Follow follow = new Follow(data[n]['Followid'], data[n]['Userid'],
            data[n]['Followerid'], data[n]['Followdate']);
        follows.add(follow);
      }
    }
    return follows;
  }

  Future<List<Moment>> getMoment(List<Following> followings) async {
    List<Moment> moments = [];
    for (int i = 0; i < followings.length; i++) {
      Following following = followings[i];
      var response = await http.post(Api.GETMOMENTPOST_URL, body: {
        'Userid': following.userID.toString(),
      });
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var data = body['data'];
        for (int i = 0; i < data.length; i++) {
          Moment moment = Moment(
              data[i]['Momentpostid'],
              data[i]['Userid'],
              data[i]['Userpostid'],
              data[i]['Caption'],
              data[i]['Image'],
              data[i]['Likecount'],
              data[i]['Createdate']);
          moments.add(moment);
        }
      }
      response = null;
    }
    return moments;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<MomentListModel>(
      model: MomentListModel(),
      onModelReady: (model) => model.initData(),
      builder: (context, model, child) {
        if (model.isBusy) {
          return SkeletonList(
            builder: (context, index) => ArticleSkeletonItem(),
          );
        } else if (model.isError && model.list.isEmpty) {
          return ViewStateErrorWidget(
              error: model.viewStateError, onPressed: model.initData);
        } else if (model.isEmpty) {
          return ViewStateEmptyWidget(onPressed: model.initData);
        }
        return
//          SmartRefresher(
//          controller: model.refreshController,
//          header: WaterDropHeader(),
//          footer: RefresherFooter(),
//          onRefresh: model.refresh,
//          onLoading: model.loadMore,
//          enablePullUp: true,
           //SingleChildScrollView(
            //scrollDirection: Axis.vertical,
            ListView.builder(
               shrinkWrap: true,
                    itemCount: model.list.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      Moment moment = model.list[index];
                      return MomentPage(moment: moment,);
                    });
          //);
        //);
      },
    );
  }

  List<Widget> getDelegate(List<Moment> moments) {
    List<Widget> _generalDelegates = List<Widget>();
    for (Moment moment in moments) {
      _generalDelegates.add(MomentPage(
        moment: moment,
      ));
    }
    //_generalDelegates.add(DisplayThreeContent());
    return _generalDelegates;
  }
}

class FollowingContent extends StatefulWidget {
  final List<Following> followings;

  FollowingContent({Key key, this.followings}) : super(key: key);

  @override
  _FollowingContentState createState() => _FollowingContentState();
}

class _FollowingContentState extends State<FollowingContent> with AutomaticKeepAliveClientMixin{


  List<Widget> list = [];
  List<User> userList = List<User>();
  List<Following> followingList = [];
  int userID = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = List<Widget>()..add(buildAddButton());

    checkUser().then((value){
      List<User> userList=value;
      if(userList.length!=0){
        userID=userList[0].userID;
      }
    });
  }

  Future<List<User>> checkUser() async {
    Future<List<User>> futureList = SQLiteDbProvider.db.getUser();
    List<User> userLists = await futureList;
    return userLists;
  }

  Future<List<Following>> checkFollowing(int id) async {
    List<Following> followings = await SQLiteDbProvider.db.getFollowing(); //check currently following user from sqflite database
    if (followings == null) {
      List<Follow> followList = await getFollower(id); //get following list from server
      SQLiteDbProvider.db.deleteFollowing();
      List<Following> followingLists = new List<Following>();
      for (var i = 0; i < followList.length; i++) {
        Follow follow = followList[i];
        var res = await http.post(Api.USER_INFO_URL, body: {
          "Userid": follow.userID.toString(),
        });
        print(res.body.toString());
        if (res.statusCode == 200) {
          var body = jsonDecode(res.body);
          Map map = body['data'];
          Following following=new Following.fromJson(map);
          //print('Data <<<<<<<'+dataUser.length.toString());
          //followers.add(dataUser['Username']);
          SQLiteDbProvider.db.insertFollowing(following);

          followingLists.add(following);
          res = null;
          body = null;
        }
      }
      return followingLists;
    } else {
      return followings;
    }
  }

  Future<List<Follow>> getFollower(int userId) async {
    List<Follow> follows = List<Follow>();
    var response = await http.post(Api.GETFOLLOWING_URL, body: {
      "Followerid": userId.toString(),
    });
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var data = body['data']['following'];
      print('Data Length====*****' + data.length.toString());
      for (var n = 0; n < data.length; n++) {
        Follow follow = new Follow(data[n]['Followid'], data[n]['Userid'],
            data[n]['Followerid'], data[n]['Followdate']);
        follows.add(follow);
      }
    }
    return follows;
  }

  @override
  Widget build(BuildContext context) {
//    return Container(
//      height: 100.0,
//      width: double.infinity,
////      child: SingleChildScrollView(
////        scrollDirection: Axis.horizontal,
////        child: Row(
////          children: list,
////        ),
////      ),
//      child: SingleChildScrollView(
//        scrollDirection: Axis.horizontal,
//        child: Row(
//        children: <Widget>[
//
//        ],
//      ),
//    ),
//    );
  super.build(context);
  return ProviderWidget<FollowingUserModel>(
    model: FollowingUserModel(),
    onModelReady: (model) => model.initData(),
    builder: (context , model, child){
      if(model.list.isNotEmpty){
        for(var i=0;i<model.list.length;i++){
          print("List length===="+model.list.length.toString() + "count"+i.toString() + "add++++"+list.length.toString());
          list.insert(list.length-1, _buildFollowingProfile(model.list[i]));
        }
        print('total****'+list.length.toString());
        return Container(
          height: 100.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: list,
          ),
        );
      }
      return Container(
        height: 100.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //buildAddButton(),
           Container(
             height: 100.0,
             width: 100.0,
             child: GestureDetector(
               onTap: (){
                 setState(() {
                   model.initData();
                 });
               },
               child:  Column(
                 children: <Widget>[
                   Container(
                       width: 60,
                       height: 60,
                       margin: EdgeInsets.only(top: 10.0),
                       child: Icon(Icons.refresh, color: Colors.white, size: 20,),
                       decoration: BoxDecoration(
                         color: Colors.black26,
                         shape: BoxShape.circle,

                       ),
                     ),

                 ],
               ),
             ),
           ),
          ],
        ),
//        child: ListView.builder(
//                        scrollDirection: Axis.horizontal,
//                        itemCount: model.list.length,
//                          itemBuilder: (context ,index){
//                            Following following=model.list[index];
//                          return _buildFollowingProfile(following);
//                          }
//                      ),
      );
                    //buildAddButton(),
    },
  );
  }

  Widget buildAddButton() {
    return Container(
      height: 100.0,
      width: 100.0,
      child: GestureDetector(
        onTap: (){
          setState(() {
            if(userID == 0){
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) {
                    return AlertDialog(
                      title: Text('Warning'),
                      content: Text('Please log in or register to follow more people!',
                        style: TextStyle(height: 1.5),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                            onPressed: () => Navigator.pop(c),
                            child: new Text('Ok'))
                      ],
                    );
                  });
            }else{
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CustomSearchPeople()));
            }
          });
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
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
                        color: Colors.white, width: 1.5, style: BorderStyle.solid),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[100],
                        offset: Offset(0.0, 7.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                height: 20.0,
                child: Center(
                  child: Text(
                    'Add People',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingProfile(Following following) {
    return Container(
      height: 100.0,
      width: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // _addFollowing();
            },
            child: Container(
              width: 60.0,
              height: 60.0,
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
                height: 50.0, width: 50.0,
                margin: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.0,
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/panda.jpg',
                    ),
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
              child: Text(
                following.userName,
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
