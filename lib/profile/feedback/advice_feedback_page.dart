import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:news/database/database.dart';
import 'package:news/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';


class All {
  int id;
  File image;

  All(this.id, this.image);
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

class AdviceFeedbackPage extends StatefulWidget {
  @override
  _AdviceFeedbackPageState createState() => _AdviceFeedbackPageState();
}

class _AdviceFeedbackPageState extends State<AdviceFeedbackPage> {
  int count = 0;
  int listLength = 0;
  int maxImages = 3;
  int index = 0;
  bool isWriting = false;
  bool first = true;
  String token, _fbSpecificScene, link;
  TextEditingController fbcontent;
  ProgressDialog progressDialog;

  List<Token> tokenList = new List<Token>();
  List<String> links =
      List<String>(); // convert link to post (get from multi-image-picker)
  List<Asset> images = List<Asset>(); // get image asset from multi-image-picker
  List<Widget> list = []; // image display (9 images)
  List<All> allList = []; // final release images (after delete any images)
  List<File> _files = [];
  List<String> _link =
      []; // to receive the image from response of uploadImage()
  List<String> _fbScene = ['功能故障', '投诉举报', '账号相关', '其他问题'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    count = 0;
    list = List<Widget>()..add(buildAddButton());
    setState(() {
      checkToken().then((value) => {
            setState(() {
              tokenList = value;
              if (tokenList.length == 0) {
                token = null;
                print('Please Login first! you have no permision to feedback');
              } else {
                token = tokenList[0].value; // get token value from tokenList
                // print("Your Token : " + token);
              }
            })
          });
    });
    fbcontent = new TextEditingController(); // 反馈内容
    //fbcontact = new TextEditingController(); // 联系方式
    count = 0;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    list.clear();
    fbcontent.dispose();
  }

  Future<List<Token>> checkToken() async {
    Future<List<Token>> futureTokenList = SQLiteDbProvider.db.getToken();
    List<Token> token = await futureTokenList;
    return token;
  }

  void isWritingTo(bool value) {
    setState(() {
      isWriting = value;
    });
  }

  Widget buildAddButton() {
    return Container(
      width: 100,
      height: 100,
      color: Color.fromRGBO(220, 220, 220, 0.5),
      child: IconButton(
        icon: Icon(
          Icons.add,
          size: 35.0,
          color: Color.fromRGBO(180, 180, 180, 1.0),
        ),
        onPressed: () {
          setState(() {
            init();
            print("List length" + list.length.toString());
          });
        },
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return (isWriting || list.length > 1)
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext c) {
              return AlertDialog(
                title: Text('提示'),
                content: Text('是否放弃发送反馈!'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(c);
                    },
                    child: Text('留下'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.pop(context);
                    },
                    child: Text('放弃'),
                  ),
                ],
              );
            })
        : false;
  }

  _uploadFeedbackWithoutImages(String token) async {
    var fbUrl = "http://localhost:3000/api/auth/feedback";

    final response = await http.post(fbUrl, headers: {
      "Authorization": "Bearer $token"
    }, body: {
      "fbcategory": _fbSpecificScene,
      "fbcontent": fbcontent.text,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var msg = data["msg"];
      print("Message from response data : " + msg);
    } else {
      //throw Exception('反馈失败！');
      print('反馈失败');
      print(response.statusCode);
    }
  }

  _uploadFeedback(String token, String links) async {
    var fbUrl = "http://localhost:3000/api/auth/feedback";

    final response = await http.post(fbUrl, headers: {
      "Authorization": "Bearer $token"
    }, body: {
      "fbcategory": _fbSpecificScene,
      "fbcontent": fbcontent.text,
      "fbscreencapture": links
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var msg = data["msg"];
      print("Message from response data : " + msg);
    } else {
      //throw Exception('反馈失败！');
      print('反馈失败');
      print(response.statusCode);
    }
  }

  uploadImage(String token) async {
    var token = this.token;
    var uploadUrl = "http://localhost:3000/api/auth/upload";
    if (allList.length == 0) {
      _uploadFeedbackWithoutImages(token);
    }
    else {
      for (int i = 0; i < allList.length; i++) {
        File file = allList[i].image;
        FormData formData = new FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path),
        });
        Dio dio = new Dio();
        Response response = await dio.post(uploadUrl, data: formData);
        if (response.statusCode == 200) {
          _link.add(response.data["filepath"]);
          link = _link.reduce((value, element) => value + ',' + element);
        }
      }
      _uploadFeedback(token, link);
    }


  }

  _sendFeedback(String token) async {
    if (_fbSpecificScene == null) {
      print('请选择反馈类型');
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: "请选择反馈类型！",
          description: "",
          buttonText: "返回",
        ),
      );
    } else {
      uploadImage(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context);
    progressDialog.style(
        message: 'Uploading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 3.0,
        insetAnimCurve: Curves.easeInCirc,
        progress: 0.0,
        maxProgress: 10.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 1.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.bold));

    return Scaffold(
      appBar: AppBar(
        title: Text('意见反馈'),
        elevation: 0.0,
        actions: <Widget>[
          (isWriting || list.length > 1)
              ? IconButton(
                  icon: Icon(Icons.send),
                  tooltip: '发送',
                  onPressed: () => {_sendFeedback(token)},
                )
              : Container()
        ],
      ),
      body: WillPopScope(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: TextField(
                        maxLines: 6,
                        maxLength: 200,
                        decoration: InputDecoration.collapsed(
                          hintText: "请输入反馈内容(5-200个字)...",
                        ),
                        keyboardType: TextInputType.multiline,
                        controller: fbcontent,
                        onChanged: (value) {
                          (value.trim() != null && value.length >= 5)
                              ? isWritingTo(true)
                              : isWritingTo(false);
                        },
                        scrollPhysics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Container(
                      child: Wrap(
                        children: list,
                        spacing: 5.0,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1.0,
                indent: 10.0,
                endIndent: 10.0,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            '反馈类型',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: Text(
                                '选择反馈类型',
                                style: TextStyle(color: Colors.grey),
                              ),
                              // Not necessary for Option 1
                              value: _fbSpecificScene,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16.0,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  _fbSpecificScene = newValue;
                                });
                              },
                              items: _fbScene.map((category) {
                                return DropdownMenuItem(
                                  child: new Text(category),
                                  value: category,
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
//              Divider(
//                thickness: 1.0,
//                indent: 10.0,
//                endIndent: 10.0,
//              ),
            ],
          ),
        ),
        onWillPop: _onBackPressed,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Future<String> getFilePath(Asset asset) async {
    String filePath = '';
    filePath = await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
    return filePath;
  }

  Future<List<Asset>> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImages,
        enableCamera: true,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

//     If the widget was removed from the tree while the asynchronous platform
//     message was in flight, we want to discard the reply rather than calling
//     setState to update our non-existent appearance.

    setState(() {
      images = resultList;
      print("Image count========" + images.length.toString());
    });

    return images;
  }

  Future<void> init() async {
    List<Asset> image = await loadAssets();
    if (image.length != 0) {
      List<File> files = [];
      for (Asset asset in image) {
        final filePath =
            await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
        files.add(File(filePath));
      }
      if (!mounted) return;
      setState(() {
        _files = files;
        print("File length=====" + _files.length.toString());
        if (list.length <= 3) {
          print("============" + _files.length.toString());
          for (var i = 0; i < _files.length; i++) {
            File file = _files[i];
            index = list.length - 1;
            list.insert(index, buildImage(file));
            allList.add(All(index, file));
          }
          if (_files.length == 3) {
            print('length before=============' + list.length.toString());
            print('length after=============' + list.length.toString());
          }
          if (list.length >= 4) {
            maxImages = 0;
            list.removeLast();
            print('After length===' + list.length.toString());
          } else if (list.length == 3) {
            maxImages = 1;
          } else {
            maxImages = (3 - list.length) + 1;
          }
          print("Max Length====" + maxImages.toString());
        }
      });
    }
  }

  Widget buildGridView() {
    if (images != null)
      return Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          children: List.generate(images.length, (index) {
            Asset asset = images[index];
            return AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            );
          }),
        ),
      );
    else
      return buildAddButton();
  }

  Widget buildImage(File image) {
    return Container(
      height: 100.0,
      width: 100.0,
      padding: EdgeInsets.only(bottom: 5),
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: 100.0,
              height: 100.0,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                listLength = 0;
                if (allList.length == 3) {
                  count = 0;
                }
                if (list.length <= 2) {
                  count = 1;
                }

                outer:
                for (var j = 0; j < allList.length; j++) {
                  if (image == allList[j].image) {
                    listLength = allList[j].id;
                    list.remove(list[listLength]);
                    break outer;
                  }
                }

                for (var n = listLength + 1; n < allList.length; n++) {
                  allList[n].id = n - 1;
                }
                allList.remove(allList[listLength]);

                list.add(buildAddButton());
                count = count + 1;
                for (var i = 1; i < count; i++) {
                  list.remove(list[list.length - 1]);
                  count = 1;
                }
                maxImages = (3 - list.length) + 1;
                print("after delete===" + maxImages.toString());
              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 5.0, right: 5.0),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//class FeedbackArea extends StatefulWidget {
//  @override
//  _FeedbackAreaState createState() => _FeedbackAreaState();
//}
//
//class _FeedbackAreaState extends State<FeedbackArea> {
//  TextEditingController fbcontent = TextEditingController();
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      padding: EdgeInsets.all(10.0),
//      color: Colors.white,
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Container(
//            child: TextField(
//              maxLines: 4,
//              maxLength: 200,
//              decoration: InputDecoration.collapsed(hintText: "请输入反馈内容..."),
//              keyboardType: TextInputType.multiline,
//            ),
//          ),
//          SizedBox(
//            height: 5.0,
//          ),
//          Container(
//            width: 100,
//            height: 100,
//            color: Color.fromRGBO(220, 220, 220, 0.5),
//            child: IconButton(
//              icon: Icon(
//                Icons.add,
//                size: 35.0,
//                color: Color.fromRGBO(180, 180, 180, 1.0),
//              ),
//              onPressed: () {},
//            ),
//          ),
//          SizedBox(
//            height: 30.0,
//          )
//        ],
//      ),
//    );
//  }
//}

//class ContactInformation extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      padding: EdgeInsets.only(left: 10.0, right: 10.0),
//      width: double.infinity,
//      color: Colors.white,
//      child: Row(
//        children: <Widget>[
//          Text(
//            '联系方式',
//            style: TextStyle(
//              fontSize: 16,
//            ),
//          ),
//          SizedBox(
//            width: 20.0,
//          ),
//          Expanded(
//            child: TextField(
//              decoration: InputDecoration(
//                hintText: '邮件、手机',
//                border: OutlineInputBorder(borderSide: BorderSide.none),
//              ),
//            ),
//          )
//        ],
//      ),
//    );
//  }

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.padding),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              //SizedBox(height: 16.0),
//              Text(
//                description,
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 16.0,
//                ),
//              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    buttonText,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
//        Positioned(
//          left: Consts.padding,
//          right: Consts.padding,
//          child: CircleAvatar(
//            backgroundColor: Colors.blueAccent,
//            radius: Consts.avatarRadius,
//          ),
//        ),
      ],
    );
  }
}
//}
