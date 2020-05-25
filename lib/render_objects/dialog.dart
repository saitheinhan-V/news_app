
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dialog{

  _showDialog(BuildContext context) async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return AlertDialog(
            title: Text('Success'),
            content: Text('Your post has been uploaded!'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){
                      Navigator.pop(c);
                      Navigator.pop(context);
                  },
                  child: Text('Ok')),
            ],
          );
        }
    );
  }
}