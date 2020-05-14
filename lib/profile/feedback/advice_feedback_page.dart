import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdviceFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('意见反馈'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            tooltip: '发送',
            onPressed: () => debugPrint('Button is pressed.'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FeedbackArea(),
            Divider(
              thickness: 1.0,
              indent: 10.0,
              endIndent: 10.0,
            ),
            ContactInformation(),
            Divider(
              thickness: 1.0,
              indent: 10.0,
              endIndent: 10.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

class FeedbackArea extends StatefulWidget {
  @override
  _FeedbackAreaState createState() => _FeedbackAreaState();
}

class _FeedbackAreaState extends State<FeedbackArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: TextField(
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration.collapsed(hintText: "请输入反馈内容..."),
              keyboardType: TextInputType.multiline,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            width: 100,
            height: 100,
            color: Color.fromRGBO(220, 220, 220, 0.5),
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 35.0,
                color: Color.fromRGBO(180, 180, 180, 1.0),
              ),
              onPressed: () {},
            ),
          ),
          SizedBox(
            height: 30.0,
          )
        ],
      ),
    );
  }
}

class ContactInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Text(
            '联系方式',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '邮件、手机',
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          )
        ],
      ),
    );
  }
}
