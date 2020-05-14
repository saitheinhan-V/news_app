import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:news/home/comment_reply/liked_profile_list.dart';
import 'package:news/home/comment_reply//reply_page.dart';
import 'package:emoji_picker/emoji_picker.dart';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  Future<bool> _onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }
  bool _loading=false;
  bool _posting = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> comment=["sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han","sai","thein","han",];

  bool isShowSticker=false;
  bool isWriting=false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment'),
      ),
      body: Column(
        children: [
          Flexible(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildListMessage(),

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

  removeComment(index){
    setState(() {
      comment.removeAt(index);
    });
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

    return Container(
      height: MediaQuery.of(context).size.height*(80/100),
      child: ListView.builder(
        // reverse: true,
          controller: _scrollController,
          //itemCount: comments.length,
          itemCount: comment.length,
          itemBuilder: (ctx, index) {
            //return _buildItem(comments[index]);
            //return _commentList();
            return Dismissible(
              onDismissed: (direction){
                //var company = companies[index];
                //showSnackBar(context, company ,index);
                removeComment(index);
              },
              key: Key(comment[index]),
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
                                              removeComment(index);
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
                                          Text('2',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 8.0,),
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
                                      SizedBox(width: 8.0,),
                                      Text('3 min ago ',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      SizedBox(width: 8.0,),
                                      Container(
                                        height: 25.0,
                                        padding: EdgeInsets.only(left: 5.0,right: 5.0,),
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
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
                                                child: Text('2 people like',
                                                  style: TextStyle(
                                                    //color: Colors.grey,
                                                    fontSize: 12.0,
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
                                              child: Icon(Icons.arrow_forward_ios,size: 15.0,color: Colors.grey,),
                                            ),
                                          ],
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
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Divider(height: 5.0,color: Colors.grey,),
                  ),
                ],
              ),
            );
          }),
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

  Widget _buildLoading() {
    return Positioned(
      child: _loading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
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
            border: Border(top: BorderSide(color: Colors.blue, width: 0.5)),
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
                        maxLines: 1,
                        style: TextStyle(fontSize: 15.0),
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(10.0),
                          filled: true,
                          hintText: "Enter Comment...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        focusNode: _focusNode,
                      ),
                    ),
                  ),
                  Material(
                    child: new Container(
                      child: new IconButton(
                        icon: new Icon(Icons.insert_emoticon),
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
                        color: Colors.blueGrey,
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
                              comment.add(_textEditingController.text);
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

  Container _commentList() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0,),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
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
              Text('Sai Thein Han'),
            ],
          ),
          Expanded(
            child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document',
              style: TextStyle(
                color: Colors.black,
                height: 1.3,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

}