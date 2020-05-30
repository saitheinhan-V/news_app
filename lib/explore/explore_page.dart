import 'package:flutter/material.dart';
import 'package:news/explore/pages/hot_people.dart';
import 'package:news/explore/pages/hot_videos.dart';
import 'package:news/explore/pages/hot_news.dart';
import 'package:news/explore/search_data.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(child: Container()),
                TabBar(
                  tabs: <Widget>[
                    Text("Top People",style: TextStyle(fontSize: 15.0),),
                    Text("Hot News",style: TextStyle(fontSize: 15.0),),
                    Text("Hot Videos",style: TextStyle(fontSize: 15.0),),
                  ],
                  labelPadding: EdgeInsets.only(bottom: 10.0),
                  controller: tabController,
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                ),
              ],
            )
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          HotPeople(),
          HotNews(),
          HotVideos(),
        ],
      ),
    );
  }
}
