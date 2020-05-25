import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/api.dart';
import 'package:news/home/custom_post/article_post.dart';
import 'package:news/home/page_details/none_page_details.dart';
import 'package:news/models/category.dart';
import 'package:news/home/page_details/follow_page.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/home/post/one_page.dart';
import 'package:news/home/post/none_page.dart';
import 'package:news/home/post/three_page.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/video/video_page.dart';
import 'package:news/home/custom_post/custom_video_post.dart';
import 'package:news/home/custom_post/file_video_post.dart';
import 'package:news/home/custom_post/moment_post.dart';
import 'package:news/search/search.dart';
import 'dart:io';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  TabController _tabController;

  List<Tab> _tabs = List<Tab>();
  List<Widget> _generalWidgets = List<Widget>();
  List<Category> categoryList=[];
  List<String> name=List<String>();
  List<Moment> momentList=List<Moment>();
  List<Following> followingList=List<Following>();
  List<User> userList=List<User>();

  int userID=0;


  static List<Action> _action=<Action>[
    Action(title: 'Upload',icon: Icons.file_upload,widget: FileVideoPost()),
    Action(title: 'Moment',icon: Icons.contact_mail,widget: MomentPost()),
    Action(title: 'Article',icon: Icons.library_books,widget: ArticlePost()),
    Action(title: 'Video',icon: Icons.video_call,widget: NonePageDetails()),

  ];

  Action selectedAction=_action[0];
  ProgressDialog progressDialog;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //addCategory();
    categoryList.add(Category(1,'Follow',1));
    categoryList.add(Category(2,'Funny',1));
    categoryList.add(Category(2,'Health',1));
    categoryList.add(Category(3,'International',1));
    categoryList.add(Category(4,'Hot',1));


    _tabs = getTabs(categoryList);
    _tabController = TabController(length: categoryList.length, vsync: this);
//    getCategory().then((value){
//      setState(() {
//        categoryList.clear();
//        categoryList=value;
//        print("List length==========="+categoryList.length.toString());
//        _tabs = getTabs(categoryList);
//        //_tabController = TabController(length: categoryList.length, vsync: this);
//      });
//    });

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
      });
    });

  getCategory().then((value){
    setState(() {
      //categoryList=value;
    });
  });

  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }


//  Future<List<Category>> addCategory() async{
//    List<Category> categories=List<Category>();
//      categories=await getCategory();
////      print("CAGteroy-----------------------------------====="+categoryList.length.toString());
//      //print(categoryList[0].categoryName+categoryList[1].categoryName+categoryList[2].categoryName);
////      for(int i=0;i<categoryList.length;i++){
////        name.add(categoryList[i].categoryName);
////      }
//    //_tabController = TabController(length: categoryList.length, vsync: this);
//    //_tabs = getTabs(categoryList);
//    return categories;
//  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Category>> getCategory() async{
    SQLiteDbProvider.db.deleteCategory();
    List<Category> categoryLists=[];
//    return categoryList;
    //List<Category> categoryLists= await SQLiteDbProvider.db.getCategory();
      var res = await http.get(Api.GETCATEGORY_URL);
      if(res.statusCode ==200){
        var body= jsonDecode(res.body);
        var data=body['data']['category'];
        print("--------" + data.length.toString());
        for(int i=0;i<data.length;i++){
          Category category=new Category(data[i]['Categoryid'], data[i]['Categoryname'], data[i]['Categoryorder']);
          categoryLists.add(category);
          SQLiteDbProvider.db.insertCategory(category);
        }
      }

    return categoryLists;
  }


  List<Tab> getTabs(List<Category> category) {
    _tabs.clear();
    for (int i = 0; i<category.length; i++) {
      _tabs.add(new Tab(text: category[i].categoryName));
    }
    return _tabs;
  }

  List<Widget> getWidgets(int count) {
    _generalWidgets.clear();
    for (int i = 0; i < count; i++) {
      if(categoryList[i].categoryName =='Follow'){
        _generalWidgets.add(FollowPageContent(userID: userID,));
      }else{
        _generalWidgets.add(_tabContent(context, categoryList[i].categoryName));
      }
    }
    return _generalWidgets;
  }


  void _onSelected(Action action){
    setState(() {
      selectedAction=action;
      Navigator.push(context, MaterialPageRoute(builder: (context) => selectedAction.widget));
    });
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => showSearch(context: context, delegate: CustomSearchDelegate()),
              child: new Container(
                width: 400.0,
                height: 40.0,
                padding: EdgeInsets.only(left: 10.0),
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
                      Icon(Icons.search,color: Colors.black26,),
                      SizedBox(width: 10.0,),
                      Text('Search...',
                      style: TextStyle(
                        color: Colors.black26,
                        fontSize: 15.0,
                      ),
                      ),
                    ],
                  ),
              ),
            ),
            actions: <Widget>[
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.black,
                ),
                child:  PopupMenuButton(
                  itemBuilder: (BuildContext context){
                    return _action.map((Action action){
                      return PopupMenuItem(
                        value: action,
                        child: Container(
                          width: 75.0,
                          color: Colors.black,
                          child: Row(
                            children: <Widget>[
                              Icon(action.icon,color: Colors.white,size: 20.0,),
                              SizedBox(
                                width: 3.0,
                              ),
                              Text(action.title,style: TextStyle(fontSize: 13.0,color: Colors.white),),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                  icon: Icon(Icons.add_a_photo,color: Colors.white,),
                  offset: Offset(0,100),
                  onSelected: _onSelected,
                ),
              ),
            ],
            bottom: TabBar(
              //indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs:  _tabs,
//            tabs: [
//              Tab(text: "Follow",),
//              Tab(icon: Icon(Icons.directions_transit)),
//              Tab(icon: Icon(Icons.directions_bike)),
//              Tab(icon: Icon(Icons.directions_transit)),
//              Tab(icon: Icon(Icons.directions_bike)),
//            ],
              controller: _tabController,
            ),
          ),
          body: TabBarView(
//          children: [
//            Icon(Icons.directions_car),
//            Icon(Icons.directions_transit),
//            Icon(Icons.directions_bike),
//            Icon(Icons.directions_car),
//            Icon(Icons.directions_transit),
//          ],
            children: getWidgets(_tabs.length),
            controller: _tabController,
          ),
        );
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c){
        return AlertDialog(
          title: Text('Choose to Post'),
          content: _buildAllAction(c),
        );
      }
    );
  }

}

class Action {

  final String title;
  final IconData icon;
  final Widget widget;
  const Action({this.title, this.icon,this.widget});

}

Widget _buildAllAction(BuildContext context) {

  const List<Action> _action=const <Action>[
    Action(title: 'Moment',icon: Icons.contact_mail),
    Action(title: 'Article',icon: Icons.library_books),
    Action(title: 'Video',icon: Icons.video_call),
    Action(title: 'Upload',icon: Icons.file_upload),
    Action(title: 'Moment',icon: Icons.library_books),
    Action(title: 'Moment',icon: Icons.library_books),

  ];
  File videoFile;

  List<Widget> _allWidget=[
    MomentPost(),ArticlePost(),CustomVideoPost(),FileVideoPost(),MomentPost(),MomentPost(),
  ];

  return Container(
    height: MediaQuery.of(context).size.height*(40/100),
    width: MediaQuery.of(context).size.width*(90/100),
    child: Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height*(30/100),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            primary: false,
            children: new List<Widget>.generate(6, (index) {
              return new GridTile(
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => _allWidget[index])
                    );

                  },
                  child: Card(
                    child: Center(
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        //margin: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blueAccent, width: 2.0),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                              offset: new Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(_action[index].icon),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              child: Text(
                                _action[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montsarrot',
                                  color: Colors.blueAccent,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            height: 40.0,
            padding: EdgeInsets.only(left: 10.0,right: 10.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text('Close',style: TextStyle(color: Colors.white),),
            ),
          ),
        ),
      ],
    ),
  );
}


Container _tabContent(BuildContext context, String category) {
  return Container(
    child: CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ImageContent(),
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
    _generalDelegates.add(DisplayNoneContent());
    _generalDelegates.add(DisplayOneContent());
    _generalDelegates.add(DisplayThreeContent());
   // _generalDelegates.add(MomentPage());
    _generalDelegates.add(DisplayThreeContent());
  }
  return _generalDelegates;
}



class ImageContent extends StatefulWidget {
  @override
  _ImageContentState createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg","adv4.jpg","adv5.jpg","adv6.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*(25/100),
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          //return new Image.network("http://via.placeholder.com/350x150",fit: BoxFit.fill,);
          return new Image.asset('assets/'+images[index],fit: BoxFit.cover,);
        },
        itemCount: images.length,
        pagination: new SwiperPagination(
          builder: SwiperPagination.dots,
          alignment: Alignment.bottomCenter,
        ),
        control: new SwiperControl(
          color: Colors.blue,
          size: 25.0,
        ),
        autoplay: true,
      ),
    );
  }
}








