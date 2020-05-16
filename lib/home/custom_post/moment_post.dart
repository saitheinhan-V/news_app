import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/models/token.dart';
import 'package:news/models/user.dart';
import 'package:news/database/database.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MomentPost extends StatefulWidget {
  @override
  _MomentPostState createState() => _MomentPostState();
}

class _MomentPostState extends State<MomentPost> {

  TextEditingController textEditingController;
  FocusNode focusNode;
  ProgressDialog progressDialog;

  int count=0;
  int userId=0;
  bool isShowSticker=false;
  bool isShowKeyboard=true;
  bool isWriting=false;
  bool first=true;

  List<User> userList= List<User>();
  List<Token> tokenList=List<Token>();
  List<Asset> images = List<Asset>();
  String _error;
  String link='';
  String userToken='';
  List<Widget> list=[];

  List<All> allList=[];
  int listLength=0;
  int maxImages=9;
  int index=0;
  int like=0;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController=new TextEditingController();
    focusNode=new FocusNode();
    list=List<Widget>()..add(buildAddButton());
    count=0;
    setState(() {
      checkUser().then((value){
        userList=value;
        if(userList.length != 0){
          userId=userList[0].userID;
        }
      });

      checkToken().then((value){
        setState(() {
          tokenList= value;
          print("Token length================="+tokenList.length.toString());
          if(tokenList.length !=0){
            userToken=tokenList[0].value;
            print(userToken);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    allList.clear();
    list.clear();
    images.clear();
    focusNode.unfocus();
    focusNode.dispose();
  }

  Future<List<Token>> checkToken() async{
    Future<List<Token>> list=SQLiteDbProvider.db.getToken();
    List<Token> tokenLists= await list;
    return tokenLists;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<String> uploadImage(List<Asset> assets) async{
    String link='';
    String name='';
    for(int i=0;i<assets.length;i++){
      name=name+ assets[i].name;
    }
    print(name+ "=====File image====");
    var uploadUrl="http://localhost:3000//api/auth/multipleupload";
    var response= await http.post(uploadUrl,body: {
      "files" : name
    });
    if(response.statusCode == 200){
      var data=jsonDecode(response.body);
      link=data['link'];
    }
    return link;
  }

  Future<bool> _onBackPressed(){
    return (isWriting || list.length>1)? showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return AlertDialog(
            title: Text('Warning'),
            content: Text('Are you sure want to exit!'),
            actions: <Widget>[
              new FlatButton(
                onPressed: (){
                  Navigator.pop(c);
                },
                child: Text('No'),
              ),
              new FlatButton(
                onPressed: (){
                  focusNode.unfocus();
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: Text('Yes'),
              ),
            ],
          );
        }
    ): Navigator.pop(context);
  }

  newMomentPost(int user_id,int user_post_id,String caption,String image,int like) async{
    var insertUrl="http://192.168.0.110:3000//api/momentpost";
    var response=await http.post(insertUrl,body: {
      "Userid" : user_id.toString(),
      "Userpostid" : user_post_id.toString(),
      "Caption" : caption,
      "Image" : image,
      "Likecount" : like.toString(),
    });
    if(response.statusCode ==200){
      print("Your post has been uploaded");
      progressDialog.hide();
      showDialog(
          context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
            return AlertDialog(
              title: Text('Success'),
              content: Text('Your post has been uploaded!'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: (){
                      setState(() {
                        Navigator.pop(c);
                        Navigator.pop(context);
                      });
                    },
                    child: Text('Ok')),
              ],
            );
        }
      );
    }
  }

  insertNewUserPost(String token) async{
    var res= await http.get("http://192.168.0.110:3000//api/userpost/info",
        headers: {
          'Authorization' : 'Bearer $token'
        }
    );
    if(res.statusCode == 200){
      var dataUser=jsonDecode(res.body);
      //var userPost=dataUser['data']['user_post'];
      int userPostId=dataUser['data']['user_post']['id'];
      int id=dataUser['data']['user_post']['user_id'];
      //var create_date=userPost['create_date'];
      print(userPostId.toString() + "==@@@@@@@@@@" );
      newMomentPost(id,userPostId,textEditingController.text,link,like);
    }
  }

  uploadPost(String user_token) async{
    var userPostUrl="http://192.168.0.110:3000//api/userpost";
    var response= await http.get(userPostUrl,
        headers: {
          'Authorization' : 'Bearer $user_token'
        });
    if(response.statusCode == 200){
      var data=jsonDecode(response.body);
      var token=data['data']['token'];
      insertNewUserPost(token);
    }
  }

  upload() async{
    progressDialog.show();
    if(userId!=0){
      if(images.length !=0){
        uploadImage(images).then((value){
          setState(() {
            link=value;
            print(link+" ========Image link==========");
          });
        });
      }
      uploadPost(userToken);
    }else{
      print('Please log in or register to be able to post');
    }
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context);
    progressDialog.style(
        message: 'Uploading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 3.0,
        insetAnimCurve: Curves.easeInCirc,
        progress: 0.0,
        maxProgress: 10.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 1.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.bold)
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Moment Post'),
        actions: <Widget>[
          (isWriting || list.length>1)? FlatButton(
            child: Text('Post',style: TextStyle(
              color: Colors.white,fontSize: 20.0
            ),
            ),
            onPressed: (){
              setState(() {
                upload();
              });
            },
          ) : Container(),
        ],
      ),
      body: WillPopScope(
        child: Container(
            child: Column(
              children: <Widget>[
                Flexible(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 5.0,left: 10.0,right: 10.0,bottom: 5.0),
                              child: TextField(
                                controller: textEditingController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                focusNode: focusNode,
                                autofocus: true,
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  hintText: 'Enter caption...',
                                ),
                                onChanged: (value){
                                  (value.trim()!=null && value.length>=5)? isWritingTo(true) : isWritingTo(false);
                                },
                                onTap: (){
                                  setState(() {
                                    if(isShowSticker){
                                      hideStickerContainer();
                                      isShowSticker=false;
                                    }else{
                                      showKeyboard();
                                      isShowKeyboard=true;
                                    }
                                  });

                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Wrap(
                                children: list,
                                spacing: 5.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
                Container(
                  child: _buildInput(),
                ),
               // isShowKeyboard? buildSticker() : Container(),
                Container(
                  child:isShowSticker ? buildSticker() : Container(),

                ),
              ],
            ),
        ),
        onWillPop: _onBackPressed,
      ),
    );
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImages,enableCamera: true,

      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;

      if (error == null) _error = 'No Error Dectected';
      if(list.length<=9){
        print("============"+images.length.toString());
        for(var i=0;i<images.length;i++){
          Asset asset = images[i];
          index=list.length-1;
          list.insert(index, buildImage(asset));
          allList.add(All(index,asset));
        }
        if(images.length==9){
          print('length before============='+list.length.toString());
          //list.removeLast();
          //maxImages=0;
          print('length after============='+list.length.toString());
        }
          if(list.length>=10){
            maxImages=0;
            list.removeLast();
            print('After length==='+list.length.toString());
          }else if(list.length==9){
            maxImages=1;
          }
          else{
            maxImages=(9-list.length)+1;
          }
          print("Max Length===="+maxImages.toString());

      }
    });
  }

  Widget buildGridView() {
    if (images != null)
      return Container(
        padding: EdgeInsets.only(left: 10.0,right: 10.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          children: List.generate(images.length, (index) {
            Asset asset = images[index];
            return AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            );
          }),
        ),
      );
    else
      return buildAddButton();
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
          textEditingController.text=textEditingController.text+emoji.emoji;
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
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Material(
                      child: new Container(
                        child: new IconButton(
                          icon: new Icon(Icons.keyboard_hide),
                          onPressed: () {
                            setState(() {
                              if(isShowKeyboard){
                                hideKeyboard();
                                isShowKeyboard=false;
                              }else{
                                if(isShowSticker){
                                  hideStickerContainer();
                                  hideKeyboard();
                                  isShowKeyboard=true;
                                }else{
                                  showKeyboard();
                                  isShowKeyboard=true;
                                }
                              }

                            });
                          },
                          color: Colors.blueGrey,
                        ),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Material(
                    child: new Container(
                      child: new IconButton(
                        icon: new Icon(Icons.alternate_email),
                        onPressed: () {
                          setState(() {
                            // if(!isShowSticker){
                            //  hideKeyboard();
                            //  showStickerContainer();
                            // }else{
                            //  showKeyboard();
                            //    hideStickerContainer();
                            //  }
                          });
                        },
                        color: Colors.blueGrey,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  Material(
                    child: new Container(
                      child: new IconButton(
                        icon: Text('#',style: TextStyle(color: Colors.blueGrey,fontSize: 25.0,fontWeight: FontWeight.bold),),
                        onPressed: () {
                          setState(() {
                            // if(!isShowSticker){
                            //  hideKeyboard();
                            //  showStickerContainer();
                            // }else{
                            //  showKeyboard();
                            //    hideStickerContainer();
                            //  }
                          });
                        },
                        color: Colors.blueGrey,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  Material(
                    child: new Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: new IconButton(
                        icon: new Icon(Icons.insert_emoticon, color: isShowSticker? Colors.blue : Colors.blueGrey,),
                        onPressed: () {
                          setState(() {
                             if(isShowKeyboard){
                               hideKeyboard();
                               showStickerContainer();
                               isShowSticker=true;
                               isShowKeyboard=false;
                               focusNode.unfocus();
                             }else{
                               showKeyboard();
                               hideStickerContainer();
                               isShowSticker=false;
                               isShowKeyboard=true;
//                               if(focusNode.hasFocus){
//                                 isShowSticker=false;
//                               }
                             }
                             if(focusNode.hasFocus){
                               hideKeyboard();
                               showStickerContainer();
                               isShowSticker=true;
                               focusNode.unfocus();
                             }
                          });
                        },
                        color: Colors.blueGrey,
                      ),
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Button send message
          ],
        ));
  }

  Widget buildAddButton(){
    return Container(
      height: 100.0,width: 100.0,
      decoration: BoxDecoration(
        color: Colors.black12,
      ),
      child: GestureDetector(
        onTap: (){
          focusNode.unfocus();
          loadAssets();
          print("List length"+list.length.toString());
        },
        child: Center(
          child: Icon(Icons.add,size: 50.0,color: Colors.grey,),
        ),
      ),
    );
  }

  Widget buildImage(Asset asset) {

    return Container(
      height: 100.0,width: 100.0,
      padding: EdgeInsets.only(bottom: 5),
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            child: AssetThumb(
              asset: asset,quality: 100,
              width: 100,
              height: 100,
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                listLength=0;
                if(allList.length==9){
                  count=0;
                }
                if(list.length<=8){
                  count=1;
                }

                outer: for(var j=0;j<allList.length;j++){
                  if(asset==allList[j].image){
                    listLength=allList[j].id;
                    list.remove(list[listLength]);
                    break outer;
                  }
                }

                for(var n=listLength+1;n<allList.length;n++){
                  allList[n].id=n-1;
                }
                allList.remove(allList[listLength]);


                list.add(buildAddButton());
                count=count+1;
                for(var i=1;i<count;i++){
                  list.remove(list[list.length-1]);
                  count=1;
                }
                maxImages=(9-list.length)+1;
                print("after delete==="+maxImages.toString());

              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 5.0,right: 5.0),
              child: Icon(Icons.close,color: Colors.white,size: 15.0,),
            ),
          ),
        ],
      ),
    );
  }


}

class All{
   int id;
   Asset image;

  All(this.id, this.image);
}