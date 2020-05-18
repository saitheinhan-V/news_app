import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/home/custom_post/article_post.dart';
import 'package:news/home/page_details/none_page_details.dart';
import 'package:news/models/category.dart';
import 'package:news/home/page_details/follow_page.dart';
import 'package:news/home/post/moment_page.dart';
import 'package:news/home/post/one_page.dart';
import 'package:news/home/post/none_page.dart';
import 'package:news/home/post/three_page.dart';
import 'package:news/video/video_page.dart';
import 'package:news/home/custom_post/custom_video_post.dart';
import 'package:news/home/custom_post/file_video_post.dart';
import 'package:news/home/custom_post/moment_post.dart';
import 'package:news/search/search.dart';
import 'dart:io';
import 'package:news/database/database.dart';
import 'package:news/models/user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;

  List<Tab> _tabs = List<Tab>();
  List<Widget> _generalWidgets = List<Widget>();

  List<Category> categoryList = [];

  // var categoryName = [
  //   "Follow",
  //   "Health",
  //   "Funny",
  //   "International",
  //   "Hot",
  // ];
  // List<Category> categoryName = [];
  static List<Action> _action = <Action>[
    Action(title: 'Upload', icon: Icons.file_upload, widget: FileVideoPost()),
    Action(title: 'Moment', icon: Icons.contact_mail, widget: MomentPost()),
    Action(title: 'Article', icon: Icons.library_books, widget: ArticlePost()),
    Action(title: 'Video', icon: Icons.video_call, widget: NonePageDetails()),
  ];

  Action selectedAction = _action[0];

  @override
  void initState() {
    super.initState();
    //addCategory();
    getCategory();
    // getCategory().then((value) {
    //   categoryList = value;
    //   _tabController =
    //       new TabController(length: categoryList.length, vsync: this);
    //   _tabs = getTabs(categoryList.length);
    // });
    setState(() {
      _tabController =
          new TabController(length: categoryList.length, vsync: this);
      _tabs = getTabs(categoryList.length);
    });
  }

  getCategory() async {
    var url = "http://10.0.2.2:3000/api/auth/category";
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      SQLiteDbProvider.db.deleCategory();
      for (int i = 0; i < data.length; i++) {
        Category category = Category(data[i]['Categoryid'],
            data[i]['Categoryname'], data[i]['Categoryorder']);
        categoryList.add(category);
        SQLiteDbProvider.db.insertCategory(category);
      }
      print(data);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> getTabs(int count) {
    _tabs.clear();
    for (int i = 0; i < count; i++) {
      _tabs.add(new Tab(
        text: categoryList[i].categoryName,
      ));
    }
    return _tabs;
  }

  List<Widget> getWidgets() {
    _generalWidgets.clear();
    for (int i = 0; i < _tabs.length; i++) {
      if (categoryList[i].categoryName == 'Follow') {
        _generalWidgets.add(FollowPageContent());
      } else {
        _generalWidgets.add(_tabContent(context, categoryList[i].categoryName));
      }
    }
    return _generalWidgets;
  }

  // void addCategory() {
  //   for (int i = 0; i < categoryName.length; i++) {
  //     categoryList.add(Category(i, categoryName[i]));
  //   }
  // }

  void _onSelected(Action action) {
    setState(() {
      selectedAction = action;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => selectedAction.widget));
    });
  }

  @override
  Widget build(BuildContext context) {
    //_tabController = new TabController(length: categoryList.length, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () =>
              showSearch(context: context, delegate: CustomSearchDelegate()),
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
            child: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return _action.map((Action action) {
                  return PopupMenuItem(
                    value: action,
                    child: Container(
                      width: 75.0,
                      color: Colors.black,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            action.icon,
                            color: Colors.white,
                            size: 20.0,
                          ),
                          SizedBox(
                            width: 3.0,
                          ),
                          Text(
                            action.title,
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              icon: Icon(
                Icons.add_a_photo,
                color: Colors.white,
              ),
              offset: Offset(0, 100),
              onSelected: _onSelected,
            ),
          ),
        ],
        bottom: TabBar(
          //indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabs: _tabs,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: getWidgets(),
        controller: _tabController,
      ),
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
    _generalDelegates.add(MomentPage());
    _generalDelegates.add(DisplayThreeContent());
  }
  return _generalDelegates;
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
            fit: BoxFit.cover,
          );
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
