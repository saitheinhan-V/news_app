import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/comment_reply/comment_content.dart';
import 'package:news/home/comment_reply/liked_profile_list.dart';
import 'package:news/home/comment_reply//reply_page.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:http/http.dart' as http;
import 'package:news/models/check_time.dart';
import 'package:news/models/comment.dart';
import 'package:news/models/following.dart';
import 'package:news/models/user.dart';

class CommentPage extends StatefulWidget {
  final int momentID;

  CommentPage({Key key,this.momentID});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  Future<bool> _onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }

  int userID=0;
  int momentID=0;

  String name='';

  bool _loading=true;
  bool isLiked = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  //List<String> comment=["sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han",];
  List<Comment> oldCommentList=[];
  List<Comment> newCommentList=[];
  List<User> userList=[];
  List<String> nameList=[];
  List<String> dateList=[];

  bool isShowSticker=false;
  bool isWriting=false;

  DateTime created;
  DateTime now=DateTime.now();
  String date;
  String username='';

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isShowSticker=false;
    momentID=widget.momentID;
    print("Momentid====="+momentID.toString());

    getAllComment(momentID).then((value){
      setState(() {
        oldCommentList=value;
        _loading=false;
        print('Old comment length======'+oldCommentList.length.toString());
      });
    });

    checkUser().then((value){
      setState(() {
        userList=value;
        if(userList.length != 0){
          userID=userList[0].userID;
          username=userList[0].userName;
        }
      });
    });

  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  void hideKeyboard() {
    _focusNode.unfocus();
  }

  void showStickerContainer() {
    setState(() {
      isShowSticker=true;
    });
  }

  void showKeyboard(){
    _focusNode.requestFocus();
  }

  void hideStickerContainer(){
    setState(() {
      isShowSticker=false;
    });
  }

  void isWritingTo(bool val){
    setState(() {
      isWriting=val;
    });
  }

  Future<List<Comment>> getAllComment(int id) async{
    List<Comment> comments=[];
    var res= await http.post(Api.GET_COMMENT_URL,
    body: {
      'Postid' : id.toString(),
      'Field' : 'moment',
    });
    if(res.statusCode ==200){
      var body= jsonDecode(res.body);
      var data=body['data'];
      for(int i=0;i<data.length;i++){
        Comment comment=new Comment(data[i]['Commentid'],data[i]['Userid'],data[i]['Postid'],data[i]['field'],data[i]['Username'],data[i]['Text'],data[i]['Likecount'],data[i]['Createdate']);
        comments.add(comment);
      }
    }
    return comments;
  }

  newComment(int userid,String name,int momentid,String text) async{
    addComment(userid,name, momentid, text).then((value){
      setState(() {
        Comment comment=value;
        newCommentList.add(comment);
        print("New comment list length====="+newCommentList.length.toString());
      });
    });
  }

  Future<Comment> addComment(int user_id,String name,int moment_id,String content) async{
    var res = await http.post(Api.ADD_COMMENT_URL,
    body: {
      'Userid' : user_id.toString(),
      'Postid' : moment_id.toString(),
      'Field' : "moment",
      'Username' : name,
      'Text' : content,
      'Likecount' : "0",
    });
      print("Add success");
      var body=jsonDecode(res.body);
      var data=body['data'];
      Comment comment=new Comment(data['Commentid'],data['Userid'],data['Postid'],data['field'],data['Username'],data['Text'],data['Likecount'],data['Createdate']);
    return comment;
  }

  Future<User> getUserInfo(int id) async{
    var res=await http.post(Api.USER_INFO_URL,
        body: {
          'Userid' : id.toString(),
        });
    var data=jsonDecode(res.body);
    Map userMap=data['data'];
    User user=User.fromJson(userMap);
    return user;
  }

  String getName(int id){
    String s;
    User user;
    getUserInfo(id).then((value){
        user=value;
        s = user.userName;
        print("Name is0000000000"+s);
    });
    return s;
  }

  String getDate(String createDate){
    var arr= createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    String result=Check().checkDate(created, now);
    return result;
  }

  Future<bool> checkLike(int user_id, int post_id) async{
    bool checked;
    var res= await http.post(Api.LIKE_CHECK_URL,
        body: {
          'Userid' : user_id.toString(),
          'Postid' : post_id.toString(),
          'Type' : "moment",
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

  List<Widget> getOldComment() {
    List<Widget> generalComment=[];
    for(var i=0;i<oldCommentList.length;i++){
      Comment comment=oldCommentList[i];
      generalComment.add(CommentContent(comment: comment,oldList: oldCommentList,newList: newCommentList,));
          print("Userid====="+userID.toString());
    }
    return generalComment;
  }

  List<Widget> getNewComment(){
    List<Widget> general=List<Widget>();
    for(var i=0;i<newCommentList.length;i++){
      Comment comment=newCommentList[i];
    general.add(CommentContent(comment: comment,oldList: oldCommentList,newList: newCommentList,));
    }
    return general;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment'),
      ),
      body: _loading? Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ) :
      Column(
        children: [
          Flexible(
            child: CustomScrollView(
              slivers: <Widget>[
                newCommentList.length>0? SliverList(
                  delegate: SliverChildListDelegate(
                    getNewComment(),
                  ),
                ) : SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        Container(),
                      ]
                  ),
                ),
                oldCommentList.length>0? SliverList(
                  delegate: SliverChildListDelegate(
                    getOldComment(),
                  ),
                ) : SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        Container(),
                      ]
                  ),
                ),
                (oldCommentList.length==0 && newCommentList.length==0)? SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          margin: EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.message,size: 50.0,color: Colors.grey,),
                                Text('No comment yet...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                  ),
                                ),
                                Text('Be the first to comment',style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.0,
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ]
                  ),
                ) : SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(),
                    ]
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: _buildInput(),
          ),
          isShowSticker ? buildSticker() : Container(),
          // Loading
          // _buildLoading()
        ],
      ),
    );
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

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji);
        setState(() {
          isWriting=true;
          _textEditingController.text=_textEditingController.text+emoji.emoji;
        });
      },
    );
  }

  Widget _buildInput() {
   // final user = AppModel.of(context).currentUser;
    //if (user == null) {
    //  return _buildNeedLogin();
    //}

    //if (user != null && user.isAnonymous) {
    //  return _buildNeedUpgradeAccount();
    //}

    return Container(
        //height: 100.0,
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            color: Colors.white),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Edit text
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        onTap: (){
                          hideStickerContainer();
                        },
                        onChanged: (val){
                          (val.length>0 && val.trim()!="")? //isWriting=true: isWriting=false;
                          isWritingTo(true) : isWritingTo(false);
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: TextStyle(fontSize: 15.0),
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(10.0),
                          filled: true,
                          hintText: "Enter Comment...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.black12,width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.black54,width: 1.0),
                          ),
                        ),
                        focusNode: _focusNode,
                        autofocus: false,
                      ),
                    ),
                  ),
                  Material(
                    child: new Container(
                      child: new IconButton(
                        icon: new Icon(Icons.insert_emoticon,color: isShowSticker? Colors.blue : Colors.blueGrey,),
                        onPressed: () {
                          setState(() {
                            if(!isShowSticker){
                              hideKeyboard();
                              showStickerContainer();
                            }else{
                              showKeyboard();
                              hideStickerContainer();
                            }
                          });
                        },
                      ),
                    ),
                    color: Colors.white,
                  ),
                  // Button send message
                  Material(
                    child: Container(
                      padding: EdgeInsets.only(right: 10.0, left: 5.0),
                      child: isWriting?
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            size: 30.0,
                            color: Colors.blue,
                          ),
                         // onTap: _postComment,
                          onPressed: (){
                            setState(() {
                              if(userID!=0){
                                newComment(userID,username,momentID,_textEditingController.text);
                                _textEditingController.text='';
                                _focusNode.unfocus();
                              }else{
                                _textEditingController.text='';
                                _focusNode.unfocus();
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext ctx){
                                      return AlertDialog(
                                        title: Text('Warning'),
                                        content: Text('You need to log in or register to be able to give comment'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Ok'),
                                            onPressed: (){
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                );
                              }

                            });
                          },
                        )
                       : Container(),
                    ),
                    color: Colors.white,
                  ),
                ],
        ));
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

}

