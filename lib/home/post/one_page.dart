import 'package:flutter/material.dart';
import 'package:news/home/page_details/one_three_page_details.dart';

class DisplayOneContent extends StatefulWidget {
  @override
  _DisplayOneContentState createState() => _DisplayOneContentState();
}

class _DisplayOneContentState extends State<DisplayOneContent> {

  List imageList=["assets/panda.jpg"];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              _setPage(context);
            },
            child: Container(
              height: 60.0,
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 3.0,
                    height: 50.0,
                    color: Colors.blue,
                  ),
                  Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width*(90/100),
                    padding: EdgeInsets.only(left: 8.0,right: 5.0,),
                    child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              _setPage(context);
            },
            child: Container(
              height: 200.0,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
              child: Image.asset('assets/panda.jpg',fit: BoxFit.cover,),
            ),
          ),
          Container(
            height: 35.0,
            padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0,bottom: 10.0),
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
          MaterialPageRoute(builder: (context) => OneThreePageDetails(image: imageList,))
      );
    });
  }
}