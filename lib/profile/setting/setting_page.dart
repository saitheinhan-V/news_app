import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('系统设置'),
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
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            ListItem(
              title: '语言',
            ),
            Divider(
              thickness: 1.0,
              indent: 16.0,
            ),
            ListItem(
              title: '夜间模式',
            ),
            Divider(
              thickness: 1.0,
              indent: 16.0,
            ),
            ListItem(
              title: '清理缓存',
            ),
            Divider(
              thickness: 1.0,
              indent: 16.0,
            ),
            ListItem(
              title: '编辑资料',
            ),
            Divider(
              thickness: 1.0,
              indent: 16.0,
            ),
            SizedBox(
              height: 8.0,
              child: Container(
                color: Color.fromRGBO(220, 220, 220, 0.5),
              ),
            ),
            ListItem(
              title: '检查版本',
            ),
            Divider(
              thickness: 1.0,
              indent: 16.0,
            ),
          ],
        ),
      ),
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

