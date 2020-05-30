import 'package:flutter/material.dart';
import 'package:news/home/home_page.dart';
import 'package:news/profile/profile_page.dart';
import 'package:news/explore/explore_page.dart';
import 'package:news/video/video_page.dart';
import 'package:flutter/cupertino.dart';
import  'package:news/ant_icon.dart' ;



class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with SingleTickerProviderStateMixin{

  var _pageController = PageController();
  int _selectedIndex = 0;
  DateTime _lastPressed;
  final List<Widget> pages = [
    HomePage(),VideoPage(),ExplorePage(),ProfilePage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressed == null ||
              DateTime.now().difference(_lastPressed) > Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressed = DateTime.now();
            return false;
          }
          return true;
        },
        child: PageView.builder(
          itemBuilder: (ctx, index) => pages[index],
          itemCount: pages.length,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        iconSize: 20,
        selectedFontSize: 15.0,
        items: [
          BottomNavigationBarItem(
              icon: _selectedIndex == 0 ? new Icon(AntIcons.home_fill,) : new Icon(AntIcons.home,),
              title: Text('首页')
          ),
          BottomNavigationBarItem(
              icon: _selectedIndex == 1 ? new Icon(AntIcons.play_video_fill) : new Icon(AntIcons.play_video,),
              title: Text('视屏')
          ),
          BottomNavigationBarItem(
              icon: _selectedIndex == 2 ? new Icon(AntIcons.explore_fill) : new Icon(AntIcons.explore,),
              title: Text('动态',)
          ),
          BottomNavigationBarItem(
              icon: _selectedIndex == 3 ? new Icon(AntIcons.profile_fill) : new Icon(AntIcons.profile,),
              title: Text('我的')
          ),
        ],
      ),

    );



  }
}

