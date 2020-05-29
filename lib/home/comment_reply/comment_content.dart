import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/comment_reply/reply_page.dart';
import 'package:news/models/check_time.dart';
import 'package:news/models/comment.dart';
import 'package:http/http.dart' as http;
import 'package:news/models/user.dart';

class CommentContent extends StatefulWidget {
  final Comment comment;
  final List<Comment> oldList;
  final List<Comment> newList;
  CommentContent({Key key,this.comment,this.oldList,this.newList});

  @override
  _CommentContentState createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> {

  Comment comment;

  bool isLiked=false;

  List<User> userList=[];
  List<Comment> oldList=[];
  List<Comment> newList=[];

  int userID=0;
  int likeCount=0;
  int replyCount=0;

  String date;
  String name;

  DateTime now=DateTime.now();
  DateTime created;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    comment=widget.comment;
    oldList=widget.oldList;
    newList=widget.newList;

    checkUser().then((value){
      userList=value;
      if(userList.length != 0){
        userID=userList[0].userID;
        checkLike(userID, comment.commentID).then((value){
          setState(() {
            isLiked=value;
          });
        });
      }
    });

    getReplyCount(comment.commentID).then((value){
      setState(() {
        replyCount=value;
      });
    });

    var arr= comment.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    likeCount=comment.likeCount;
    name=comment.userName;
    date=Check().checkDate(created, now);
  }

  Future<int> getReplyCount(int id) async{
    int count=0;
    var res =await http.post(Api.GET_REPLY_COUNT_URL,
    body: {
      "Commentid" : id.toString(),
    });
    if(res.statusCode ==200){
      var data=jsonDecode(res.body);
      count= data['count'];
    }
    return count;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<bool> checkLike(int user_id, int post_id) async{
    bool checked;
    var res= await http.post(Api.LIKE_CHECK_URL,
        body: {
          'Userid' : user_id.toString(),
          'Postid' : post_id.toString(),
          'Field' : "comment",
        });
    if(res.statusCode ==200){
      var data=jsonDecode(res.body);
      if(data['data']['Id'] == 0){
        checked=false;
      }else{
        checked=true;
      }
    }
    return checked;
  }

  removeComment(int id) async{
    var response= await http.delete(Api.DELETE_COMMENT_URL+id.toString());
    if(response.statusCode ==200){
      print("Delete comment success");
    }
  }

  updateCommentLike(int commentID, int likeCount) async{
    var response = await http.put(Api.LIKE_COMMENT_UPDATE_URL,
        body: {
          'Commentid' : commentID.toString(),
          'Likecount' : likeCount.toString(),
        });
    if(response.statusCode ==200){
      print("Update success");
    }
  }

  insertLikeRecord(int user_id,int post_id) async{
    var response= await http.post(Api.LIKERECORD_URL,
        body: {
          'Userid' : user_id.toString(),
          'Postid' : post_id.toString(),
          'Field' : "comment",
        });
    if(response.statusCode ==200){
      print("record success");
    }
  }

  deleteLikeRecord(int user_id,int post_id) async{
    var response= await http.delete(Api.DELETELIKE_URL+user_id.toString()+"/"+post_id.toString()+"/"+"comment");
    if(response.statusCode ==200){
      print('delete success');
    }
  }

  deleteCommentLikeRecord(int id) async{
    var res = await http.delete(Api.DELETE_COMMENT_LIKE_RECORD_URL+id.toString()+"/"+"comment");
    if(res.statusCode ==200){
      print("delete success");
    }
  }

  Widget refreshBg(){
    return Container(
      width: 50.0,
      padding: EdgeInsets.only(right: 20.0),
      alignment: Alignment.centerRight,
      color: Colors.red,
      child: const Icon(Icons.delete,color: Colors.white,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dismissible(
        onDismissed: (direction){
          //var company = companies[index];
          //showSnackBar(context, company ,index);
          setState(() {
            removeComment(comment.commentID);
            deleteCommentLikeRecord(comment.commentID);

          });
        },
        key: Key(comment.commentID.toString()),
        background: refreshBg(),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0,),
                    image: DecorationImage(
                      image: AssetImage('assets/panda.jpg'),
                      fit: BoxFit.cover,
                    )
                ),
              ),
              title: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text(comment.userName),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          child: Icon(Icons.thumb_up,color: isLiked? Colors.blue : Colors.grey,size: 15.0,),
                          onTap: (){
                            setState(() {
                              if(isLiked){
                                isLiked=false;
                                likeCount=likeCount-1;
                                deleteLikeRecord(userID, comment.commentID);
                              }else{
                                isLiked=true;
                                likeCount=likeCount+1;
                                insertLikeRecord(userID, comment.commentID);
                              }
                              updateCommentLike(comment.commentID,likeCount);
                            });
                          },
                        ),
                        SizedBox(width: 3.0,),
                        Text(likeCount.toString(),style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: (){
                        if(comment.userID == userID){
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc){
                                return Container(
                                  child: new Wrap(
                                    children: <Widget>[
                                      new ListTile(
                                        leading: new Icon(Icons.reply),
                                        title: new Text('Reply'),
                                        onTap: (){
                                          Navigator.pop(bc);
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => ReplyPage(comment: comment,liked: isLiked,))
                                          );
                                        },
                                      ),
                                      new ListTile(
                                        leading: new Icon(Icons.delete),
                                        title: new Text('Delete'),
                                        onTap: (){
                                          setState(() {
                                            removeComment(comment.commentID);
                                            deleteCommentLikeRecord(comment.commentID);
                                            Navigator.pop(bc);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(comment.text,
                          style: TextStyle(
                            color: Colors.black,
                            height: 1.5,
                            fontSize: 15.0,
                          ),
                          //textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8.0,),
                      child: Row(
                              children: <Widget>[
                                Text(date,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 3.0,),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => ReplyPage(comment: comment,liked: isLiked,))
                                      );
                                    });
                                  },
                                  child: Container(
                                    height: 20.0,
                                    // width: 80.0,
                                    padding: EdgeInsets.only(left: 5.0,right: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(10.0,),
                                    ),
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                            text: replyCount.toString(),
                                            style: TextStyle(fontSize: 10.0,color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: ' Reply',
                                                  style: TextStyle(color: Colors.black,fontSize: 10.0)
                                              )
                                            ]
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0,right: 10.0),
              child: Divider(height: 5.0,color: Colors.grey,),
            ),
          ],
        ),
      ),
    );
  }
}
