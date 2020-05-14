import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
import 'package:video_box/video.controller.dart';

class FileVideoPost extends StatefulWidget {


  @override
  _FileVideoPostState createState() => _FileVideoPostState();
}

class _FileVideoPostState extends State<FileVideoPost> {


  VideoController videoController;
  PersistentBottomSheetController bottomSheetController;
  TextEditingController captionController=new TextEditingController();
  TextEditingController descriptionController= new TextEditingController();
  FocusNode focusNode=new FocusNode();
  bool isWriting=false;
  bool validate=true;
  bool hasVideo;
  File videoFile;
  bool changed=false;
  bool firstChanged=false;
  int count=0;
  String caption='';
  String description='';
  List<String> _category = ['Funny', 'Health','Traditional','Internationl'];
  String _selectedCategory;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hasVideo=false;

  }

  @override
  void dispose() {
    captionController.dispose();
    descriptionController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  isWritingTo(bool val) {
    setState(() {
      isWriting=val;
    });
  }

  _pickVideo() async{
    File file=await ImagePicker.pickVideo(source: ImageSource.gallery);
    //File file=await FilePicker.getFile(type: FileType.video);
    if(file!=null){
      setState(() {
        changed=true;
        videoFile=file;
        videoController=VideoController(source: VideoPlayerController.file(file))..initialize().then((_){

        });
      });
    }
  }


  Future<bool> _onBackPressed(){
    return videoFile!=null? showDialog(
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('File Video'),

      ),
      body: WillPopScope(
        child: Container(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  videoFile!=null?
                  Container(
                    height: 250.0,
                    //width: MediaQuery.of(context).size.width*(100/100),
                     //child: FittedBox(
                       //fit: BoxFit.fill,
                       //height: 250.0,
                       child: mounted? AspectRatio(
                         aspectRatio: 16/9,
                         child: VideoBox(controller: videoController),
                       )
                           : Container(),
                  //),
                  )
                      :Container(
                    height: 250.0,
                    child: Center(
                      child: GestureDetector(
                        onTap: (){
                          _pickVideo();
                        },
                        child: Container(
                          width: 100.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                              child: Text('Add Video',style: TextStyle(color: Colors.white),
                              ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Divider(height: 5.0,color: Colors.grey,),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Text('Category'),
                              Text('*',style: TextStyle(color: Colors.red),),
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
                                  hint: Text('Choose Category',
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
                                    });
                                  },
                                  items: _category.map((category) {
                                    return DropdownMenuItem(
                                      child: new Text(category),
                                      value: category,
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
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Divider(height: 5.0,color: Colors.grey,),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Text('Caption'),
                              Text('*',style: TextStyle(color: Colors.red),),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                //_showBottomSheet(context);
                                //_showAlertDialog(context);
                                _showCaptionDialog(context);
                              });
                            },
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 9,
                                      child: Text(caption,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child:Icon(Icons.arrow_forward_ios,size: 20.0,color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    width: double.infinity,
                    height: 50.0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child:Text('Description'),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: (){
                              _showDescriptionDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 9,
                                  child: Text(description,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey),),
                                ),
                                Expanded(
                                  flex: 1,
                                    child:Icon(Icons.arrow_forward_ios,size: 20.0,color: Colors.grey,)
                                  ,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Divider(height: 5.0,color: Colors.grey,),
                  ),
                ],
              ),
              Container(
                height: 50.0,
                padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          if(videoFile!=null){
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext c){
                                return AlertDialog(
                                  title: Text('Warning'),
                                  content: Text('Are you sure want to exit!'),
                                  actions: <Widget>[
                                    new FlatButton(
                                        onPressed: ()=> Navigator.pop(c),
                                        child: Text('No')),
                                    new FlatButton(
                                        onPressed: (){
                                          setState(() {
                                            Navigator.pop(c);
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text('Yes')),
                                  ],
                                );
                              }
                            );
                          }else{
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 40.0,
                          padding: EdgeInsets.only(left: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0,),
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                            ),
                            child:  Center(child: Text('Cancel',style: TextStyle(color: Colors.grey),)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            _checkToPost();
                          });},
                        child: Container(
                          height: 40.0,
                          padding: EdgeInsets.only(left: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0,),
                              color: (_selectedCategory!=null && caption.isNotEmpty && caption!="Caption..." && videoFile!=null)? Colors.blue : Colors.grey,
                            ),
                            child:  Center(child: Text('Post',style: TextStyle(color: Colors.white),)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onWillPop:_onBackPressed,
      ),
    );
  }

  _showCaptionDialog(BuildContext context) async {

    if(caption.isNotEmpty && caption!="Caption..."){
      captionController.text=caption;
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 110.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                          controller: captionController,
                          maxLines: null,
                          maxLength: 50,
                          autofocus: true,
                          focusNode: focusNode,
                          decoration: InputDecoration(hintText: "Caption...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          //errorText: validate? null : 'please enter at least 5',
                          ),
                      onChanged: (val){
                        (val.length>=5 && val.trim()!=null)?
                            isWritingTo(true) : isWritingTo(false);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0),
                    height: 17.0,
                      child: Text('min 5 ~ max 50',style: TextStyle(color:Colors.grey,fontSize: 12.0),)),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Save',style: TextStyle(color: Colors.blue),),
                onPressed: () {
                  setState(() {
                    if(isWriting==true){
                      validate=true;
                      caption=captionController.text;
                      Navigator.of(context).pop();
                    }else{
                      validate=false;
                    }
                  });
                },
              )
            ],
          );
        });
  }

  _showDescriptionDialog(BuildContext context) async{
    if(description.isNotEmpty && description!="Description..."){
      descriptionController.text=description;
    }else{
      //descriptionController.text="Description...";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 140.0,
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: descriptionController,
                      maxLength: 200,
                      maxLines: 4,
                      focusNode: focusNode,
                      keyboardType: TextInputType.multiline,
                      autofocus: true,
                      decoration: InputDecoration(hintText: "Description...",
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        //errorText: validate? null : 'please enter at least 5',
                      ),
                      onChanged: (val){
                        (val.length>0 && val.trim()!=null)?
                        isWritingTo(true) : isWritingTo(false);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0),
                          height: 17.0,
                          child: Text('min 0 ~ max 500',style: TextStyle(color:Colors.grey,fontSize: 10.0),)),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){Navigator.pop(context);},
                  child: Text('Cancel')),
              new FlatButton(
                  onPressed: (){
                    setState(() {
                      if(isWriting==true){
                        validate=true;
                        description=descriptionController.text;
                      }else{
                        validate=false;
                        description="Description...";
                      }
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Save')),
            ],
          );
        });
  }

  _checkToPost() {
    if(_selectedCategory.isNotEmpty && caption.isNotEmpty && caption!="Caption..."){
      if(videoFile!=null){

      }else{
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context){
              return AlertDialog(
                title: Text('Warning'),
                content: Text('Please add video file to be able to home.post!',
                  style: TextStyle(
                      height: 1.5
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(onPressed: ()=> Navigator.pop(context),
                      child: new Text('Ok'))
                ],
              );
            }
        );
      }

    }else{
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return AlertDialog(
              title: Text('Warning'),
              content: Text('Please enter both category and caption field to be able to home.post!',
                style: TextStyle(
                    height: 1.5
                ),
              ),
              actions: <Widget>[
                new FlatButton(onPressed: ()=> Navigator.pop(context),
                    child: new Text('Ok'))
              ],
            );
          }
      );
    }
  }

}

