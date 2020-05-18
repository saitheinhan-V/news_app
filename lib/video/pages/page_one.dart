import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news/models/video.dart';
import 'package:http/http.dart' as http;
import 'package:news/video/pages/commentpage/videocomment.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
// import '../globals.dart';
// import 'package:share/share.dart';

class PageOne extends StatefulWidget {
  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  // List<Video> video = List();
  var isLoading = false;
  List<VideoController> vc = [];
  List<String> vcs = List<String>();
  List<Video> videoList = List<Video>();
  // List<String> vcs = [
  //   'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
  //   'https://www.runoob.com/try/demo_source/mov_bbb.mp4',
  //   'https://gss3.baidu.com/6LZ0ej3k1Qd3ote6lo7D0j9wehsv/tieba-smallvideo/3_2bef1c8023579028c22523316a10c415.mp4'
  // ];

  @override
  void initState() {
    super.initState();
    // getCategory();
    getVideo().then((value) {
      videoList = value;
      for (int i = 0; i < videoList.length; i++) {
        vcs.add(videoList[i].videourl);
      }
      for (var i = 0; i < vcs.length; i++) {
        // vcs.add(VideoController(source: VideoPlayerController.network(vcs[i]))
        vc.add(VideoController(source: VideoPlayerController.network(vcs[i]))
          ..initialize());
      }
      print("category length" + videoList.length.toString());
    });
  }

  // getCategory() async {
  //   List<Video> videos = List<Video>();
  //   var url = "http://10.0.2.2:3000/api/auth/videoget";
  //   var res = await http.get(url);
  //   if (res.statusCode == 200) {
  //     var data = jsonDecode(res.body);
  //     print(data);
  //   }
  //   return videos;
  // }
  Future<List<Video>> getVideo() async {
    List<Video> videos = List<Video>();
    var url = "http://10.0.2.2:3000/api/auth/videoget";
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      // SQLiteDbProvider.db.deleCategory();
      for (int i = 0; i < data.length; i++) {
        Video video = Video(
            data[i]['Videoid'],
            data[i]['Videourl'],
            data[i]['Caption'],
            data[i]['Categoryid'],
            data[i]['Userpostid'],
            data[i]['Userid'],
            data[i]['Viewcount'],
            data[i]['Likecount'],
            data[i]['Createdate']);
        videos.add(video);
        // SQLiteDbProvider.db.insertCategory(category);
      }
      print(data);
    }
    return videos;
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
      body: ListView(
        children: <Widget>[
          for (var v in vc)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoBox(
                      controller: v,
                      children: <Widget>[
                        Stack(alignment: Alignment.center, children: <Widget>[
                          Positioned(
                            left: 20.0,
                            top: 0.0,
                            child: Text(
                              "埃弗拉第三方的",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "https://images.pexels.com/photos/230860/pexels-photo-230860.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 0.0, 0.0),
                                child: Text("风力发电机",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    )),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.thumb_up),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CommentPage()),
                                    );
                                  },
                                  child: Icon(
                                    Icons.message,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                              // Icon(Icons.more_horiz, size: 30,)
                              IconButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                ),
                                onPressed: () {},
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
