import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/models/category.dart';
import 'package:news/models/token.dart';
import 'package:news/models/user.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:notus/convert.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as mk;


class ArticlePost extends StatefulWidget {
  @override
  _ArticlePostState createState() => _ArticlePostState();
}

class _ArticlePostState extends State<ArticlePost> {

  FocusNode _focusNode= FocusNode();
  FocusNode focusNode=FocusNode();
  ZefyrController _controller;
  TextEditingController textEditingController=TextEditingController();
  bool isWriting=false;

  String userToken='';
  String _selectedCategory;
  String testoHtml;
  String link;
  String realContent='';

  List<User> userList=[];
  List<Token> tokenList=[];
  List<Category> categoryList=[];
  List<String> _categoryName=[];
  List<String> linkList=[];

  int userId=0;
  int like=0;
  int categoryID=0;
  int view=0;

  ProgressDialog progressDialog;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //final document = _loadDocument();
    //_controller = ZefyrController(document);
    //_focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
        //testoHtml = mk.markdownToHtml(_controller.document.toString());
       // print("Html****"+testoHtml);
      });
    });

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

      addCategory().then((value){
        setState(() {
          categoryList=value;
          for (int i = 0; i < categoryList.length; i++) {
            _categoryName.add(categoryList[i].categoryName);
          }
        });
      });
    });
  }


  isWritingTo(bool val) {
    setState(() {
      isWriting=val;
    });
  }

  Future<List<Category>> addCategory() async{
    List<Category> categories=[];
    categories=await SQLiteDbProvider.db.getCategory();
    //_tabController = TabController(length: categoryList.length, vsync: this);
    //_tabs = getTabs(categoryList);
    return categories;
  }

  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    print("Encode=="+_controller.document.toString());
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });
    print("Document==="+contents);
  }

  Future<bool> onBackPressed(){
    return _controller!=null? showDialog(
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
                  _focusNode.unfocus();
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: Text('Yes'),
              ),
            ],
          );
        }
    ): false;
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

  newArticlePost(String userPostToken,String caption,String content,String cover,int view_count,int like_count) async{
    var response=await http.post(Api.NEWARTICLEPOST_URL,
        headers: {
          'Authorization' : 'Bearer $userPostToken'
        },
        body: {
          "Categoryid" : categoryID.toString(),
          "Caption" : caption,
          "Content" : content,
          "Cover" : cover,
          "Viewcount" : view_count.toString(),
          "Likecount" : like_count.toString(),
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

  uploadPost(String token) async{
    progressDialog.show();

    var response= await http.post(Api.NEWPOST_URL,
        headers: {
          'Authorization' : 'Bearer $token'
        });
    if(response.statusCode == 200){
      var data=jsonDecode(response.body);
      var userPostToken=data['data']['token'];

      Delta _delta = _controller.document.toDelta();
      String html = mk.markdownToHtml(notusMarkdown.encode(_delta).toString());

      uploadImage(html).then((value){
        setState(() {
          link=value;
          if(link != null){
            replaceImage(html,link);
            print("All link========="+link);
            newArticlePost(userPostToken,textEditingController.text, realContent, link, view, like);
          }
        });
      });


    }
  }

  Future<String> uploadImage(String content) async{
    String img = 'img';
    var arr = [];
    String allLink='';
    arr = content.split(">");
    for (var i = 0; i < arr.length; i++) {
      if (arr[i].contains(img)) {
        final filePath = arr[i].split("\"")[1];
        File file=new File(filePath);
        FormData formData = new FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path),
        });
        Dio dio =new Dio();
        Response response= await dio.post(Api.UPLOAD_URL,
            data: formData);
        print(response.data.toString());
          allLink = allLink + response.data['filepath'] + "/";
      }
    }
    print("All link********"+allLink);
    return allLink;
  }

  replaceImage(String content,String totalLink) {
    String img='img';
    var baseUrl="http://192.168.0.119:3000/public/";
    var arr =[];
    int count=0;
    arr = content.split(">");

    var links=[];
    links = totalLink.split("/");

    if(links != null){
      //replace image link
      for(var i=0;i<arr.length;i++){
        if (arr[i].contains(img)) {
          var arr2 =[];
          arr2= arr[i].split("\"");
          if(arr2.length != 0){
            arr2[1] = baseUrl + links[count] ;
            String s='';
            for(var j=0;j<arr2.length-1;j++){
              s = s + arr2[j] + "\"";
            }
            s = s+ arr2[arr2.length-1];
            arr[i] = s;
            count= count +1;
          }
        }
      }

      ///re-build html tag
      for(var n=0;n<arr.length-1;n++){
        realContent = realContent + arr[n] + ">";
      }
      realContent = realContent + arr[arr.length-1];
      print("Final content====="+realContent);
    }

  }

  _checkToPost(String user_token) async{
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

    return  Scaffold(
      appBar: AppBar(
        title: Text('Article'),
        actions: <Widget>[
          (isWriting && _controller!=null && _selectedCategory!=null)? FlatButton(
            child: Text('Post',style: TextStyle(
                color: Colors.white,fontSize: 20.0
            ),
            ),
            onPressed: (){
              setState(() {
                if(userId ==0){
                  print("Please log in or register to be able to post");
                  print(_controller.document.toString());
                  print(_controller.document.toPlainText());
                  print(_controller.document.toJson());
                  showDialog(
                      context: context,
                    barrierDismissible: false,
                    builder: (BuildContext ctx){
                        return AlertDialog(
                          title: Text('Warning'),
                          content: Text('Please log in or register to be able to post'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Ok'),
                              onPressed: (){
                                focusNode.unfocus();
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                    }
                  );
                }else{
                  _checkToPost(userToken);
                }
              });
            },
          ) : Container(),
        ],
      ),
      body: WillPopScope(
          onWillPop: onBackPressed,
            child: ZefyrScaffold(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        width: double.infinity,
                        height: 50.0,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: <Widget>[
                                  Text('Category'),
                                  Text(
                                    '*',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      hint: Text(
                                        'Choose Category',
                                        style: TextStyle(color: Colors.grey),
                                      ), // Not necessary for Option 1
                                      value: _selectedCategory,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13.0,
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedCategory = newValue;
                                          outer: for (int i = 0; i < categoryList.length; i++) {
                                            if (categoryList[i].categoryName == _selectedCategory) {
                                              categoryID = categoryList[i].categoryID;
                                              break outer;
                                            }
                                          }
                                        });
                                      },
                                      items: _categoryName.map((name) {
                                        return DropdownMenuItem(
                                          child: new Text(name),
                                          value: name,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        child: Container(
                          height: 1.0,color: Colors.grey,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 10.0,right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextField(
                            autofocus: true,
                            controller: textEditingController,
                            focusNode: focusNode,
                            maxLines: null,
                            maxLength: 200,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Enter Caption... (min 20 ~ max 150)',
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                            ),
                            onChanged: (value){
                              (value.trim()!=null && value.length>=20)? isWritingTo(true) : isWritingTo(false);
                            },
                          ),
                        ),
                      Container(padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        child: Container(
                          height: 1.0,color: Colors.grey,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          //height: MediaQuery.of(context).size.height*(50/100),
                          child: new ZefyrEditor(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: false,
                            imageDelegate: MyAppZefyrImageDelegate(),
                            physics: ClampingScrollPhysics(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ),
    );
  }

  /// Loads the document to be edited in Zefyr.
  Future<NotusDocument> _loadDocument() async{
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    //final Delta delta = Delta()..insert("Zefyr Quick Start\n");
   // return NotusDocument.fromDelta(delta);
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    if (await file.exists()) {
    final contents = await file.readAsString();
    return NotusDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Content...\n");
    return NotusDocument.fromDelta(delta);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    _focusNode.dispose();
    _controller.dispose();
    textEditingController.dispose();
  }


}

class MyAppZefyrImageDelegate implements ZefyrImageDelegate<ImageSource> {
  @override
  Future<String> pickImage(ImageSource source) async {
    final file = await ImagePicker.pickImage(source: source);
    if (file == null) return null;
    // We simply return the absolute path to selected file.
    return file.path;
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    final file = File.fromUri(Uri.parse(key));
    /// Create standard [FileImage] provider. If [key] was an HTTP link
    /// we could use [NetworkImage] instead.
    final image = FileImage(file);
//    return Container(
//      width: 200.0,
//      height: MediaQuery.of(context).size.width,
//      child: Image.file(file,fit: BoxFit.cover,),
//    );
    return Image(image: image,fit: BoxFit.cover,);
  }

  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;
}


