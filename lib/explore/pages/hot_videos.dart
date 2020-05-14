// import 'package:flutter/material.dart';

// class HotVideos extends StatefulWidget {
//   @override
//   _HotVideosState createState() => _HotVideosState();
// }

// class _HotVideosState extends State<HotVideos> {
//   List names = [
//     "abc",
//     "bbc",
//     "ccd",
//     "dde",
//     "eef",
//     "ffh",
//     "hhgh",
//     "lxx",
//     "ttd",
//     "ill"
//   ];
//   List designations = [
//     "pro",
//     "cro",
//     "gro",
//     "abc",
//     "prro",
//     "dfa",
//     "sdfas",
//     "dfl",
//     "lfks",
//     "fhed"
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView.builder(
//         itemCount: 10,
//         shrinkWrap: true,
//         itemBuilder: (BuildContext context, int index) => Container(
//           width: MediaQuery.of(context).size.width,
//           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
//           child: Card(
//             elevation: 5.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(0.0),
//             ),
//             child: Container(
//               height: 100.0,
//               width: MediaQuery.of(context).size.width,
//               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Container(
//                         width: 55.0,
//                         height: 55.0,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.greenAccent,
//                           backgroundImage: NetworkImage(
//                               "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10.0,
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             names[index],
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             designations[index],
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 18.0,
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                   Container(
//                     alignment: Alignment.center,
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//                     child: Icon(Icons.email),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
                        Stack(alignment: Alignment.topLeft, children: <Widget>[
                          Positioned(
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
