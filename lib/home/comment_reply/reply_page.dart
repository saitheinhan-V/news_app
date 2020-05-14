import 'package:flutter/material.dart';
import 'package:news/home/comment_reply//liked_profile_list.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/profile/user_profile_page.dart';

class ReplyPage extends StatefulWidget {
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
  bool isLiked=false;
  int count=100;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply'),
      ),
      body: Column(
        children: [
          Flexible(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      profileContent(),
                      Container(
                        padding: EdgeInsets.only(left: 70.0,right: 10.0,bottom: 5.0),
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
                        padding: EdgeInsets.only(top: 5.0,left: 70.0,right: 15.0,bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Row(
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
                                            child: Text('20 people like',
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
                              ),
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
                                            count=count-1;
                                          }else{
                                            isLiked=true;
                                            count=count+1;
                                          }
                                        });
                                    },
                                  ),
                                  SizedBox(width: 3.0,),
                                  Text(count.toString(),style: TextStyle(color: Colors.grey,fontSize: 12.0),)
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
                      Container(
                        padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 10.0),
                        child: Row(
                          children: <Widget>[
                            Container(width: 3.0,
                            height: 25.0,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5.0,),
                            Text('All Reply'),
                          ],
                        ),
                      ),
                      _buildReplyMessage(),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    getDelegate(),
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
    );
  }

  List<Widget> getDelegate() {
    List<Widget> _generalDelegates = List<Widget>();
    //_generalDelegates.clear();
    for (var i = 0; i < 5; i++) {
      _generalDelegates.add(_buildReplyMessage());
    }
    return _generalDelegates;
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
                      //newCommentList.add('one');
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
                        Text('3 hours ago',
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
            child: GestureDetector(
              onTap: (){
                setState(() {
                    if(isFollowed){
                      isFollowed=false;
                    }else{
                      isFollowed=true;
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
