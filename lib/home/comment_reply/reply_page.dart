import 'package:flutter/material.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/comment_reply//liked_profile_list.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/models/check_time.dart';
import 'package:news/models/comment.dart';
import 'package:news/models/following.dart';
import 'package:news/models/reply.dart';
import 'package:news/models/user.dart';
import 'package:news/profile/user_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReplyPage extends StatefulWidget {
  final Comment comment;
  final bool liked;
  ReplyPage({Key key,this.comment,this.liked});

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool isShowSticker=false;
  bool isWriting=false;
  bool isFollowed=false;
  bool isLoading=true;
  bool isLiked=false;
  int commentLikeCount=0;

  int count=100;
  int userID=0;
  int commentID=0;

  List<Reply> replyList=[];
  List<User> userList=[];
  List<Following> followingList=[];

  String username;
  String date;

  DateTime created;
  DateTime now=DateTime.now();

  Comment comment;
  Following following;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    comment=widget.comment;
    isLiked=widget.liked;
    commentLikeCount=comment.likeCount;
    commentID=comment.commentID;

    getAllReply(comment.commentID).then((value){
      setState(() {
        replyList=value;
        isLoading=false;
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

    getFollowing(comment.userID).then((value){
      setState(() {
        following=value;
        if(following==null){
          isFollowed=false;
        }else{
          isFollowed=true;
        }
      });
    });

    var arr= comment.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    date=Check().checkDate(created, now);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void hideKeyboard() {
    focusNode.unfocus();
  }

  void showStickerContainer() {
    setState(() {
      isShowSticker=true;
    });
  }

  void showKeyboard(){
    focusNode.requestFocus();
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

  Future<Following> getFollowing(int id) async{
    Following following= await SQLiteDbProvider.db.getFollowingById(id);
    return following;
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

  Future<List<Reply>> getAllReply(int id) async{
    List<Reply> replies=[];
    var res= await http.post(Api.GET_REPLY_URL,
    body: {
      'Commentid' : id.toString(),
    });
    if(res.statusCode==200){
      var body= jsonDecode(res.body);
      var data=body['data'];
      for(int i=0;i<data.length;i++){
        Reply reply=new Reply(data[i]['Replyid'],data[i]['Commentid'],data[i]['Userid'],data[i]['Username'],data[i]['Text'],data[i]['Likecount'],data[i]['Createdate']);
        replies.add(reply);
      }
    }
    return replies;
  }

  newReply(int commentid,int userid,String name,String text) async{
    addReply(commentid,userid, name, text).then((value){
      setState(() {
        Reply reply=value;
        replyList.add(reply);
      });
    });
  }

  Future<Reply> addReply(int comment_id,int user_id,String username,String content) async{
    var res = await http.post(Api.ADD_REPLY_URL,
        body: {
          'Commentid' : comment_id.toString(),
          'Userid' : user_id.toString(),
          'Username' : username,
          'Text' : content,
          'Likecount' : "0",
        });
    print("Add success");
    var body=jsonDecode(res.body);
    print(body);
    var data=body['data'];
    Reply reply=new Reply(data['Replyid'],data['Commentid'],data['Userid'],data['Username'],data['Text'],data['Likecount'],data['Createdate']);
    return reply;
  }

  List<Widget> getDelegate() {
    List<Widget> _generalDelegates = List<Widget>();
    for (var i = 0; i < replyList.length; i++) {
      Reply reply=replyList[i];
      _generalDelegates.add(ReplyContent(reply: reply,));
    }
    return _generalDelegates;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
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

  insertFollower(int userid,int followerid) async{
    var res= await http.post(Api.ADD_FOLLOWER_URL,
    body: {
      "Userid" : userid.toString(),
      "Followerid" : followerid.toString(),
    });
    if(res.statusCode ==200){
      var body=jsonDecode(res.body);
      Map map=body['data'];
      Following following=Following.fromJson(map);
      SQLiteDbProvider.db.insertFollowing(following);
    }
  }

  deleteFollower(int userid,int followerid) async{
    var res = await http.delete(Api.DELETE_FOLLOWER_URL+userid.toString()+"/"+followerid.toString());
    if(res.statusCode ==200){
      print('delete success');
      int result= await SQLiteDbProvider.db.deleteFollowingById(userid);
      print(result.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply'),
      ),
      body: !isLoading? Column(
        children: [
          Flexible(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      profileContent(),
                      Container(
                        padding: EdgeInsets.only(left: 70.0,right: 10.0,bottom: 10.0),
                        child: Text(comment.text,
                          style: TextStyle(
                            color: Colors.black,
                            height: 1.5,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5.0,left: 70.0,right: 15.0,bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: commentLikeCount !=0? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: (){},
                                    child: Container(
                                      height: 25.0,width: 25.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100.0),
                                        image: DecorationImage(
                                          image: AssetImage('assets/panda.jpg'),
                                          fit: BoxFit.cover,
                                        )
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.0,),
                                  commentLikeCount>=2? GestureDetector(
                                    onTap: (){},
                                    child: Container(
                                      height: 25.0,width: 25.0,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100.0),
                                          image: DecorationImage(
                                            image: AssetImage('assets/minion.jpg'),
                                            fit: BoxFit.cover,
                                          )
                                      ),
                                    ),
                                  ) : Container(),
                                  Container(
                                    height: 25.0,
                                    padding: EdgeInsets.only(left: 5.0,right: 5.0,),
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => LikedProfile())
                                              );
                                            });
                                          },
                                          child: Center(
                                            child: Text('$commentLikeCount people like',
                                              style: TextStyle(
                                                //color: Colors.grey,
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => LikedProfile())
                                              );
                                            });
                                          },
                                          child: Icon(Icons.arrow_forward_ios,size: 10.0,color: Colors.grey,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ): Container(),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                      child: Icon(Icons.thumb_up,color: isLiked? Colors.blue:Colors.grey,size: 15.0,),
                                    onTap: (){
                                        setState(() {
                                          if(isLiked){
                                            isLiked=false;
                                            commentLikeCount=commentLikeCount-1;
                                            deleteLikeRecord(userID, comment.commentID);
                                          }else{
                                            isLiked=true;
                                            commentLikeCount=commentLikeCount+1;
                                            insertLikeRecord(userID, comment.commentID);
                                          }
                                          updateCommentLike(comment.commentID,commentLikeCount);
                                        });
                                    },
                                  ),
                                  SizedBox(width: 3.0,),
                                  Text(commentLikeCount.toString(),style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        child: Divider(height: 5.0,color: Colors.grey,),
                      ),
                      replyList.length!=0? Container(
                        margin: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 10.0),
                        child: Row(
                          children: <Widget>[
                            Container(width: 3.0,
                            height: 25.0,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 20.0,),
                            Text('All Reply',),
                          ],
                        ),
                      ) : Container(),
                      //_buildReplyMessage(),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    replyList.length!=0 ? getDelegate() :
                    [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        margin: EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.message,size: 50.0,color: Colors.grey,),
                              Text('No reply yet...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: _buildInput(),
          ),
          isShowSticker ? buildSticker() : Container(),
        ],
      )
      : Center(
        child: CircularProgressIndicator(),
    ),
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

    return Container(
        height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    hintText: "Enter Reply...",
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
                  focusNode: focusNode,
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
            isWriting? Container() : Stack(
              children: <Widget>[
                new IconButton(icon: Icon(Icons.thumb_up,color: isLiked? Colors.blue:Colors.grey,),
                  onPressed: () {
                    setState(() {
                      if(isLiked){
                        isLiked=false;
                        commentLikeCount=commentLikeCount-1;
                        deleteLikeRecord(userID, commentID);
                      }else{
                        isLiked=true;
                        commentLikeCount=commentLikeCount+1;
                        insertLikeRecord(userID, commentID);
                      }
                      updateCommentLike(commentID, commentLikeCount);
                    });
                  },),
                commentLikeCount != 0 ? new Positioned(
                  right: 0,
                  top: 5,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$commentLikeCount',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ) : new Container(),
              ],
            ),
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
                      isWritingTo(false);
                      if(userID!=0){
                        newReply(commentID,userID,username,_textEditingController.text);
                        _textEditingController.clear();
                        hideStickerContainer();
                        hideKeyboard();
                      }else{
                        _textEditingController.clear();
                        hideStickerContainer();
                        hideKeyboard();
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

  Widget _buildListMessage() {
    //final comments = List<Response>.from(_comments);
    // comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // if more comments possibly still available
    // add fake response to commenrs so it will be rendered as Load more button.
    // only loggedin user can load previous comments.
    // final user = AppModel.of(context).currentUser;
    // if (_cursor != null && user != null && !user.isAnonymous) {
    // final resp = Response();
    // resp.type = "LOADMORE";
    // comments.insertAll(0, [resp]);
    //}

    return Column(
      children: <Widget>[
        Container(
          child: ListView.builder(
            // reverse: true,
              controller: _scrollController,
              //itemCount: comments.length,
              itemCount: 1,
              itemBuilder: (ctx, index) {
                //return _buildItem(comments[index]);
                //return _commentList();
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0,),
                            image: DecorationImage(
                              image: AssetImage('assets/panda.jpg'),
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                      title: Text('Sai Thein Han'),
                      subtitle: Container(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onLongPress: (){
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc){
                                      return Container(
                                        child: new Wrap(
                                          children: <Widget>[
                                            new ListTile(
                                                leading: new Icon(Icons.reply),
                                                title: new Text('Reply'),
                                                onTap: () => {}
                                            ),
                                            new ListTile(
                                              leading: new Icon(Icons.delete),
                                              title: new Text('Delete'),
                                              onTap: () => {},
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                );
                              },
                              child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
                                style: TextStyle(
                                  color: Colors.black,
                                  height: 1.3,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5.0,),
                              child: Row(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Icon(Icons.thumb_up,size: 15.0,color: Colors.grey,),
                                          SizedBox(width: 5.0,),
                                          Text('1000',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10.0,),
                                      GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) => ReplyPage())
                                            );
                                          });
                                        },
                                        child: Container(
                                          height: 20.0,
                                          // width: 80.0,
                                          padding: EdgeInsets.only(left: 5.0,right: 5.0),
                                          decoration: BoxDecoration(
                                            //color: Colors.black12,
                                            borderRadius: BorderRadius.circular(10.0,),
                                          ),
                                          child: Center(
                                            child: Text('5 Reply',
                                              style: TextStyle(
                                                //color: Colors.grey,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.0,),
                                      Text('3 min ago ',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 5.0,color: Colors.grey,),
                  ],
                );
              }),
        ),
        _buildReplyMessage(),
      ],
    );
  }

  Widget _buildReplyMessage(){
    return Column(
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
                child: Text('Sai Aung'),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.thumb_up,color: Colors.grey,size: 15.0,),
                    SizedBox(width: 3.0,),
                    Text('100',style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                  ],
                ),
              ),
            ],
          ),
          subtitle: Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onLongPress: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc){
                          return Container(
                            child: new Wrap(
                              children: <Widget>[
                                new ListTile(
                                    leading: new Icon(Icons.reply),
                                    title: new Text('Reply'),
                                    onTap: () => {}
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.delete),
                                  title: new Text('Delete'),
                                  onTap: () => {},
                                ),
                              ],
                            ),
                          );
                        }
                    );
                  },
                  child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
                    style: TextStyle(
                      color: Colors.black,
                      height: 1.5,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('1 min ago ',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => ReplyPage())
                                );
                              });
                            },
                            child: Container(
                              height: 20.0,
                              // width: 80.0,
                              padding: EdgeInsets.only(left: 5.0,right: 5.0),
                              decoration: BoxDecoration(
                                //color: Colors.black12,
                                borderRadius: BorderRadius.circular(10.0,),
                              ),
                              child: Center(
                                child: Text('Reply',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 70.0,right: 10.0),
          color: Colors.grey,
          height: 0.5,
        ),
      ],
    );
  }

  Container profileContent() {
    return  Container(
      height: 50.0,
      //width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                });
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        image: DecorationImage(
                          image: AssetImage('assets/minion.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width*(60/100),
              //width: MediaQuery.of(context).size.width*(90/100),
              padding: EdgeInsets.only(left: 8.0,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                      });
                    },
                    child: Container(
                      child: Text(comment.userName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 18.0,
                    width: 120.0,
                    padding: EdgeInsets.only(top: 5.0,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(date,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: (comment.userID!= userID)? GestureDetector(
              onTap: (){
                setState(() {
                    if(isFollowed){
                      isFollowed=false;
                      deleteFollower(comment.userID,userID);
                    }else{
                      isFollowed=true;
                      insertFollower(comment.userID,userID);
                    }
                });
              },
              child: Container(
                height: 20.0,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 20.0,
                      padding: EdgeInsets.only(left: 5.0,right: 5.0),
                      decoration: BoxDecoration(
                        color: isFollowed? Colors.white : Colors.blue,
                        borderRadius: BorderRadius.circular(5.0,),
                        border: Border.all(
                            color: isFollowed? Colors.black12 : Colors.blue,
                            width: 1.0
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              //width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: isFollowed? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Icon(isFollowed? Icons.check: Icons.add,
                                color: isFollowed? Colors.white : Colors.blue,size: 12.0,),
                            ),
                            SizedBox(width: 5.0,),
                            Text('Follow',
                              style: TextStyle(
                                color: isFollowed? Colors.grey : Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : Container(),
          ),
        ],
      ),
    );
  }
}

class ReplyContent extends StatefulWidget {
  final Reply reply;
  ReplyContent({Key key,this.reply});

  @override
  _ReplyContentState createState() => _ReplyContentState();
}

class _ReplyContentState extends State<ReplyContent> {

  Reply reply;

  int likeCount=0;
  int userID=0;

  bool isLiked=false;

  List<User> userList=[];

  String date;

  DateTime created;
  DateTime now=DateTime.now();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reply=widget.reply;
    likeCount=reply.likeCount;

    checkUser().then((value){
      userList=value;
      if(userList.length != 0){
        userID=userList[0].userID;
        checkLike(userID, reply.replyID).then((value){
            isLiked=value;
        });
      }
    });

    var arr= reply.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    date=Check().checkDate(created, now);
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
          'Field' : "reply",
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

  removeReply(int id) async{
    var response= await http.delete(Api.DELETE_REPLY_URL+id.toString());
    if(response.statusCode ==200){
      print("Delete comment success");
    }
  }

  updateReplyLike(int replyID, int likeCount) async{
    var response = await http.put(Api.UPDATE_REPLY_LIKE_URL,
        body: {
          'Replyid' : replyID.toString(),
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
          'Field' : "reply",
        });
    if(response.statusCode ==200){
      print("record success");
    }
  }

  deleteLikeRecord(int user_id,int post_id) async{
    var response= await http.delete(Api.DELETELIKE_URL+user_id.toString()+"/"+post_id.toString()+"/"+"reply");
    if(response.statusCode ==200){
      print('delete success');
    }
  }

  deleteReplyLikeRecord(int id) async{
    var res = await http.delete(Api.DELETE_REPLY_LIKE_URL+id.toString()+"/"+"reply");
    if(res.statusCode ==200){
      print("delete success");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: Text(reply.userName),
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
                                deleteLikeRecord(userID,reply.replyID);
                              }else{
                                isLiked=true;
                                likeCount=likeCount+1;
                                insertLikeRecord(userID, reply.replyID);
                              }
                              updateReplyLike(reply.replyID,likeCount);
                            });
                      },),
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
                      if(reply.userID == userID){
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext bc){
                              return Container(
                                child: new Wrap(
                                  children: <Widget>[
                                    new ListTile(
                                        leading: new Icon(Icons.reply),
                                        title: new Text('Reply'),
                                        onTap: () => {}
                                    ),
                                    new ListTile(
                                      leading: new Icon(Icons.delete),
                                      title: new Text('Delete'),
                                      onTap: () {
                                        setState(() {
                                          removeReply(reply.replyID);
                                          deleteReplyLikeRecord(reply.replyID);
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
                    child: Text(reply.text,
                      style: TextStyle(
                        color: Colors.black,
                        height: 1.5,
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(date,
                              style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.black
                              ),
                            ),
                            SizedBox(width: 10.0,),
                            GestureDetector(
                              onTap: (){
                                setState(() {

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
                                  child: Text('Reply',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 70.0,right: 10.0),
            color: Colors.grey,
            height: 0.5,
          ),
        ],
      ),
    );
  }
}

