import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news/models/hot_new_model.dart';

class VerticalListItem extends StatelessWidget {
  final int index;
  VerticalListItem({this.index});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5.0,
          child: Row(
            children: <Widget>[
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)),
                  child: new CachedNetworkImage(
                    imageUrl: topNewList[index].imageUrl,
                    height: 150.0,
                    width: 96.0,
                    fit: BoxFit.cover,
                  ),
                ),
                width: 150.0,
                height: 150.0,
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.only(
                //         bottomLeft: Radius.circular(5),
                //         topLeft: Radius.circular(5)),
                //     image: DecorationImage(
                //         fit: BoxFit.cover,
                //         image: CachedNetworkImageProvider(
                //             topNewList[index].imageUrl))),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 75.0),
                  // margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(topNewList[index].title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.0)),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(topNewList[index].description),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 5.0,
        )
      ],
    );
  }
}
