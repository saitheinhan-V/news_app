import 'package:flutter/material.dart';

import 'skeleton.dart';

class VideoSkeletonItem extends StatelessWidget {
  final int index;

  VideoSkeletonItem({this.index: 0});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(
              bottom: Divider.createBorderSide(context,
                  width: 0.7, color: Colors.redAccent))),
      child: Column(
        children: <Widget>[
          Container(
            width: width,
            height: 150.0,
            decoration: SkeletonDecoration(isDark: isDark),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
                decoration: SkeletonDecoration(isCircle: true, isDark: isDark),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 20,
                width: 300,
                decoration: SkeletonDecoration(isDark: isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}