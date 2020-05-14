import 'package:flutter/material.dart';
import 'package:news/home/page_details/none_page_details.dart';

class DisplayNoneContent extends StatefulWidget {
  @override
  _DisplayNoneContentState createState() => _DisplayNoneContentState();
}

class _DisplayNoneContentState extends State<DisplayNoneContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Container(
            height: 80.0,
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    _setPage(context);
                  },
                  child: Container(
                    height: 80.0,
                    width: MediaQuery.of(context).size.width*(90/100),
                    padding: EdgeInsets.only(left: 8.0,right: 5.0,),
                    child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30.0,
            padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Sai Thein Han',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
                Text('20 Comments',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
                Text('8 hours ago',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 5.0,
            padding: EdgeInsets.only(top: 5.0,),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }

  void _setPage(BuildContext context) {
    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => NonePageDetails())
      );
    });
  }
}
