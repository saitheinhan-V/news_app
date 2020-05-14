import 'package:flutter/material.dart';
import 'package:news/models/check_time.dart';
import 'package:news/home/post/moment_image.dart';
import 'package:news/profile/recommend_user_profile.dart';
import 'package:news/search/search_people.dart';
import 'package:news/profile/user_profile_page.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/home/comment_reply/reply_page.dart';
import 'package:news/home/comment_reply/liked_profile_list.dart';

class MomentPageDetails extends StatefulWidget {

  final List image;
  final bool follow;
  MomentPageDetails({Key key,this.image,this.follow}):super(key: key);

  @override
  _MomentPageDetailsState createState() => _MomentPageDetailsState();
}

class _MomentPageDetailsState extends State<MomentPageDetails> {

  List imageList=[];
  DateTime now= DateTime.now();
  DateTime created=DateTime(2020,04,15,11,10);
  var date;
  bool isFollowed=false;
  var height=0;
  var length;
  int count=100;
  TextEditingController _textEditingController=TextEditingController();
  FocusNode focusNode=FocusNode();

  List<Widget> generalComment=List<Widget>();
  List<Widget> generalWidget=List<Widget>();

  var allCommentList=[];
  var oldCommentList=[];
  var newCommentList=[];

  bool isExpanded=false;
  bool isLiked=false;
  bool isShowed=false;
  bool first=true;
  bool isWriting=false;
  bool isShowSticker=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageList=widget.image;
    isFollowed=widget.follow;
    print(imageList.length.toString());
    date=Check().checkDate(created, now);
    height=Check().checkImage(imageList);
    addComment();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    newCommentList.clear();
    oldCommentList.clear();
  }

  void addComment(){
    for(int i=0;i<allCommentList.length;i++){
      oldCommentList.add(allCommentList[i]);
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

  List<Widget> getWidget() {

    //generalWidget.add(text());

    return generalWidget;
  }

  List<Widget> getOldComment(){
    for(int i=0;i<oldCommentList.length;i++){
      generalComment.add(comment());
    }
    return generalComment;
  }

  List<Widget> getNewComment(){
    List<Widget> general=List<Widget>();
    for(var i=0;i<newCommentList.length;i++){
      general.add(comment());
      allCommentList.add(newCommentList[i]);
    }
    return general;
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
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        profile(),
                        (isShowed)? Container(
                          height: 200.0,
                          color: Colors.black12,
                          child: Visibility(
                              visible: true,
                              child: RelevantRecommendation()),
                        ) : Container(),
                        _textContent(),
                        _textContent(),
                        _textContent(),
                        _textContent(),
                        _textContent(),
                        height==0 ? Container() : MomentImage(height: height,image: imageList,),
                        //_imageContent(),
                        _textContent(),
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
                                          Text('1000',style: TextStyle(color: Colors.grey,fontSize: 12.0),)
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
                                        if(isLiked){
                                          isLiked=false;
                                          count=count-1;
                                        }else{
                                          isLiked=true;
                                          count=count+1;
                                        }
                                      });
                                    },
                                    shape: StadiumBorder(),
                                    borderSide: BorderSide(color: isLiked? Colors.blue: Colors.black54,width: 1.0,style: BorderStyle.solid),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(Icons.thumb_up,size: 15.0,color: isLiked? Colors.blue:Colors.grey,),
                                        Text(count.toString(),style: TextStyle(color: isLiked? Colors.blue:Colors.grey,fontSize: 12.0),)
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
                  oldCommentList.length>0 || newCommentList.length>0? SliverList(
                    delegate: SliverChildListDelegate(
                      getOldComment(),
                    ),
                  ) : SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Container(
                            height: 50.0,
                            child: Center(
                              child: Text('No comment...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
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
                      child: Text('Sai Thein Han',
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
                        Text(date.toString(),
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
            child: GestureDetector(
              onTap: (){
                setState(() {
                  if(first){
                    if(isFollowed){
                      isShowed=false;
                      isFollowed=false;
                      isExpanded=false;
                      //totalHeight=totalHeight-recommendHeight;
                    }else{
                      isFollowed=true;
                      isExpanded=true;
                      isShowed=true;
                      //totalHeight=totalHeight+recommendHeight;
                    }
                  }else{
                    isShowed=false;
                    isFollowed=false;
                    isExpanded=false;
                    first=true;
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
            ),
          ),
        ],
      ),
    );
  }



  List<Widget> getDelegate() {
    List<Widget> _generalDelegates = List<Widget>();
    _generalDelegates.clear();
    for (var i = 0; i < imageList.length; i++) {
      //_generalDelegates.add(_imageContent(imageList[i]));
      _generalDelegates.add(_textContent());
    }
    return _generalDelegates;
  }


  Widget _imageNoneContent() {
    return Container(
      height: 400.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
      //child: Image.asset(imageList,fit: BoxFit.cover,),
      //child: Image.network(imageList,fit: BoxFit.cover,),
      child: GridView.count(
        primary: false,
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        children: List<Widget>.generate(
            9, (index){
          return GridTile(
            child: Container(
              //width: 100.0,
              //child: Image.network(imageList[index],fit: BoxFit.fill,),
              child: Image.asset('assets/panda.jpg',fit: BoxFit.cover,),
            ),
          );
        }
        ),
      ),
    );
  }

  Widget _textContent() {
    return Container(
      //height: 100.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
      child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
        style: TextStyle(
          color: Colors.black,
          height: 1.5,
          fontSize: 15.0,
        ),
        textAlign: TextAlign.justify,
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
          //border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
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
                count != 0 ? new Positioned(
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
                      '$count',
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
                      if(isLiked){
                        isLiked=false;
                        count=count-1;
                      }else{
                        isLiked=true;
                        count=count+1;
                      }
                    });
                  },),
                count != 0 ? new Positioned(
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
                      '$count',
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
                      //comment.add(_textEditingController.text);
                      isWritingTo(false);
                      _textEditingController.clear();
                      hideStickerContainer();
                      hideKeyboard();
                      newCommentList.add('one');
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
