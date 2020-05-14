import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/video/pages/commentpage/videocomment.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PageTwo extends StatefulWidget {
  @override
  _PageTwoState createState() => _PageTwoState();
}

// ScrollController _scrollController = ScrollController();

class _PageTwoState extends State<PageTwo> {
  List<String> _videos = <String>[];
  File videoFile;
  @override
  void initState() {
    super.initState();
  }

  bool _imagePickerActive = false;
  VideoController vc;
  void _takeVideo() async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    videoFile = await ImagePicker.pickVideo(source: ImageSource.camera);
    uploadVideo(videoFile);
    _imagePickerActive = false;

    if (videoFile == null) return;

    setState(() {
      _videos.add(videoFile.path);
      vc = VideoController(source: VideoPlayerController.file(videoFile))
        ..initialize().then((_) {
          setState(() {});
          vc.play();
        });
    });
  }

  getMoredata() {}
  Future uploadVideo(File videoFiles) async {
    var uri = Uri.parse("https://warnernews.000webhostapp.com/uploadVideo.php");
    var request = new MultipartRequest("POST", uri);

    var multipartFile = await MultipartFile.fromPath("video", videoFiles.path);
    request.files.add(multipartFile);
    StreamedResponse response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    if (response.statusCode == 200) {
      print("Video uploaded");
    } else {
      print("Video upload failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.cloud_upload),
              iconSize: 30.0,
              onPressed: () {
                uploadVideo(videoFile);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: ListView.builder(
            itemCount: _videos.length,
            itemBuilder: (context, i) => Column(
              children: <Widget>[
                Container(
                    color: Colors.blueAccent,
                    height: MediaQuery.of(context).size.height * (30 / 100),
                    width: MediaQuery.of(context).size.width * (100 / 100),
                    child: _videos == null
                        ? Container(
                            child: Icon(
                              Icons.photo,
                              color: Colors.blueGrey,
                              size: 50.0,
                            ),
                          )
                        : Container(
                            child: mounted
                                ? AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: VideoBox(
                                      controller: vc,
                                      children: <Widget>[
                                        Stack(
                                            alignment: Alignment.topLeft,
                                            children: <Widget>[
                                              Positioned(
                                                child: Text(
                                                  "埃弗拉第三方的",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 40.0),
                                                ),
                                              ),
                                            ])
                                      ],
                                    ),
                                  )
                                : Container(),
                          )),
                // SizedBox(
                //   height: 20,
                // ),
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
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                              child: Text("风力发电机",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
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
                              onPressed: () {
                                // final RenderBox box =
                                //     context.findRenderObject();
                                // Share.share('hahahahahahhaahhh',
                                //     subject:
                                //         'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh',
                                //     sharePositionOrigin:
                                //         box.localToGlobal(Offset.zero) &
                                //             box.size);
                              },
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takeVideo,
        tooltip: 'Take Video',
        child: Icon(Icons.add),
      ),
    );
  }
}
