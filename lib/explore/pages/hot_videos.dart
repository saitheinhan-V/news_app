

import 'package:flutter/material.dart';
import 'package:news/video/pages/commentpage/videocomment.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
// import '../globals.dart';
// import 'package:share/share.dart';

class HotVideos extends StatefulWidget {
  @override
  _HotVideosState createState() => _HotVideosState();
}

class _HotVideosState extends State<HotVideos> {
  List<VideoController> vc = [];

  List<String> vcs = [
    'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
    'https://gss3.baidu.com/6LZ0ej3k1Qd3ote6lo7D0j9wehsv/tieba-smallvideo/3_2bef1c8023579028c22523316a10c415.mp4'
  ];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < vcs.length; i++) {
      // vcs.add(VideoController(source: VideoPlayerController.network(vcs[i]))
      vc.add(VideoController(source: VideoPlayerController.network(vcs[i]))
        ..initialize());
    }
  }

  @override
  void dispose() {
    for (var v in vc) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      body: ListView(
//        children: <Widget>[
//          for (var v in vc)
//            Padding(
//              padding: const EdgeInsets.only(top: 12.0),
//              child: Column(
//                children: <Widget>[
//                  AspectRatio(
//                    aspectRatio: 16 / 9,
//                    child: VideoBox(
//                      controller: v,
//                      children: <Widget>[
//                        Stack(alignment: Alignment.topLeft, children: <Widget>[
//                          Positioned(
//                            child: Text(
//                              "埃弗拉第三方的",
//                              style: TextStyle(
//                                  color: Colors.white, fontSize: 20.0),
//                            ),
//                          ),
//                        ])
//                      ],
//                    ),
//                  ),
//                  Container(
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      children: <Widget>[
//                        Padding(
//                          padding: const EdgeInsets.all(20.0),
//                          child: Row(
//                            children: <Widget>[
//                              CircleAvatar(
//                                backgroundImage: NetworkImage(
//                                    "https://images.pexels.com/photos/230860/pexels-photo-230860.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
//                              ),
//                              Padding(
//                                padding: const EdgeInsets.fromLTRB(
//                                    8.0, 0.0, 0.0, 0.0),
//                                child: Text("风力发电机",
//                                    style: TextStyle(
//                                      color: Colors.grey,
//                                    )),
//                              )
//                            ],
//                          ),
//                        ),
//                        Padding(
//                          padding:
//                              const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
//                          child: Row(
//                            children: <Widget>[
//                              Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Icon(Icons.thumb_up),
//                              ),
//                              Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: GestureDetector(
//                                  onTap: () {
//                                    Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (context) => CommentPage()),
//                                    );
//                                  },
//                                  child: Icon(
//                                    Icons.message,
//                                    size: 20.0,
//                                  ),
//                                ),
//                              ),
//                              // Icon(Icons.more_horiz, size: 30,)
//
//                              IconButton(
//                                icon: Icon(
//                                  Icons.more_horiz,
//                                ),
//                                onPressed: () {},
//                              )
//                            ],
//                          ),
//                        )
//                      ],
//                    ),
//                  )
//                ],
//              ),
//            ),
//        ],
//      ),
    );
  }
}
