import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccountManagementPage extends StatelessWidget {
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
          color: Color.fromRGBO(220, 220, 220, 0.5),
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    ListItem(
                      title: '头像更换',
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
                    SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
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
                            splashColor: Colors.white,
                            onPressed: () {},
                          ),
                        )
                      ],
                    )),
              )
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
