import 'package:flutter/material.dart';

class PageFour extends StatefulWidget {
  @override
  _PageFourState createState() => _PageFourState();
}

class _PageFourState extends State<PageFour> {
  List names = [
    "abc",
    "bbc",
    "ccd",
    "dde",
    "eef",
    "ffh",
    "hhgh",
    "lxx",
    "ttd",
    "ill"
  ];
  List designations = [
    "pro",
    "cro",
    "gro",
    "abc",
    "prro",
    "dfa",
    "sdfas",
    "dfl",
    "lfks",
    "fhed"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 200.0,
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  myArticles(
                      "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                      "heading",
                      "subheading"),
                  myArticles(
                      "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                      "heading",
                      "subheading"),
                  myArticles(
                      "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                      "heading",
                      "subheading"),
                  myArticles(
                      "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                      "heading",
                      "subheading"),
                ],
              ),
            ),
            Container(
              height: 800.0,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 10,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) => Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    child: Container(
                      height: 100.0,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 55.0,
                                height: 55.0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.greenAccent,
                                  backgroundImage: NetworkImage(
                                      "https://images.pexels.com/photos/242492/pexels-photo-242492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    names[index],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    designations[index],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18.0,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: Icon(Icons.email),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Container myArticles(String imageval, String heading, String subheading) {
    return Container(
      width: 160.0,
      child: Card(
        child: Wrap(
          children: <Widget>[
            Image.network(imageval),
            ListTile(
              title: Text(heading),
              subtitle: Text(subheading),
            )
          ],
        ),
      ),
    );
  }
}
