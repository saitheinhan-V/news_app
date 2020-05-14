import 'dart:io';

import 'package:flutter/material.dart';

const String _name = "MyoMyint";

class ChatMessage extends StatelessWidget {
  final String text;
  final File imageFile;

  ChatMessage({Key key, this.text, this.imageFile}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: Text(_name[0]),
              backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/3433633/pexels-photo-3433633.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_name, style: Theme.of(context).textTheme.subhead),
              Container(margin: EdgeInsets.only(top: 5.0), child: Text(text)),
            ],
          )
        ],
      ),
    );
  }
}
