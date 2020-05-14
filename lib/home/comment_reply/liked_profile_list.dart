import 'package:flutter/material.dart';

class LikedProfile extends StatefulWidget {
  @override
  _LikedProfileState createState() => _LikedProfileState();
}

class _LikedProfileState extends State<LikedProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2 people like'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 2,
          itemBuilder: (BuildContext context,int index){
            return Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Sai Thein Han'),
                    leading: GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              image: DecorationImage(
                                image: AssetImage('assets/minion.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Divider(height: 5.0,color: Colors.grey,),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
