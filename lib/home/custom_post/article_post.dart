import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

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
      });
    });
  }


  isWritingTo(bool val) {
    setState(() {
      isWriting=val;
    });
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
    ): Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        title: Text('Article'),
        actions: <Widget>[
          (isWriting && _controller!=null)? FlatButton(
            child: Text('Post',style: TextStyle(
                color: Colors.white,fontSize: 20.0
            ),),
          ) : Container(),
        ],
      ),
      body: WillPopScope(
          onWillPop: onBackPressed,
            child: ZefyrScaffold(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
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
                          maxLength: 50,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Enter Caption... (min 5 ~ max 30)',
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          onChanged: (value){
                            (value.trim()!=null && value.length>=5)? isWritingTo(true) : isWritingTo(false);
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
                        ),
                      ),
                    ),
                  ],
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
    final Delta delta = Delta()..insert("Enter your content...\n");
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
    return file.uri.toString();
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    final file = File.fromUri(Uri.parse(key));
    /// Create standard [FileImage] provider. If [key] was an HTTP link
    /// we could use [NetworkImage] instead.
    final image = FileImage(file);
    return Container(
      width: 200.0,
      height: MediaQuery.of(context).size.width,
      child: Image.file(file,fit: BoxFit.cover,),
    );
  }

  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;
}


