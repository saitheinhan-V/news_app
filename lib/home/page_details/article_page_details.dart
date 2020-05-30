import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/comment_reply/comment_content.dart';
import 'package:news/models/article.dart';
import 'package:news/models/check_time.dart';
import 'package:news/home/post/moment_image.dart';
import 'package:news/models/comment.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/models/user.dart';
import 'package:news/profile/recommend_user_profile.dart';
import 'package:news/search/search_people.dart';
import 'package:news/profile/user_profile_page.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/home/comment_reply/reply_page.dart';
import 'package:news/home/comment_reply/liked_profile_list.dart';
import 'package:http/http.dart' as http;

class ArticlePageDetails extends StatefulWidget {

  final Article article;
  final int commentCount;
  ArticlePageDetails({Key key,this.article,this.commentCount}):super(key: key);

  @override
  _ArticlePageDetailsState createState() => _ArticlePageDetailsState();
}

class _ArticlePageDetailsState extends State<ArticlePageDetails> {

  List imageList=[];
  DateTime now= DateTime.now();
  DateTime created;
  var date;
  var height=0;
  var length;

  int count=100;
  int userID=0;
  int like=0;
  int view=0;
  int commentCount=0;

  String name;
  String username;

  TextEditingController _textEditingController=TextEditingController();
  FocusNode focusNode=FocusNode();

  List<Widget> generalComment=List<Widget>();
  List<Widget> generalWidget=List<Widget>();
  List<User> userList=List<User>();
  List<Comment> oldCommentList=[];
  List<Comment> newCommentList=[];

  bool isExpanded=false;
  bool isFollowed=false;
  bool isLiked=false;
  bool isShowed=false;
  bool isLoading=true;
  bool first=true;
  bool isWriting=false;
  bool isShowSticker=false;

  Following following;
  Article article;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    article=widget.article;
    commentCount=widget.commentCount;
    like=article.likeCount;
    view=article.viewCount;
    var arr= article.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));
    date=Check().checkDate(created, now);
    //addComment();

    checkUser().then((value){
      setState(() {
        userList=value;
        if(userList.length != 0){
          userID=userList[0].userID;
          username=userList[0].userName;
          checkLike(userID, article.articlePostID).then((value){
            setState(() {
              isLiked=value;
            });
          });
        }
      });
    });

    getFollowing(article.userID).then((value){
      setState(() {
        following=value;
        if(following==null){
          isFollowed=false;
        }else{
          isFollowed=true;
        }
      });
    });

    getAllComment(article.articlePostID).then((value){
      setState(() {
        oldCommentList=value;
        print('Old comment length======'+oldCommentList.length.toString());
      });
    });

    getUserInfo(article.userID).then((value){
      setState(() {
        following=value;
        name=following.userName;
        isLoading=false;
      });
    });
  }

  updateArticleLike(int articleID, int likeCount) async{
    var response = await http.put(Api.UPDATE_ARTICLE_LIKE_URL,
        body: {
          'Articlepostid' : articleID.toString(),
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
          'Field' : "article",
        });
    if(response.statusCode ==200){
      print("record success");
    }
  }

  deleteLikeRecord(int user_id,int post_id) async{
    var response= await http.delete(Api.DELETELIKE_URL+user_id.toString()+"/"+post_id.toString()+"/"+"article");
    if(response.statusCode ==200){
      print('delete success');
    }
  }

//  deleteCommentLikeRecord(int id) async{
//    var res = await http.delete(Api.DELETE_COMMENT_LIKE_RECORD_URL+id.toString()+"/"+"comment");
//    if(res.statusCode ==200){
//      print("delete success");
//    }
//  }

  Future<Following> getFollowing(int id) async{
    Following following= await SQLiteDbProvider.db.getFollowingById(id);
    return following;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<Following> getUserInfo(int id) async{
    var res=await http.post(Api.USER_INFO_URL,
        body: {
          'Userid' : id.toString(),
        });
    var data=jsonDecode(res.body);
    Map userMap=data['data'];
    Following following=Following.fromJson(userMap);
    return following;
  }

  Future<bool> checkLike(int user_id, int post_id) async{
    bool checked;
    var res= await http.post(Api.LIKE_CHECK_URL,
        body: {
          'Userid' : user_id.toString(),
          'Postid' : post_id.toString(),
          'Field' : "article",
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    newCommentList.clear();
    oldCommentList.clear();
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

  Future<List<Comment>> getAllComment(int id) async{
    List<Comment> comments=[];
    var res= await http.post(Api.GET_COMMENT_URL,
        body: {
          'Postid' : id.toString(),
          'Field' : "article",
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

  newComment(int userid,String name,int articleid,String text) async{
    addComment(userid,name, articleid, text).then((value){
      setState(() {
        Comment comment=value;
        newCommentList.add(comment);
        print("New comment list length====="+newCommentList.length.toString());
      });
    });
  }

  Future<Comment> addComment(int user_id,String name,int article_id,String content) async{
    var res = await http.post(Api.ADD_COMMENT_URL,
        body: {
          'Userid' : user_id.toString(),
          'Postid' : article_id.toString(),
          'Field' : "article",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomSearchPeople()));
            },
          ),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          )
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading? Center(
        child: CircularProgressIndicator(),
      ) : Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Container(
                            //height: 80.0,
                            // width: MediaQuery.of(context).size.width*(90/100),
                            padding: EdgeInsets.only(top: 5.0,left: 10.0,right: 10.0,bottom: 10.0,),
                            child: Text(article.caption,
                              style: TextStyle(
                                color: Colors.black,
                                height: 1.5,
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          profile(),
                          (isShowed)? Container(
                            height: 200.0,
                            color: Colors.black12,
                            child: Visibility(
                                visible: true,
                                child: RelevantRecommendation()),
                          ) : Container(),
                          Container(
                            child: Html(
                              data: article.content,
                              style: {
                                "img" : Style(
                                  height: 220.0,
                                  width: double.infinity,
                                ),
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: ButtonTheme(
                                    height: 30.0,
                                    child: Center(
                                      child: OutlineButton(
                                        onPressed: (){
                                          setState(() {

                                          });
                                        },
                                        borderSide: BorderSide(color: Colors.black54,width: 1.0,style: BorderStyle.solid),
                                        shape: StadiumBorder(),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Icon(Icons.comment,size: 15.0,color: Colors.grey,),
                                            Text(commentCount.toString(),style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.0,),
                                Expanded(
                                  flex: 1,
                                  child: ButtonTheme(
                                    minWidth: 60.0,
                                    height: 30.0,
                                    child: OutlineButton(
                                      onPressed: (){
                                        setState(() {
                                          if(userID !=0){
                                            if(isLiked){
                                              isLiked=false;
                                              like=like-1;
                                              deleteLikeRecord(userID, article.articlePostID);
                                            }else{
                                              isLiked=true;
                                              like=like+1;
                                              insertLikeRecord(userID, article.articlePostID);
                                            }
                                            updateArticleLike(article.articlePostID, like);
                                          }else{

                                          }

                                        });
                                      },
                                      shape: StadiumBorder(),
                                      borderSide: BorderSide(color: isLiked? Colors.blue: Colors.black54,width: 1.0,style: BorderStyle.solid),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Icon(Icons.thumb_up,size: 15.0,color: isLiked? Colors.blue:Colors.grey,),
                                          Text(like.toString(),style: TextStyle(color: isLiked? Colors.blue:Colors.grey,fontSize: 12.0),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.0,),
                                Expanded(
                                  flex: 1,
                                  child: ButtonTheme(
                                    minWidth: 60.0,
                                    height: 30.0,
                                    child: OutlineButton(
                                      onPressed: (){

                                      },
                                      shape: StadiumBorder(),
                                      borderSide: BorderSide(color: Colors.black54,width: 1.0,style: BorderStyle.solid),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Icon(Icons.report_problem,size: 15.0,color: Colors.grey,),
                                          Text('report',style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.0,),
                                Expanded(
                                  flex: 1,
                                  child: ButtonTheme(
                                    height: 30.0,
                                    child: OutlineButton(
                                      onPressed: (){
                                        setState(() {

                                        });
                                      },
                                      borderSide: BorderSide(color: Colors.black54,width: 1.0,style: BorderStyle.solid),
                                      shape: StadiumBorder(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Icon(Icons.share,size: 15.0,color: Colors.grey,),
                                          Text('share',style: TextStyle(color: Colors.grey,fontSize: 12.0),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                    ),
                  ),
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
                            height: 200.0,
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
                        Container()
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
          ],
        ),
      ),
    );
  }

  Widget profile(){
    return Container(
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
              //padding: EdgeInsets.only(left: 8.0,right: 5.0,),
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
                      child: Text(name,
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
            flex: 4,
            child: (article.userID != userID && userID !=0)? GestureDetector(
              onTap: (){
                setState(() {
                  if(first){
                    if(isFollowed){
                      isShowed=false;
                      isFollowed=false;
                      isExpanded=false;
                      deleteFollower(article.userID,userID);
                      //totalHeight=totalHeight-recommendHeight;
                    }else{
                      isFollowed=true;
                      isExpanded=true;
                      isShowed=true;
                      insertFollower(article.userID,userID);
                      //totalHeight=totalHeight+recommendHeight;
                    }
                  }else{
                    isShowed=false;
                    isFollowed=false;
                    isExpanded=false;
                    first=true;
                    deleteFollower(article.userID,userID);
                    //totalHeight=totalHeight-recommendHeight;
                  }

                });
              },
              child: Container(
                height: 20.0,
                //padding: EdgeInsets.only(right: .0),
                //width: MediaQuery.of(context).size.width*(10/100),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    SizedBox(
                      width: 3.0,
                    ),
                    isFollowed? GestureDetector(
                        onTap: (){
                          setState(() {
                            if(isFollowed){
                              if(isExpanded){
                                isExpanded=false;
                                isShowed=false;
                                //totalHeight=totalHeight-recommendHeight;
                              }else{
                                isExpanded=true;
                                isShowed=true;
                                //totalHeight=totalHeight+recommendHeight;
                              }
                            }
                            if(isFollowed && !isExpanded){
                              first=false;
                            }else{
                              first=true;
                            }
                          });
                        },
                        child: Container(
                          height: 20.0,width: 20.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(isExpanded? Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,
                              size: 18.0,
                              color: Colors.grey,),
                          ),
                        ))
                        :
                    Container(),
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
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    TextField(
                      onTap: (){
                        hideStickerContainer();
                      },
                      onChanged: (val){
                        (val.length>0 && val.trim()!="")? //isWriting=true: isWriting=false;
                        isWritingTo(true) : isWritingTo(false);
                      },
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
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
                      focusNode: focusNode,
                      autofocus: false,
                    ),
                    IconButton(
                      icon: Icon(Icons.tag_faces,color: isShowSticker? Colors.blue:Colors.grey,size: 20.0,),
                      onPressed: (){
                        if(!isShowSticker){
                          hideKeyboard();
                          showStickerContainer();
                        }else{
                          showKeyboard();
                          hideStickerContainer();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            isWriting? Container() : Stack(
              children: <Widget>[
                new IconButton(icon: Icon(Icons.comment,color: Colors.grey,),
                  onPressed: () {
                    setState(() {

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage()));
                    });
                  },
                ),
                commentCount != 0 ? new Positioned(
                  right: 3,
                  top: 5,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$commentCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ) : new Container(),
              ],
            ),
            isWriting? Container() : IconButton(
              icon: Icon(Icons.favorite_border,color: Colors.grey,),
              onPressed: (){

              },
            ),
            isWriting? Container() : Stack(
              children: <Widget>[
                new IconButton(icon: Icon(Icons.thumb_up,color: isLiked? Colors.blue:Colors.grey,),
                  onPressed: () {
                    setState(() {
                      if(userID !=0) {
                        if(isLiked){
                          isLiked=false;
                          like=like-1;
                          deleteLikeRecord(userID, article.articlePostID);
                        }else{
                          isLiked=true;
                          like=like+1;
                          insertLikeRecord(userID, article.articlePostID);
                        }
                        updateArticleLike(article.articlePostID, like);
                      }else{
                        //write something
                      }

                    });
                  },),
                like != 0 ? new Positioned(
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
                      like.toString(),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 8,
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
                      hideStickerContainer();
                      hideKeyboard();
                      if(userID!=0){
                        newComment(userID,username,article.articlePostID,_textEditingController.text);
                        _textEditingController.text='';
                        focusNode.unfocus();
                      }else{
                        _textEditingController.text='';
                        focusNode.unfocus();
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

  Widget comment(){
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
                child: Text('Sai Thein Han'),
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
                                  onTap: (){
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => ReplyPage())
                                    );
                                  },
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.delete),
                                  title: new Text('Delete'),
                                  onTap: (){
                                    //removeComment(index);
                                    Navigator.pop(context);
                                  },
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
                  padding: EdgeInsets.only(top: 8.0,),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: <Widget>[
                            Text('01-05 1:00',
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
                                  child: RichText(
                                    text: TextSpan(
                                        text: '1000',
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
                      Expanded(
                        flex: 6,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            GestureDetector(
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
                            ),
                            Container(
                              height: 25.0,
                              padding: EdgeInsets.only(left: 2.0,right: 0.0,),
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
                                      child: Text('2000 people like',
                                        style: TextStyle(
                                          color: Colors.black,
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
    );
  }




}
