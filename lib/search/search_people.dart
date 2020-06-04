import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news/database/database.dart';
import 'package:news/home/widgets/article_skeleton.dart';
import 'package:news/home/widgets/skeleton.dart';
import 'package:news/models/following.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:news/provider/provider_widget.dart';
import 'package:news/view_models/structure_model.dart';
import 'package:news/view_models/view_state_widget.dart';

import '../api.dart';

class CustomSearchPeople extends StatefulWidget {
  @override
  _CustomSearchPeopleState createState() => _CustomSearchPeopleState();
}

class _CustomSearchPeopleState extends State<CustomSearchPeople>{

  FocusNode focusNode=FocusNode();
  TextEditingController textEditingController=TextEditingController();
  bool isWriting=false;

  List<User> userList=[];
  List<User> allUserList=[];
  List<Following> followingList=[];

  int userId=0;

  bool isLoading=true;
  bool isFollowed=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    getFollowing().then((value){
//      setState(() {
//        followingList= value;
//        print("Length00000"+ followingList.length.toString());
//        checkUser().then((value){
//          userList=value;
//          if(userList.length != 0){
//            userId=userList[0].userID;
//            getAllUser(userId,followingList).then((value){
//              allUserList=value;
//              print("User list===="+allUserList.length.toString());
//              isLoading=false;
//            });
//          }
//        });
//      });
//    });
  checkUser().then((value){
    setState(() {
      List<User> userList=value;
      userId=userList[0].userID;
    });
  });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    focusNode.dispose();
    textEditingController.dispose();

  }

  Future<List<Following>> getFollowing() async{
    List<Following> followings= await SQLiteDbProvider.db.getFollowing();
    return followings;
  }



  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<List<User>> getAllUser(int id,List<Following> followings) async{
    List<User> userList=[];
    var res = await http.post(Api.GET_ALL_USER_URL,
    body: {
      'Userid' : id.toString(),
    });
    var body=jsonDecode(res.body);
    var data=body['user'];
    for(int i=0;i<data.length;i++){
      Map map= data[i];
      User user=User.fromJson(map);
      for(int j=0;j<followings.length;j++){
        if(user.userID != followings[j].userID){
          userList.add(user);
        }
      }
    }
    return userList;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey),
        title: GestureDetector(
          onTap: () => showSearch(context: context, delegate: SearchPeople(hintText: 'Search for People...')),
          child: new Container(
            //width: 300.0,
            height: 50.0,
            //padding: EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Search for People...',
                  style: TextStyle(
                    color: Colors.black54,
                    //fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  ),
                ),
              ],
            )
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchPeople(hintText: 'Search for People...',));
            },
          ),
        ],
      ),
      body: ProviderWidget<RecommendUserModel>(
        model: RecommendUserModel(),
        onModelReady: (model) => model.initData(),
        builder: (context, model, child){
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
          return Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 20.0,
                    margin: EdgeInsets.only(left: 10.0,top: 5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('Recommend',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: ListView.builder(
                        itemCount: model.list.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index){
                          User user=model.list[index];
                          return RecommendFollower(user: user,id: userId,);
                        }
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  isWritingTo(bool param0) {
    setState(() {
      isWriting=param0;
    });
  }

  Container _recentSearch(){
    return Container(
      height: 100.0,
      child: Column(
        children: <Widget>[
        ],
      ),
    );
  }

  Container _recommendProfile(){
    return Container(
      height: 250.0,
      padding: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Recommend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('See More...'),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 220.0,
            child: ListView.builder(
              primary: false,
              itemCount: 4,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    //padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                    child: ListTile(
                      title: Text('Sai Thein Han'),
                      subtitle: Text('1k Followers',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                      ),
                      leading: Container(
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
                      trailing: Container(
                        height: 20.0,
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                //width: 12.0,
                                height: 12.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Icon(Icons.add,
                                  color: Colors.blue,size: 12.0,),
                              ),
                              Text('Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

}

class RecommendFollower extends StatefulWidget {
  final User user;
  final int id;
  RecommendFollower({this.user,this.id});

  @override
  _RecommendFollowerState createState() => _RecommendFollowerState();
}

class _RecommendFollowerState extends State<RecommendFollower> {

  bool isFollowed=false;

  int userId=0;

  insertFollower(int userid,int followerid) async{
    var res= await http.post(Api.ADD_FOLLOWER_URL,
        body: {
          "Userid" : userid.toString(),
          "Followerid" : followerid.toString(),
        });
    if(res.statusCode ==200){
      var body=jsonDecode(res.body);
      Map map=body['data'];
      Following following=Following.fromJson(map);
      SQLiteDbProvider.db.insertFollowing(following);
    }
  }

  deleteFollower(int userid,int followerid) async{
    var res = await http.delete(Api.DELETE_FOLLOWER_URL+userid.toString()+"/"+followerid.toString());
    if(res.statusCode ==200){
      print('delete success');
      int result= await SQLiteDbProvider.db.deleteFollowingById(userid);
      print(result.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId=widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      //padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
      child: ListTile(
        title: Text(widget.user.userName),
        subtitle: Text('0 Followers',
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
        leading: Container(
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
        trailing: GestureDetector(
          onTap: (){
            setState(() {
              if(isFollowed){
                isFollowed=false;
                deleteFollower(widget.user.userID,userId);
              }else{
                isFollowed=true;
                insertFollower(widget.user.userID,userId);
              }
            });
          },
          child: Container(
            height: 20.0,
            width: 70.0,
            decoration: BoxDecoration(
              color: isFollowed? Colors.white : Colors.blue,
              borderRadius: BorderRadius.circular(5.0,),
              border: Border.all(
                  color: isFollowed? Colors.black12 : Colors.blue,
                  width: 1.0
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    //width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: isFollowed? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Icon(isFollowed? Icons.check: Icons.add,
                      color: isFollowed? Colors.white : Colors.blue,size: 12.0,),
                  ),
                  Text('Follow',
                    style: TextStyle(
                      color: isFollowed? Colors.grey : Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class SearchPeople extends SearchDelegate<String> {
  String hintText='Search for People';
  final userList;
  SearchPeople({this.hintText,this.userList}):
        super(searchFieldLabel: hintText,keyboardType: TextInputType.text,textInputAction: TextInputAction.search,);


  final cities=[
    'Myanmar','Malaysia','Singapore','Vietnam','Burma','Australia',
    'America','Burma','Hungary','Holland','Zambia','Thailand','Tanzania','Japan','Korea','Cambodia',
    'Cameron','China','Denmark','Egypt','England','Finland','France','Greece','Italy','Portugal',
    'Russia','Switzerland','Netherland','USA',
  ];

  final recentCities=[
    'Myanmar','Malaysia','Singapore','Vietnam','Burma','Australia',
  ];

  bool hasQuery;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isNotEmpty?
      Container(
        width: 20.0,
        child: GestureDetector(
          child: Container(
            width: 20.0,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(100.0),
            ),
            margin: EdgeInsets.only(top: 18.0,bottom: 18.0),
            child: Center(
              child: Icon(Icons.clear,size: 15.0,color: Colors.white,),
            ),
          ),
          onTap: (){
            query= '';
            hasQuery=false;
          },
        ),
      ) : Container(),
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          query = '';
          hasQuery=false;
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return hasQuery? Container(
      width: 100.0,
      height: 100.0,
      color: Colors.red,
      child: Center(
        child: Text(query),
      ),
    ): Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 100.0,
            child: Center(
              child: Text('recent search'),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty? recentCities: cities.where((p) => p.startsWith(query)).toList();

    return Container(
      height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (BuildContext context,int index){
              return ListTile(
                onTap: (){
                  query=suggestionList[index];
                  hasQuery=true;
                  recentCities.add(suggestionList[index]);
                  showResults(context);
                },
                leading: Icon(Icons.history),
                title: RichText(
                  text: TextSpan(
                    text: suggestionList[index].substring(0,query.length),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.subdirectory_arrow_right),
              );
            },
          ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.dark,
      primaryTextTheme: theme.textTheme,
    );
  }

}
