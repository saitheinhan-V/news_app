import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:news/database/database.dart';
import 'package:news/models/category.dart';
import 'package:news/models/token.dart';
import 'package:news/models/user.dart';

import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
import 'package:video_box/video.controller.dart';

class FileVideoPost extends StatefulWidget {
  @override
  _FileVideoPostState createState() => _FileVideoPostState();
}

class _FileVideoPostState extends State<FileVideoPost> {
  VideoController videoController;
  PersistentBottomSheetController bottomSheetController;
  TextEditingController captionController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  FocusNode focusNode = new FocusNode();
  bool isWriting = false;
  bool validate = true;
  bool hasVideo;
  File videoFile;
  bool changed = false;
  bool firstChanged = false;
  int count = 0;
  String caption = '';
  String description = '';
  String _selectedCategory;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String responselink;

//
  List<String> _categoryName = List<String>();
  List<User> userList = List<User>();
  List<Token> tokenList = List<Token>();
  List<Category> categoryList = List<Category>();
  String userToken = '';
  int userId = 0;
  int categoryID = 0;
  //
  @override
  void initState() {
    super.initState();
    hasVideo = false;
//
    getCategory().then((value) {
      categoryList = value;
      for (int i = 0; i < categoryList.length; i++) {
        _categoryName.add(categoryList[i].categoryName);
      }
      print("category length" + categoryList.length.toString());
    });

    setState(() {
      checkUser().then((value) {
        userList = value;
        if (userList.length != 0) {
          userId = userList[0].userID;
        }
      });

      checkToken().then((value) {
        setState(() {
          tokenList = value;
          print("Token length=================" + tokenList.length.toString());
          if (tokenList.length != 0) {
            userToken = tokenList[0].value;
            print(userToken);
          }
        });
      });
    });
    //
  }

//getting list of category

  @override
  void dispose() {
    captionController.dispose();
    descriptionController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<List<Token>> checkToken() async {
    Future<List<Token>> list = SQLiteDbProvider.db.getToken();
    List<Token> tokenLists = await list;
    return tokenLists;
  }

  Future<List<Category>> getCategory() async {
    List<Category> categorys = List<Category>();
    var url = "http://10.0.2.2:3000/api/auth/category";
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      // SQLiteDbProvider.db.deleCategory();
      for (int i = 0; i < data.length; i++) {
        Category category = Category(data[i]['Categoryid'],
            data[i]['Categoryname'], data[i]['Categoryorder']);
        categorys.add(category);
        // SQLiteDbProvider.db.insertCategory(category);
      }
      print(data);
    }
    return categorys;
  }
//db category list
  // Future<List<Category>> getCategory() async {
  //   Future<List<Category>> list = SQLiteDbProvider.db.getCategory();
  //   List<Category> categoryList = await list;
  //   return categoryList;
  // }

  Future<List<User>> checkUser() async {
    Future<List<User>> futureList = SQLiteDbProvider.db.getUser();
    List<User> userLists = await futureList;
    return userLists;
  }

  isWritingTo(bool val) {
    setState(() {
      isWriting = val;
    });
  }

//pick video
  _pickVideo() async {
    File file = await ImagePicker.pickVideo(source: ImageSource.camera);
    //File file=await FilePicker.getFile(type: FileType.video);
    uploadVideo(file);
    if (file != null) {
      setState(() {
        changed = true;
        videoFile = file;
        videoController =
            VideoController(source: VideoPlayerController.file(file))
              ..initialize().then((_) {});
      });
    }
  }

  //upload video
  Future uploadVideo(File videoFiles) async {
    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        videoFiles.path,
      ),
    });
    Dio dio = new Dio();
    Response res =
        await dio.post("http://10.0.2.2:3000//api/auth/upload", data: data);
    if (res.statusCode == 200) {
      responselink = res.data['filepath'];
    }
    // .then((response) => print(response))
    // .catchError((error) => print(error));
  }

  Future<bool> _onBackPressed() {
    return videoFile != null
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext c) {
              return AlertDialog(
                title: Text('Warning'),
                content: Text('Are you sure want to exit!'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(c);
                    },
                    child: Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.pop(context);
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            })
        : Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('File Video'),
      ),
      body: WillPopScope(
        child: Container(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  videoFile != null
                      ? Container(
                          height: 250.0,
                          //width: MediaQuery.of(context).size.width*(100/100),
                          //child: FittedBox(
                          //fit: BoxFit.fill,
                          //height: 250.0,
                          child: mounted
                              ? AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: VideoBox(controller: videoController),
                                )
                              : Container(),
                          //),
                        )
                      : Container(
                          height: 250.0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _pickVideo();
                              },
                              child: Container(
                                width: 100.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Video',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Divider(
                      height: 5.0,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Text('Category'),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  hint: Text(
                                    'Choose Category',
                                    style: TextStyle(color: Colors.grey),
                                  ), // Not necessary for Option 1
                                  value: _selectedCategory,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                  ),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                      for (int i = 0;
                                          i < categoryList.length;
                                          i++) {
                                        if (categoryList[i].categoryName ==
                                            _selectedCategory) {
                                          categoryID =
                                              categoryList[i].categoryID;
                                        }
                                      }
                                    });
                                  },
                                  items: _categoryName.map((name) {
                                    return DropdownMenuItem(
                                      child: new Text(name),
                                      value: name,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Divider(
                      height: 5.0,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Text('Caption'),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                //_showBottomSheet(context);
                                //_showAlertDialog(context);
                                _showCaptionDialog(context);
                              });
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      caption,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Divider(
                      height: 5.0,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text('Description'),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: () {
                              _showDescriptionDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 9,
                                  child: Text(
                                    description,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Divider(
                      height: 5.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                height: 50.0,
                padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if (videoFile != null) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext c) {
                                  return AlertDialog(
                                    title: Text('Warning'),
                                    content: Text('Are you sure want to exit!'),
                                    actions: <Widget>[
                                      new FlatButton(
                                          onPressed: () => Navigator.pop(c),
                                          child: Text('No')),
                                      new FlatButton(
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(c);
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text('Yes')),
                                    ],
                                  );
                                });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 40.0,
                          padding: EdgeInsets.only(left: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                            ),
                            child: Center(
                                child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            )),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _checkToPost();
                          });
                        },
                        child: Container(
                          height: 40.0,
                          padding: EdgeInsets.only(left: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                              color: (_selectedCategory != null &&
                                      caption.isNotEmpty &&
                                      caption != "Caption..." &&
                                      videoFile != null)
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            child: Center(
                                child: Text(
                              'Post',
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onWillPop: _onBackPressed,
      ),
    );
  }

  _showCaptionDialog(BuildContext context) async {
    if (caption.isNotEmpty && caption != "Caption...") {
      captionController.text = caption;
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 110.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: captionController,
                      maxLines: null,
                      maxLength: 50,
                      autofocus: true,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: "Caption...",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        //errorText: validate? null : 'please enter at least 5',
                      ),
                      onChanged: (val) {
                        (val.length >= 5 && val.trim() != null)
                            ? isWritingTo(true)
                            : isWritingTo(false);
                      },
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 5.0),
                      height: 17.0,
                      child: Text(
                        'min 5 ~ max 50',
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  'Save',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  setState(() {
                    if (isWriting == true) {
                      validate = true;
                      caption = captionController.text;
                      Navigator.of(context).pop();
                    } else {
                      validate = false;
                    }
                  });
                },
              )
            ],
          );
        });
  }

  _showDescriptionDialog(BuildContext context) async {
    if (description.isNotEmpty && description != "Description...") {
      descriptionController.text = description;
    } else {
      //descriptionController.text="Description...";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 140.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: descriptionController,
                      maxLength: 200,
                      maxLines: 4,
                      focusNode: focusNode,
                      keyboardType: TextInputType.multiline,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Description...",
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        //errorText: validate? null : 'please enter at least 5',
                      ),
                      onChanged: (val) {
                        (val.length > 0 && val.trim() != null)
                            ? isWritingTo(true)
                            : isWritingTo(false);
                      },
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 5.0),
                      height: 17.0,
                      child: Text(
                        'min 0 ~ max 500',
                        style: TextStyle(color: Colors.grey, fontSize: 10.0),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    setState(() {
                      if (isWriting == true) {
                        validate = true;
                        description = descriptionController.text;
                      } else {
                        validate = false;
                        description = "Description...";
                      }
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Save')),
            ],
          );
        });
  }

  newvideopost(String token) async {
    var response =
        await http.post("http://10.0.2.2:3000/api/auth/videopost", headers: {
      'Authorization': 'Bearer $token'
    }, body: {
      'Caption': caption,
      'Videourl': responselink,
      'Categoryid': categoryID.toString(),
      "Viewcount": "12",
      "Likecount": "12",
    });
    print('Response body: ${response.body}');
  }

  uploadpost(String user_token) async {
    var userPostUrl = "http://10.0.2.2:3000/api/auth/userpost";
    var res = await http
        .post(userPostUrl, headers: {'Authorization': 'Bearer $user_token'});
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      var token = data['data']['token'];
      print(data);
      print(token);
      newvideopost(token);
    }
  }

  _checkToPost() async {
    if (_selectedCategory != null &&
        caption != null &&
        caption != "Caption...") {
      if (videoFile != null) {
        // var res = http.post(
        //   "http://10.0.2.2:3000/api/auth/userpost",
        //   // headers: {'Authorization': 'Bearer $token'},
        // );
        uploadpost(userToken);
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Warning'),
                content: Text(
                  'Please add video file to be able to home.post!',
                  style: TextStyle(height: 1.5),
                ),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: new Text('Ok'))
                ],
              );
            });
      }
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Warning'),
              content: Text(
                'Please enter both category and caption field to be able to home.post!',
                style: TextStyle(height: 1.5),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: new Text('Ok'))
              ],
            );
          });
    }
  }
}
