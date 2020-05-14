import 'package:flutter/material.dart';
import 'package:news/explore/search_data.dart';
import 'package:news/video/pages/page_one.dart';
import 'package:news/video/pages/page_two.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  List<Tab> _tabs = List<Tab>();
  List<VideoCategory> categoryList = [];
  List<Widget> _generateWidgets = List<Widget>();
  var categoryName = ["Hot", "Health", "Funny", "Sports"];
  static List<Action> _action = <Action>[
    Action(
      title: 'Upload',
      icon: Icons.file_upload,
    ),
    Action(
      title: 'Moment',
      icon: Icons.contact_mail,
    ),
    Action(
      title: 'Article',
      icon: Icons.library_books,
    ),
    Action(
      title: 'Video',
      icon: Icons.video_call,
    )
  ];
  void _onSelected(Action action) {
    setState(() {
      selectedAction = action;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => selectedAction.widget));
    });
  }

  Action selectedAction = _action[0];

  TabController tabController;
  void initState() {
    super.initState();
    addCategory();

    tabController = TabController(vsync: this, length: categoryList.length);
    _tabs = getTabs(categoryList.length);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<Tab> getTabs(int count) {
    _tabs.clear();
    for (var i = 0; i < count; i++) {
      _tabs.add(new Tab(
        text: categoryList[i].name,
      ));
    }
    return _tabs;
  }

  void addCategory() {
    for (int i = 0; i < categoryName.length; i++) {
      categoryList.add(VideoCategory(id: i, name: categoryName[i]));
    }
  }

  List<Widget> getWidgets() {
    _generateWidgets.clear();
    for (var i = 0; i < _tabs.length; i++) {
      if (categoryList[i].name == 'Hot') {
        _generateWidgets.add(PageOne());
      } else if (categoryList[i].name == 'Health') {
        _generateWidgets.add(PageTwo());
      } else {
        _generateWidgets.add(PageOne());
      }
    }
    return _generateWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () =>
              showSearch(context: context, delegate: SearchBarDelegate()),
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
          tabs: _tabs,
          //labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          //labelPadding: EdgeInsets.only(bottom: 10.0),
          controller: tabController,
          labelColor: Colors.white,
          //indicatorSize: TabBarIndicatorSize.label,
          // unselectedLabelColor: Colors.black,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: getWidgets(),
      ),
    );
  }
}

class Action {
  final String title;
  final IconData icon;
  final Widget widget;
  const Action({this.title, this.icon, this.widget});
}

class VideoCategory {
  final int id;
  final String name;
  VideoCategory({this.id, this.name});
}
