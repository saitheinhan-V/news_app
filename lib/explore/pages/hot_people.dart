import 'package:flutter/material.dart';

import 'package:news/video/pages/commentpage/videocomment.dart';
import '../../models/hot_people_model.dart';

class HotPeople extends StatefulWidget {
  @override
  _HotPeopleState createState() => _HotPeopleState();
}

class _HotPeopleState extends State<HotPeople> {
  final instructors = allInstructors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFFAF6ED),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              child: Text('Hot People',
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
            ),
            Container(
                height: MediaQuery.of(context).size.height,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 0.67,
                  primary: false,
                  children: <Widget>[
                    ...instructors.map((e) {
                      return buildInstructorGrid(e);
                    }).toList()
                  ],
                ))
          ],
        ),
      ),
    );
  }

  buildInstructorGrid(Instructor instructor) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  // UserDetail(selectedInstructor: instructor)
                  CommentPage()));
        },
        child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Stack(
              children: <Widget>[
                Container(
                    height: 150.0, width: 100.0, color: Colors.transparent),
//                Positioned(
//                    left: 30.0,
//                    top: 65.0,
//                    child: Container(
//                        height: 30.0,
//                        width: 40.0,
//                        decoration: BoxDecoration(boxShadow: [
//                          BoxShadow(
//                              //blurRadius: 7.0,
//                              color: Colors.grey.withOpacity(0.75),
//                              offset: Offset(5, 25),
//                              spreadRadius: 12.0)
//                        ]))),
                Positioned(
                    left: 12.0,
                    top: 15.0,
                    child: Container(
                        height: 110.0,
                        width: 85.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            image: DecorationImage(
                                image: NetworkImage(instructor.instructorPic),
                                fit: BoxFit.cover)))),
                Positioned(
                    left: 22.0,
                    top: 138.0,
                    child: Column(
                      children: <Widget>[
                        Text(instructor.instructorName,
                            style: TextStyle(
                                color: Colors.black87, fontSize: 12.0)),
                        Row(children: [
                          Icon(
                            Icons.star,
                            color: Colors.grey.withOpacity(0.5),
                            size: 15.0,
                          ),
                          SizedBox(width: 3.0),
                          Text(instructor.rating,
                              style: TextStyle(color: Colors.black))
                        ])
                      ],
                    ))
              ],
            )));
  }
}
