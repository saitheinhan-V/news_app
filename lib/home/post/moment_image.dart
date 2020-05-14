import 'package:flutter/material.dart';
import 'package:news/models/check_time.dart';

class MomentImage extends StatefulWidget {
  final List image;
  final int height;
  MomentImage({Key key,this.image,this.height}):super(key: key);

  @override
  _MomentImageState createState() => _MomentImageState();
}

class _MomentImageState extends State<MomentImage> {

  List list = [
    'https://images.unsplash.com/photo-1502117859338-fd9daa518a9a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1554321586-92083ba0a115?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1536679545597-c2e5e1946495?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1543922596-b3bbaba80649?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1502943693086-33b5b1cfdf2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80',
  ];
  List imgList=[];
  var height=0;
  bool one=false,two=false,three=false,four=false,five=false;
  int len=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imgList=widget.image;
   // height=widget.height;
    checkHeight();
  }

  void checkHeight(){
    if(imgList.length==1){
      height=200;
      five=true;
    }else if(imgList.length==3){
      height=100;
      one=true;
    }else if(imgList.length==2){
      height=150;
      four=true;
    } else if(imgList.length>3 && imgList.length<=6){
      height=200;
      one=true;
      two=true;
      print(imgList.length);
      setLength(imgList.length);
    }else if(imgList.length>6 && imgList.length<=9){
      height=300;
      one=true;two=true;three=true;
      setLength(imgList.length);
    }
  }

  void setLength(int length){
    if(length==8 || length==5){
      len=1;
    }else if(length==9 || length==6){
      len=2;
    }else if(length==7){
      len=0;
    }else if(length==4){
      len=5;
    }
  }

  @override
  Widget build(BuildContext context) {
   // return _imageAllContent(height,imageList.length);
    return Container(
      height: height.toDouble(),
      child: Column(
        children: <Widget>[
          one? Container(
            height: 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: imageContent(imgList[0]),
                ),
                Expanded(
                  flex: 1,
                  child: imageContent(imgList[1]),
                ),
                Expanded(
                  flex: 1,
                  child: imageContent(imgList[2]),
                ),
              ],
            ),
          ) : Container(),
          two? Container(
            height: 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: imageContent(imgList[3]),
                ),
                Expanded(
                  flex: 1,
                  child: (len==0 || len==1 || len==2)? imageContent(imgList[4]) : Container(),
                ),
                Expanded(
                  flex: 1,
                  child: ((len==0 || len==2) || imgList.length==8)? imageContent(imgList[5]) : Container(),
                ),
              ],
            ),
          ) : Container(),
          three? Container(
            height: 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: imageContent(imgList[6]),
                ),
                Expanded(
                  flex: 1,
                  child: (len==1 || len==2)? imageContent(imgList[7]) : Container(),
                ),
                Expanded(
                  flex: 1,
                  child: (len==2)? imageContent(imgList[8]) : Container(),
                ),
              ],
            ),
          ) : Container(),
          four? Container(
            height: 150.0,
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      height: 150.0,
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/'+imgList[0]),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                    )
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      height: 150.0,
                      child: Container(
                        margin: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/'+imgList[1]),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                    )
                ),
              ],
            ),
          ) : Container(),
          five? Container(
            height: 200.0,
            child: Container(
              margin: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0),
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/'+imgList[0]),
                    fit: BoxFit.cover,
                  )
              ),
            ),
          ): Container(),
        ],
      ),
    );
  }

  Container imageContent(String image){
    return Container(
      height: 100.0,
      child: Container(
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/'+image),
              fit: BoxFit.cover,
            )
        ),
      ),
    );
  }
//
//  Container _imageAllContent(int height,int len) {
//    return height>199 && height!=0? _content(height,len) :  _manyContent(height,len);
//  }
//
//  Container _manyContent(int height,int length) {
//    return length==2? _twoContent(height,length) : _threeSixNineContent(height,length);
//  }

//  Container _content(int height,int length) {
//    return length==1? _oneContent(height,length) : _threeSixNineContent(height,length);
//  }
//
//  Container _twoContent(int height, int length) {
//    return Container(
//      height: height.toDouble(),
//      padding: EdgeInsets.only(left: 10.0,right: 10.0),
//      child: GridView.count(
//        primary: false,
//        crossAxisCount: 2,
//        crossAxisSpacing: 3,
//        mainAxisSpacing: 3,
//        children: List<Widget>.generate(
//            length, (index){
//          return GridTile(
//            child: Container(
//              //width: 100.0,
//              child: Image.network(imageList[index],fit: BoxFit.cover,),
//              //child: Image.asset(imageList[index],fit: BoxFit.cover,),
//            ),
//          );
//        }
//        ),
//      ),
//    );
//  }


//  _oneContent(int height, int length) {
//    return Container(
//      height: height.toDouble(),
//      width: MediaQuery.of(context).size.width,
//      padding: EdgeInsets.only(left: 10.0,right: 10.0),
//      child: Image.network(imageList[0],fit: BoxFit.cover,),
//    );
//  }

  _threeSixNineContent(int height, int length) {
    return Container(
      height: height.toDouble(),
      padding: EdgeInsets.only(left: 10.0,right: 10.0),
      child: GridView.count(
        primary: false,
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        children: List<Widget>.generate(
            length, (index){
          return new GridTile(
            child: Card(
              child: Center(
                child: Container(
                  height: 80.0,
                  width: 80.0,
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.blueAccent, width: 2.0),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    boxShadow: <BoxShadow>[
                      new BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3.0,
                        offset: new Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Image.asset(
                          'assets/panda.jpg',
                          fit: BoxFit.fill,
                          height: 50.0,
                          width: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        child: Text(
                          'home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montsarrot',
                            color: Colors.blueAccent,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        ),
      ),
    );
  }
}
