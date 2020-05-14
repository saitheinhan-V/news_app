import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:news/profile/recommend_user_profile.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sai Thein Han'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // 作者文品
              AuthorInformation(),
              SizedBox(
                height: 7.0,
                child: Container(
                  color: Color.fromRGBO(220, 220, 220, 1.0),
                ),
              ),
              // 作者杰作
              AuthorMasterPiece(),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthorInformation extends StatefulWidget {
  @override
  _AuthorInformationState createState() => _AuthorInformationState();
}

class _AuthorInformationState extends State<AuthorInformation>
    with SingleTickerProviderStateMixin {
  bool recommend = false;
  bool expanded = true;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blueGrey,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 10.0,
              right: 10.0,
              left: 10.0,
            ),
            child: Row(
              children: <Widget>[
                // 头像
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/minion.jpg'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                // 作者信息
                Expanded(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        // 人气
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  '1.3k',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Color.fromRGBO(128, 128, 128, 1.0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  '98',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                    color: Color.fromRGBO(128, 128, 128, 1.0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  '1.2k',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Follower',
                                  style: TextStyle(
                                    color: Color.fromRGBO(128, 128, 128, 1.0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        // 订阅
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: ButtonTheme(
                                    child: RaisedButton.icon(
                                      icon: Icon(Icons.check),
                                      label: Text(
                                        'Follow',
                                      ),
                                      onPressed: () {},
                                      splashColor: Colors.transparent,
                                      textColor: Colors.white,
                                      elevation: 10.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                        Theme.of(context).primaryColor),
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: AnimatedIcon(
                                        size: 18,
                                        icon: AnimatedIcons.menu_close,
                                        progress: controller,
                                        color:
                                        Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          expanded
                                              ? controller.forward()
                                              : controller.reverse();
                                          expanded = !expanded;
                                          recommend = !recommend;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 相关推荐
          Container(
            alignment: Alignment(-1.0, 0.0),
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Container(
                width: double.infinity,
                color: Color.fromRGBO(220, 220, 220, 1),
                child: Visibility(
                  visible: recommend ? true : false,
                  child: Container(
                    child: RelevantRecommendation(),
                  ),
                ),
              ),
            ),
          ),
          // 位置、简介
          Container(
            // color: Colors.blueGrey,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: Text('位置： 北京市东城区'),
                    )
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.view_list),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: Text('简介： 用中国人的独特视野，辣评世界风云变幻。用中国人的独特视野，辣评世界风云变幻。'),
                    )
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class AuthorMasterPiece extends StatefulWidget {
  @override
  _AuthorMasterPieceState createState() => _AuthorMasterPieceState();
}

class _AuthorMasterPieceState extends State<AuthorMasterPiece> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Container(
          child: Column(
            children: <Widget>[
              TabBar(
                unselectedLabelColor: Colors.black54,
                labelColor: Theme.of(context).primaryColor,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,

                tabs: <Widget>[
                  Tab(
                    child: Text('Article'),
                  ),
                  Tab(
                    child: Text('Moment'),
                  ),
                  Tab(
                    child: Text('Video'),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Text('全部'),
                    Text('文章'),
                    Text('视频'),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
