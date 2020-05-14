import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news/models/hot_new_model.dart';

import 'detail_pagetwo.dart';

class HorizontalListItem extends StatelessWidget {
  final int index;
  HorizontalListItem({this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage()),
          );
        },
        child: Column(
          children: <Widget>[
            Card(
              elevation: 10.0,
              child: Container(
                height: 200,
                width: 160.0,

                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(5),
                //     image: DecorationImage(
                //         image: CachedNetworkImageProvider(
                //             newlist[index].imageUrl))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: new CachedNetworkImage(
                    imageUrl: newlist[index].imageUrl,
                    height: 150.0,
                    width: 96.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              newlist[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              "流口水的犯",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
            ),
          ],
        ),
      ),
    );
  }
}
