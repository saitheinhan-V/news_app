import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:emoji_picker/emoji_picker.dart';
import 'package:news/api.dart';
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
  List<String> links= List<String>();
  List<Asset> images = List<Asset>();
  List<File> _files=[];
  List<Widget> list=[];
  List<All> allList=[];

  String _error;
  String link='';
  String userToken='';

  int listLength=0;
  int maxImages=9;
  int index=0;
  int like=0;

  Api api= new Api();

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

  //Future<String> get filePath { return MultiImagePicker.requestFilePath(_identifier); }

  Future<String> uploadImage(File file) async{
    String s='';
      FormData formData = new FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
      });
      Dio dio =new Dio();
      Response response= await dio.post(Api.UPLOAD_URL,
      data: formData);
      print(response.data.toString());
      if(response.statusCode == 200){
        s= response.data['filepath'];
      }

    return s;
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

  newMomentPost(String userPostToken,String caption,String image,int like) async{
    var response=await http.post(Api.NEWMOMENTPOST_URL,
        headers: {
          'Authorization' : 'Bearer $userPostToken'
        },
        body: {
      "Caption" : caption,
      "Image" : image,
      "Likecount" : like.toString(),
    });
    if(response.statusCode ==200){
      print("Your post has been uploaded");
      print(image);
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

  uploadPost(String token) async{
    var response= await http.post(Api.NEWPOST_URL,
        headers: {
          'Authorization' : 'Bearer $token'
        });
    if(response.statusCode == 200){
      var data=jsonDecode(response.body);
      var userPostToken=data['data']['token'];
      print("All list length=========="+allList.length.toString());

      for(int i=0;i<allList.length;i++){
        File file= allList[i].image;
        FormData formData = new FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path),
        });
        Dio dio =new Dio();
        Response response= await dio.post(Api.UPLOAD_URL,
            data: formData);
        print(response.data.toString());
        if(response.statusCode == 200){
          link = link + response.data['filepath'] + ",";
        }
      }
      print("link*********"+link);
      newMomentPost(userPostToken,textEditingController.text, link, like);
    }
  }

  upload(String user_token) async{
    progressDialog.show();
    if(userId!=0){
      uploadPost(user_token);
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
                if(userToken !=null){
                  upload(userToken);
                }
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

  Future<String> getFilePath(Asset asset) async{
    String filePath='';
    filePath= await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
    return filePath;
  }

  Future<List<Asset>> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImages,
        enableCamera: true,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

//     If the widget was removed from the tree while the asynchronous platform
//     message was in flight, we want to discard the reply rather than calling
//     setState to update our non-existent appearance.
    //if (!mounted) return;

    setState(() {
      images = resultList;
      print("Image count========"+images.length.toString());

      if (error == null) _error = 'No Error Detected';
    });

    return images;
  }

  Future<void> init() async{
    List<Asset> image= await loadAssets();
    if(image.length != 0){
      List<File> files=[];
      for(Asset asset in image){
        final filePath= await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
        files.add(File(filePath));
      }
      if(!mounted) return;
      setState(() {
        _files = files;
        print("File length====="+_files.length.toString());
//        uploadImage(_files).then((value){
//          setState(() {
//            links=value;
//            print("Link length======="+links.length.toString());
//          });
//        });

        if(list.length<=9){
          print("============"+_files.length.toString());
          for(var i=0;i<_files.length;i++){
            File file=_files[i];
            index=list.length-1;
            list.insert(index, buildImage(file));
            allList.add(All(index,file));
          }
          if(_files.length==9){
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
          } else{
            maxImages=(9-list.length)+1;
          }
          print("Max Length===="+maxImages.toString());

        }
      });

    }
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
          setState(() {
            focusNode.unfocus();
            init();
            print("List length"+list.length.toString());
          });
        },
        child: Center(
          child: Icon(Icons.add,size: 50.0,color: Colors.grey,),
        ),
      ),
    );
  }

  Widget buildImage(File image) {

    return Container(
      height: 100.0,width: 100.0,
      padding: EdgeInsets.only(bottom: 5),
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            child: Image.file(image,fit: BoxFit.cover,width: 100.0,height: 100.0,),
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
                  if(image==allList[j].image){
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
   File image;

  All(this.id, this.image);
}