import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/video/pages/commentpage/chat_message.dart';
import 'package:emoji_picker/emoji_picker.dart';
// import 'package:news/video/pages/utilies.dart';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  ScrollController _listScrollController = ScrollController();
  bool isWriting = false;
  bool showEmojiPicker = false;
  FocusNode textFielFocus = FocusNode();
  File imageFile;
  //responsible for changing the value of iswriting

  void setWritingTo(bool val) {
    setState(() {
      isWriting = val;
    });
  }

  void _handleSubmitted(
    String text,
    File imageFile,
  ) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      imageFile: imageFile,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  showKeyboard() => textFielFocus.requestFocus();
  hideKeyboard() => textFielFocus.unfocus();
  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  _camera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imageFile = image;
      });
    }
  }

  Widget _textComposerWidget() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onTap: () => hideEmojiContainer(),
              controller: _textController,
              focusNode: textFielFocus,
              style: TextStyle(
                color: Colors.white,
              ),
              onChanged: (val) {
                (val.length > 0 && val.trim() != "")
                    ? setWritingTo(true)
                    : setWritingTo(false);
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  filled: true,
                  fillColor: Colors.black,
                  hintText: "Type a Comment",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        if (!showEmojiPicker) {
                          //keyboard is visible
                          hideKeyboard();
                          showEmojiContainer();
                        } else {
                          //keyboard is hidden
                          showKeyboard();
                          hideEmojiContainer();
                        }
                      },
                      child: Icon(
                        Icons.tag_faces,
                        size: 15.0,
                        color: Colors.white,
                      ))),
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                      onTap: () => _camera(), child: Icon(Icons.camera_alt)),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 25,
                        color: Colors.black,
                      ),
                      onPressed: () =>
                          _handleSubmitted(_textController.text, imageFile)),
                )
              : Container(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.black,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });
        _textController.text = _textController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Comment"),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                controller: _listScrollController,
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.grey,
            ),
            Container(
              child: _textComposerWidget(),
            ),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ));
  }
}
