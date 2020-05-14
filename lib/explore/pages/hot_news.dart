import 'package:flutter/material.dart';
// import 'package:news/explore/pages/hotnewswidget/horizontal_list_item.dart';

import 'package:news/explore/pages/hotnewswidget/vertical_list_item.dart';
import 'package:news/models/hot_new_model.dart';

class HotNews extends StatefulWidget {
  @override
  _HotNewsState createState() => _HotNewsState();
}

class _HotNewsState extends State<HotNews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: <Widget>[
              // Container(
              //   height: 300,
              //   child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: newlist.length,
              //       itemBuilder: (cxt, i) => HorizontalListItem(index: i)),
              // ),
              Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: ListView.builder(
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: topNewList.length,
                  itemBuilder: (ctx, i) => VerticalListItem(index: i),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
