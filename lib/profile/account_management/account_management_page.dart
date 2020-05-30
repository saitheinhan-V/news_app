import 'package:flutter/material.dart';
import 'package:news/profile/account_management/change_profile_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  File _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账号管理'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            tooltip: 'Search',
            onPressed: () => debugPrint('Button is pressed.'),
          )
        ],
      ),
      body: Container(
          child: Stack(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(220, 220, 220, 0.5),
            child: ListView(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('头像更换'),
                        trailing: CircleAvatar(
                          backgroundImage: _imagePath == null
                              ? NetworkImage('https://via.placeholder.com/150')
                              : FileImage(_imagePath),
                        ),
                        onTap: () {
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
                                  setState(() {
                                    _imagePath = image;
                                    print(_imagePath);
                                  });
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
                      ListItem(
                        title: '修改用户名',
                      ),
                      Divider(
                        thickness: 1.0,
                        indent: 16.0,
                      ),
                      ListItem(
                        title: '修改手机号码',
                      ),
                      Divider(
                        thickness: 1.0,
                        indent: 16.0,
                      ),
                      ListItem(
                        title: '修改登陆密码',
                      ),
                      Divider(
                        thickness: 1.0,
                        indent: 16.0,
                      ),
                      ListItem(
                        title: '隐私权限设置',
                      ),
                      Divider(
                        thickness: 1.0,
                        indent: 16.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
              bottom: 50,
              child: GestureDetector(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    // padding: EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        '退出账号',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 6.0,
                          fontSize: 16.0,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ))
        ],
      )),
    );
  }
}

class ListItem extends StatelessWidget {
  final String title;
  final Widget page;

  ListItem({this.title, this.page}); // 构造函数

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
