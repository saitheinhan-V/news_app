import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/api.dart';
import 'package:news/home/custom_post/article_post.dart';
import 'package:news/home/page_details/none_page_details.dart';
import 'package:news/home/post/article_page.dart';
import 'package:news/models/article.dart';
import 'package:news/models/category.dart';
import 'package:news/home/page_details/follow_page.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/provider/provider_widget.dart';
import 'package:news/video/video_page.dart';
import 'package:news/home/custom_post/custom_video_post.dart';
import 'package:news/home/custom_post/file_video_post.dart';
import 'package:news/home/custom_post/moment_post.dart';
import 'package:news/search/search.dart';
import 'dart:io';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:news/view_models/project_model.dart';
import 'package:news/view_models/view_state_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:news/ant_icon.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ValueNotifier<int> valueNotifier;
  TabController tabController;

  TabController _tabController;

  List<Tab> _tabs = List<Tab>();
  List<Widget> _generalWidgets = List<Widget>();
  List<Category> categoryList = [];
  List<String> name = List<String>();
  List<Moment> momentList = List<Moment>();
  List<Following> followingList = List<Following>();
  List<User> userList = List<User>();
  List<Article> articleList = List<Article>();

  int userID = 0;

  static List<Action> _action = <Action>[
    Action(title: 'Upload', icon: AntIcons.video, widget: FileVideoPost()),
    Action(title: 'Moment', icon: AntIcons.moment, widget: MomentPost()),
    Action(title: 'Article', icon: AntIcons.article, widget: ArticlePost()),
    Action(title: 'Video', icon: AntIcons.live_video, widget: NonePageDetails()),
//    Action(title: '发布视频',icon: AntIcons.video,widget: FileVideoPost()),
//    Action(title: '发头条',icon: AntIcons.moment,widget: MomentPost()),
//    Action(title: '写文章',icon: AntIcons.article,widget: ArticlePost()),
//    Action(title: '开直播',icon: AntIcons.live_video,widget: NonePageDetails()),
  ];

  Action selectedAction = _action[0];
  ProgressDialog progressDialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valueNotifier = ValueNotifier(0);
//      checkUser().then((value) {
//        setState(() {
//          userList = value;
//          if (userList.length == 0) {
//            userID = 0;
//          } else {
//            User user = userList[0];
//            userID = user.userID;
//            print("Result========*******" + userID.toString());
//          }
//        });
//      });

  }

  Future<List<User>> checkUser() async {
    Future<List<User>> futureList = SQLiteDbProvider.db.getUser();
    List<User> userLists = await futureList;
    return userLists;
  }

  @override
  void dispose() {
    super.dispose();
    valueNotifier.dispose();
  }

  Future<List<Category>> getCategory() async {
    SQLiteDbProvider.db.deleteCategory();
    List<Category> categoryLists = [];
//    return categoryList;
    //List<Category> categoryLists= await SQLiteDbProvider.db.getCategory();
    var res = await http.get(Api.GETCATEGORY_URL);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var data = body['data']['category'];
      print("--------" + data.length.toString());
      for (int i = 0; i < data.length; i++) {
        Category category = new Category(data[i]['Categoryid'],
            data[i]['Categoryname'], data[i]['Categoryorder']);
        categoryLists.add(category);
        SQLiteDbProvider.db.insertCategory(category);
      }
    }

    return categoryLists;
  }

  List<Tab> getTabs(List<Category> category) {
    _tabs.clear();
    for (int i = 0; i < category.length; i++) {
      _tabs.add(new Tab(text: category[i].categoryName));
    }
    return _tabs;
  }

  void _onSelected(Action action) {
    setState(() {
      selectedAction = action;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => selectedAction.widget));
    });
  }

//  List<Widget> getWidgets(int count) {
//    _generalWidgets.clear();
//    for (int i = 0; i < count; i++) {
//      if (categoryList[i].categoryName == 'Follow') {
//        _generalWidgets.add(FollowPageContent(
//          userID: userID,
//        ));
//      } else {
//        _generalWidgets.add(ArticlePage(
//          id: categoryList[i].categoryID,
//        ));
//      }
//    }
//    return _generalWidgets;
//  }


  @override
  Widget build(BuildContext context) {
//    return  Scaffold(
//          appBar: AppBar(
//            title: GestureDetector(
//              onTap: () => showSearch(context: context, delegate: CustomSearchDelegate()),
//              child: new Container(
//                width: 400.0,
//                height: 40.0,
//                padding: EdgeInsets.only(left: 10.0),
//                decoration: BoxDecoration(
//                  border: Border.all(
//                    color: Colors.white,
//                    width: 2.0,
//                  ),
//                  borderRadius: BorderRadius.circular(10.0),
//                  color: Colors.white,
//                ),
//                  child: Row(
//                    children: <Widget>[
//                      Icon(Icons.search,color: Colors.black26,),
//                      SizedBox(width: 10.0,),
//                      Text('Search...',
//                      style: TextStyle(
//                        color: Colors.black26,
//                        fontSize: 15.0,
//                      ),
//                      ),
//                    ],
//                  ),
//              ),
//            ),
//            actions: <Widget>[
//              Theme(
//                data: Theme.of(context).copyWith(
//                  cardColor: Colors.black,
//                ),
//                child:  PopupMenuButton(
//                  itemBuilder: (BuildContext context){
//                    return _action.map((Action action){
//                      return PopupMenuItem(
//                        value: action,
//                        child: Container(
//                          width: 75.0,
//                          color: Colors.black,
//                          child: Row(
//                            children: <Widget>[
//                              Icon(action.icon,color: Colors.white,size: 20.0,),
//                              SizedBox(
//                                width: 3.0,
//                              ),
//                              Text(action.title,style: TextStyle(fontSize: 13.0,color: Colors.white),),
//                            ],
//                          ),
//                        ),
//                      );
//                    }).toList();
//                  },
//                  icon: Icon(Icons.add_a_photo,color: Colors.white,),
//                  offset: Offset(0,100),
//                  onSelected: _onSelected,
//                ),
//              ),
//            ],
//            bottom: TabBar(
//              //indicatorSize: TabBarIndicatorSize.label,
//              isScrollable: true,
//              tabs:  _tabs,
////            tabs: [
////              Tab(text: "Follow",),
////              Tab(icon: Icon(Icons.directions_transit)),
////              Tab(icon: Icon(Icons.directions_bike)),
////              Tab(icon: Icon(Icons.directions_transit)),
////              Tab(icon: Icon(Icons.directions_bike)),
////            ],
//              controller: _tabController,
//            ),
//          ),
//          body: TabBarView(
////          children: [
////            Icon(Icons.directions_car),
////            Icon(Icons.directions_transit),
////            Icon(Icons.directions_bike),
////            Icon(Icons.directions_car),
////            Icon(Icons.directions_transit),
////          ],
//            children: getWidgets(_tabs.length),
//            controller: _tabController,
//          ),
//        );

  super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ProviderWidget<ProjectCategoryModel>(
          model: ProjectCategoryModel(),
          onModelReady: (model) {
            model.initData();
          },
          builder: (context, model, child) {
            if (model.isBusy) {
              return ViewStateBusyWidget();
            }
            if (model.isError) {
              return ViewStateErrorWidget(
                  error: model.viewStateError, onPressed: model.initData);
            }

            List<Category> categoryList = model.list;
            var primaryColor = Theme.of(context).primaryColor;
            return ValueListenableProvider<int>.value(
              value: valueNotifier,
              child: DefaultTabController(
                length: model.list.length,
                initialIndex: valueNotifier.value,
                child: Builder(
                  builder: (context) {
                    if (tabController == null) {
                      tabController = DefaultTabController.of(context);
                      tabController.addListener(() {
                        valueNotifier.value = tabController.index;
                      });
                    }
                    return Scaffold(
                      appBar: AppBar(
                        title: GestureDetector(
                          onTap: () => showSearch(
                              context: context,
                              delegate: CustomSearchDelegate()),
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
                                Icon(
                                  Icons.search,
                                  color: Colors.black26,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'Search...',
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
                              icon: Container(
                                child: Column(
                                  children: <Widget>[
                                    Icon(AntIcons.add,color: Colors.white,size: 23,),
                                    SizedBox(height: 1.5,),
                                    Text('发布',style: TextStyle(fontSize: 11),)
                                  ],
                                ),
                              ),
                              offset: Offset(0,100),
                              onSelected: _onSelected,
                            ),
                          ),
                        ],
                        bottom: TabBar(
                            isScrollable: true,
                            tabs: List.generate(
                                categoryList.length,
                                (index) => Tab(
                                      text: categoryList[index].categoryName,
                                    ))),
                      ),
                      body: TabBarView(
                        children: List.generate(
                            categoryList.length,
                            (index) => categoryList[index].categoryName=='Follow' ? FollowMainPage() : ArticlePage(id: categoryList[index].categoryID,),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
    );
  }

  showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return AlertDialog(
            title: Text('Choose to Post'),
            content: _buildAllAction(c),
          );
        });
  }
}

class Action {
  final String title;
  final IconData icon;
  final Widget widget;

  const Action({this.title, this.icon, this.widget});
}

Widget _buildAllAction(BuildContext context) {
  const List<Action> _action = const <Action>[
    Action(title: 'Moment', icon: Icons.contact_mail),
    Action(title: 'Article', icon: Icons.library_books),
    Action(title: 'Video', icon: Icons.video_call),
    Action(title: 'Upload', icon: Icons.file_upload),
    Action(title: 'Moment', icon: Icons.library_books),
    Action(title: 'Moment', icon: Icons.library_books),
  ];
  File videoFile;

  List<Widget> _allWidget = [
    MomentPost(),
    ArticlePost(),
    CustomVideoPost(),
    FileVideoPost(),
    MomentPost(),
    MomentPost(),
  ];

  return Container(
    height: MediaQuery.of(context).size.height * (40 / 100),
    width: MediaQuery.of(context).size.width * (90 / 100),
    child: Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * (30 / 100),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            primary: false,
            children: new List<Widget>.generate(
              6,
              (index) {
                return new GridTile(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => _allWidget[index]));
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
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40.0,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ImageContent extends StatefulWidget {
  @override
  _ImageContentState createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {
  var images = [
    "adv1.jpg",
    "adv2.jpg",
    "adv3.jpg",
    "adv4.jpg",
    "adv5.jpg",
    "adv6.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * (25 / 100),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          //return new Image.network("http://via.placeholder.com/350x150",fit: BoxFit.fill,);
          return new Image.asset(
            'assets/' + images[index],
            fit: BoxFit.fill,
          );
        },
        itemCount: images.length,
        pagination: new SwiperPagination(
          builder: SwiperPagination.dots,
          alignment: Alignment.bottomCenter,
        ),
        control: new SwiperControl(
          color: Colors.black12,
          size: 25.0,
        ),
        autoplay: true,
      ),
    );
  }
}
