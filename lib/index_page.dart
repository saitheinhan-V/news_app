import 'package:flutter/material.dart';
import 'package:news/home/home_page.dart';
import 'package:news/profile/profile_page.dart';
import 'package:news/explore/explore_page.dart';
import 'package:news/video/video_page.dart';
import 'package:flutter/cupertino.dart';



class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with SingleTickerProviderStateMixin{

  int _currentIndex=0;
  final List<Widget> _pageOption = [
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
      body: _pageOption[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        iconSize: 20,
        selectedFontSize: 15.0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video),
              title: Text('Video')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              title: Text('Explore')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          ),
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),

    );



  }
}

