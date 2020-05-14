import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户反馈'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            tooltip: '更多',
            onPressed: () => debugPrint('Button is pressed.'),
          )
        ],
      ),
      body: Container(
        color: Color.fromRGBO(220, 220, 220, 0.5),
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment(-1.0, 0),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '常见问题',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(90, 90, 90, 1.0),
                    ),
                  ),
                ),
                FAQ(),
                Container(
                  alignment: Alignment(-1.0, 0),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '问题分类',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(90, 90, 90, 1.0),
                    ),
                  ),
                ),
                FAQCategory(),
              ],
            ),
            Positioned(
              bottom: 15,
              child: FeedbackBtn()
            )
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
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

class FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListItem(
            title: '我想发表内容',
          ),
          Divider(
            thickness: 1.0,
            indent: 16.0,
          ),
          ListItem(
            title: '不喜欢推荐的文章/视频',
          ),
          Divider(
            thickness: 1.0,
            indent: 16.0,
          ),
          ListItem(
            title: '我要举报文章/视频',
          ),
          Divider(
            thickness: 1.0,
            indent: 16.0,
          ),
          ListItem(
            title: '如何添加我喜欢的频道',
          ),
          Divider(
            thickness: 1.0,
            indent: 16.0,
          ),
        ],
      ),
    );
  }
}

class FAQCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.8),
                      right: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                  ),
                  child: ListItem(
                    title: '功能故障',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                  ),
                  child: ListItem(
                    title: '投诉举报',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.8),
                      right: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                  ),
                  child: ListItem(
                    title: '账号相关',
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedbackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.white,
      padding: EdgeInsets.only(left: 15.0,right: 15.0),
      child:  Row(
        children: <Widget>[
          Expanded(
            // width: 130.0,  // Expanded 不需要 width
            child: OutlineButton(
              onPressed: () {},
              child: Text('反馈历史'),
              splashColor: Colors.grey[100],
              textColor: Colors.black,
              highlightedBorderColor: Colors.grey,
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            // Expanded 不需要 width
            child: RaisedButton(
              onPressed: () { Navigator.pushNamed(context, '/advicefeedback');},
              child: Text('意见反馈'),
              splashColor: Colors.white10,
              color: Colors.blueAccent,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
          )
        ],
      ),
    );
  }
}
