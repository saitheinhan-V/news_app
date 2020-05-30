import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news/ant_icon.dart';
import 'package:news/models/following.dart';
import 'package:news/models/video.dart';
import 'package:news/video/pages/commentpage/videocomment.dart';
import 'package:video_box/video_box.dart';
import 'package:http/http.dart' as http;

import '../api.dart';

class VideoContent extends StatefulWidget {
  final Video video;

  VideoContent({this.video});

  @override
  _VideoContentState createState() => _VideoContentState();
}

class _VideoContentState extends State<VideoContent> {
  VideoController vc;
  List<String> vcs = [];
  List<Video> videoList = List<Video>();
  Following following;
  Video video;

  String name='';

  @override
  void initState() {
    super.initState();
    video = widget.video;
    vc = VideoController(
        source: VideoPlayerController.network(
            'http://192.168.0.119:3000/public/' + video.videoUrl))
      ..initialize();

    getUserInfo(video.userID).then((value){
      setState(() {
        following=value;
        name=following.userName;
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    vc.dispose();
  }

  Future<Following> getUserInfo(int id) async{
    var res=await http.post(Api.USER_INFO_URL,
        body: {
          'Userid' : id.toString(),
        });
    var data=jsonDecode(res.body);
    Map userMap=data['data'];
    Following following=Following.fromJson(userMap);
    return following;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: AspectRatio(aspectRatio: 16 / 9,
              child: VideoBox(
                controller: vc,
                children: <Widget>[
                  Stack(alignment: Alignment.center, children: <Widget>[
                    Positioned(
                      left: 10.0,
                      top: 3.0,
                      child: Text(
                        video.caption,
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ),
                  ])
                ],
              ),
            ),
          ),
          Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://images.pexels.com/photos/230860/pexels-photo-230860.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                      ),
                      Padding(
                          padding:
                          const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                          child: Text(
                              name))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentPage()),
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(
                                AntIcons.comment,
                                size: 18.0,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5.0,),
                              Text('0',style: TextStyle(color: Colors.grey),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0,),
                      // Icon(Icons.more_horiz, size: 30,)
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 5.0,
            padding: EdgeInsets.only(top: 3.0,),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}
