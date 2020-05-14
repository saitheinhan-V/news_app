import 'package:flutter/material.dart';
import 'package:news/search/search_people.dart';


class RelevantRecommendation extends StatefulWidget {
  @override
  _RelevantRecommendationState createState() => _RelevantRecommendationState();
}

class _RelevantRecommendationState extends State<RelevantRecommendation> {

  List<AuthorChip> _authorChip = <AuthorChip>[
    AuthorChip('1','1',FollowCard()),
    AuthorChip('1','1',FollowCard()),
    AuthorChip('1','1',FollowCard()),
    AuthorChip('1','1',FollowCard()),
    AuthorChip('1', '1', AddCard()),
    // default Search Card
  ];



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 20.0,
                  width: 3.0,
                  color: Colors.blue,
                ),
                SizedBox(width: 5.0,),
                Text('Suggested accounts',style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: _authorChip.map((chip) {
                return Container(
                  child: chip.card,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

}

class AuthorChip {
  final String author;
  final String authentication;
  final Widget card;

  const AuthorChip(this.author, this.authentication, this.card);

}

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 148.0,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomSearchPeople()));
            },
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          child: Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                                style: BorderStyle.solid),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue[100],
                                offset: Offset(0.0, 7.0),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Add People',
                          style:
                          TextStyle(color: Colors.blue,),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FollowCard extends StatefulWidget {
  @override
  _FollowCardState createState() => _FollowCardState();
}

class _FollowCardState extends State<FollowCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      child: Stack(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                left: 8.0,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/panda.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Sai Sai🇲🇲',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 25,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: RaisedButton(
                      color: Colors.blue,
                      child: Text('Follow'),
                      onPressed: () {},
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                      elevation: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              icon: Icon(Icons.close),
              color: Colors.grey[400],
              iconSize: 16,
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

