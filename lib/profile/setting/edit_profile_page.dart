import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/database/database.dart';
import 'package:news/models/user_info.dart';
import 'dart:async';
import 'dart:io';
import 'package:news/api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum Gender { male, female }

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String token, userName, avatorImage, intro, birthday;
  int sex;
  TextEditingController _username;
  TextEditingController _introduction;
  DateTime initialDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _username = new TextEditingController();
    _introduction = new TextEditingController();
    setState(() {
      checkToken().then((value)  {
            setState(() {
              if (value == '' || value == null) {
                token = null;
                print(
                    'Please Login first! you have no permision to upload image');
              } else {
                token = value;
                //print("Your Token : " + token);
              }
            });
          });
      getUserInfo().then((UserInfo info)  {
            setState(() {
              userName = info.userName;
              avatorImage = info.avatorImage;
              intro = info.introduction;
              birthday = info.birthday;
              sex = info.gender;
            });
          });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _username.dispose();
    _introduction.dispose();
  }

  Future<String> checkToken() async {
    Future<String> futureTokenString = SQLiteDbProvider.db.getTokenString();
    String token = await futureTokenString;
    return token;
  }

  Future<UserInfo> getUserInfo() async {
    Future<UserInfo> futureUserInfo = SQLiteDbProvider.db.getUserInfo();
    UserInfo info = await futureUserInfo;
    return info;
  }

  String validateUsername(value) {
    if (value.isEmpty) {
      return '用户名不能为空!';
    }
    return null;
  }

  Future _uploadUserName(String token, String name) async {
    var uploadUrl = Api.UPDATE_USER_NAME_URL;
    final response = await http.post(uploadUrl,
        headers: {"Authorization": "Bearer $token"}, body: {"Username": name});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map userMap = data['data']['params'];
      UserInfo info = UserInfo.fromJson(userMap);
      await SQLiteDbProvider.db.updateUserInfo(info);
      _username.text = "";
      setState(() {
        userName = info.userName;
      });
    } else {
      print('更改用户名失败!');
      print(response.statusCode);
    }
  }

  Future _uploadProfileImage(String token, File image) async {
    var uploadUrl = Api.UPDATE_USER_PROFILE_IMAGE_URL;
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    // var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        path,
        filename: name,
        //contentType: MediaType("image", "jpeg"), //add this
      ),
    });
    Dio dio = new Dio(BaseOptions(headers: {"Authorization": "Bearer $token"}));
    Response response = await dio.post(uploadUrl,
        data: formData,
        options: Options(
            headers: {"Authorization": "Bearer $token"},
            contentType: "application/json"));

    if (response.statusCode == 200) {
      final data = response.data["params"];
      Map userMap = data;
      UserInfo info = UserInfo.fromJson(userMap);
      await SQLiteDbProvider.db.updateUserInfo(info);
      setState(() {
        avatorImage = info.avatorImage;
      });
    } else {
      print('头像更换失败!');
      print(response.statusCode);
    }
  }

  Future _uploadUserIntroduction(String token, String introduction) async {
    var uploadUrl = Api.UPDATE_USER_INTRODUCTION_URL;
    final response = await http.post(uploadUrl,
        headers: {"Authorization": "Bearer $token"},
        body: {"Introduction": introduction});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map userMap = data['data']['params'];
      UserInfo info = UserInfo.fromJson(userMap);
      await SQLiteDbProvider.db.updateUserInfo(info);
      _introduction.text = "";
      setState(() {
        intro = info.introduction;
      });
    } else {
      print('上传介绍失败!');
      print(response.statusCode);
    }
  }

  Future _openUsernameDialog() async {
    bool _validate = false;
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: new TextField(
                          autofocus: false,
                          controller: _username,
                          decoration: new InputDecoration(
                            labelText: '用户名',
                            hintText: '请输入用户名...',
                            errorText: _validate ? '用户名不能为空！' : null,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "*用户名不能为空",
                    style: TextStyle(color: Colors.blue[300], fontSize: 12),
                  )
                ],
              )),
          actions: <Widget>[
            new FlatButton(
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    _username.text = '';
                  });
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('更改'),
                onPressed: () {
                  setState(() {
                    _username.text.isEmpty
                        ? _validate = true
                        : _validate = false;
                    _validate
                        ? print("用户名不能为空！")
                        : _uploadUserName(token, _username.text);
                    Navigator.pop(context);
                  });
                })
          ],
        ),
      ),
    );
  }

  Future _openIntroductionDialog() async {
    bool _validate = false;
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: Container(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          maxLines: 4,
                          maxLength: 30,
                          decoration: InputDecoration.collapsed(
                            hintText: "请输入介绍内容(30个字)...",
                          ),
                          keyboardType: TextInputType.multiline,
                          controller: _introduction,
                          scrollPhysics: NeverScrollableScrollPhysics(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "*介绍不能为空",
                    style: TextStyle(color: Colors.blue[300], fontSize: 12),
                  )
                ],
              )),
          actions: <Widget>[
            new FlatButton(
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    _introduction.text = '';
                  });
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('确定'),
                onPressed: () {
                  setState(() {
                    _introduction.text.isEmpty
                        ? _validate = true
                        : _validate = false;
                  });
                  _validate
                      ? print("介绍不能为空！")
                      : _uploadUserIntroduction(token, _introduction.text);
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: Locale('zh'),
    );

    if (date == null) return;

    // Convert DateTime to String
    var bd = DateFormat("yyyy-MM-dd").format(date);

    // Convert String to DateTime
    // DateTime birthday = DateFormat("yyyy-MM-dd").parse(birthday);

    var uploadUrl = Api.UPDATE_USER_BIRTHDAY_URL;
    final response = await http.post(uploadUrl,
        headers: {"Authorization": "Bearer $token"},
        body: {"Birthday": bd});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map userMap = data['data']['params'];
      UserInfo info = UserInfo.fromJson(userMap);
      await SQLiteDbProvider.db.updateUserInfo(info);
      setState(() {
        birthday = info.birthday;
      });
    } else {
      print('生日上传失败!');
      print(response.statusCode);
    }
  }

  Future _openGenderDialog() async {
    final option = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          //title: Text('Simple Dialog'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Male'),
              onPressed: () {
                Navigator.pop(context, Gender.male);
              },
            ),
            SimpleDialogOption(
              child: Text('Female'),
              onPressed: () {
                Navigator.pop(context, Gender.female);
              },
            ),
          ],
        );
      },
    );
    switch (option) {
      case Gender.male:
        var uploadUrl = Api.UPDATE_USER_GENDER_URL;
        final response = await http.post(uploadUrl,
            headers: {"Authorization": "Bearer $token"},
            body: {"Gender": "1"});
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          Map userMap = data['data']['params'];
          UserInfo info = UserInfo.fromJson(userMap);
          await SQLiteDbProvider.db.updateUserInfo(info);
          setState(() {
            sex = info.gender;
          });
        } else {
          print('性别上传失败!');
          print(response.statusCode);
        }
        break;
      case Gender.female:
        var uploadUrl = Api.UPDATE_USER_GENDER_URL;
        final response = await http.post(uploadUrl,
            headers: {"Authorization": "Bearer $token"},
            body: {"Gender": "2"});
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          Map userMap = data['data']['params'];
          UserInfo info = UserInfo.fromJson(userMap);
          await SQLiteDbProvider.db.updateUserInfo(info);
          setState(() {
            sex = info.gender;
          });
        } else {
          print('性别上传失败!');
          print(response.statusCode);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑资料"),
      ),
      body: Container(
        color: Color.fromRGBO(220, 220, 220, 0.5),
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '头像更换',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                CircleAvatar(
                                    backgroundImage: avatorImage == '' ||
                                            avatorImage == null
                                        ? NetworkImage(
                                            'https://via.placeholder.com/150')
                                        : NetworkImage(avatorImage)),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('clicked~');
                      final action = CupertinoActionSheet(
                        title: Text(
                          "选择图片",
                          style: TextStyle(fontSize: 24),
                        ),
                        message: Text(
                          "通过以下选择项获取图片",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text(
                              "拍照",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            isDefaultAction: true,
                            onPressed: () {},
                          ),
                          CupertinoActionSheetAction(
                            child: Text(
                              "从手机相册选择",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            isDestructiveAction: true,
                            onPressed: () async {
                              Navigator.pop(context);
                              var image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              _uploadProfileImage(token, image);
                            },
                          )
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      );

                      showCupertinoModalPopup(
                          context: context, builder: (context) => action);
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 16.0,
                  ),
                  InkWell(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '用户名',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '$userName',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('clicked to change user name!');
                      _openUsernameDialog();
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 16.0,
                  ),
                  InkWell(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '介绍',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  intro == null || intro == ''
                                      ? "待完善"
                                      : "$intro",
                                  style: TextStyle(
                                      color: intro == null || intro == ''
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[600],
                                      fontSize: 15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('clicked~');
                      _openIntroductionDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 15),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '性别',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  sex == 0 ? "待完善" : sex == 1 ? "男" : "女",
                                  style: TextStyle(
                                      color:  sex == 0 ? Theme.of(context).primaryColor :Colors.grey[600], fontSize: 15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('clicked to gender!');
                      _openGenderDialog();
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 16.0,
                  ),
                  InkWell(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '生日',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  birthday == null || birthday == ''
                                      ? "待完善"
                                      : "$birthday",
                                  style: TextStyle(
                                      color: birthday == null || birthday == '' ? Theme.of(context).primaryColor :Colors.grey[600], fontSize: 15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print('clicked to calendar!');
                      _selectBirthDate();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
