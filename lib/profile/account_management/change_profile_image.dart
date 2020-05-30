import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/ant_icon.dart';
import 'dart:async';
import 'dart:io';

import 'package:video_box/video_box.dart';

class ChangeProfileImage extends StatefulWidget {
  @override
  _ChangeProfileImageState createState() => _ChangeProfileImageState();
}

class _ChangeProfileImageState extends State<ChangeProfileImage> {
  var _imagePath;
  File _imageFile;
  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  Future<void> _playVideo(File file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      _controller = VideoPlayerController.file(file);
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      final File file = await ImagePicker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file);
    } else {
      await _displayPickImageDialog(context,
              (double maxWidth, double maxHeight, int quality) async {
            try {
              _imageFile = await ImagePicker.pickImage(
                  source: source,
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  imageQuality: quality);
              setState(() {});
            } catch (e) {
              _pickImageError = e;
            }
          });
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Image Picker Test'),
//      ),
//      body: Center(
//        child: Platform.isAndroid
//            ? FutureBuilder<void>(
//          future: retrieveLostData(),
//          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//            switch (snapshot.connectionState) {
//              case ConnectionState.none:
//              case ConnectionState.waiting:
//                return const Text(
//                  'You have not yet picked an image.',
//                  textAlign: TextAlign.center,
//                );
//              case ConnectionState.done:
//                return isVideo ? _previewVideo() : _previewImage();
//              default:
//                if (snapshot.hasError) {
//                  return Text(
//                    'Pick image/video error: ${snapshot.error}}',
//                    textAlign: TextAlign.center,
//                  );
//                } else {
//                  return const Text(
//                    'You have not yet picked an image.',
//                    textAlign: TextAlign.center,
//                  );
//                }
//            }
//          },
//        )
//            : (isVideo ? _previewVideo() : _previewImage()),
//      ),
//      floatingActionButton: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
//        children: <Widget>[
//          FloatingActionButton(
//            onPressed: () {
//              isVideo = false;
//              _onImageButtonPressed(ImageSource.gallery, context: context);
//            },
//            heroTag: 'image0',
//            tooltip: 'Pick Image from gallery',
//            child: const Icon(Icons.photo_library),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(top: 16.0),
//            child: FloatingActionButton(
//              onPressed: () {
//                isVideo = false;
//                _onImageButtonPressed(ImageSource.camera, context: context);
//              },
//              heroTag: 'image1',
//              tooltip: 'Take a Photo',
//              child: const Icon(Icons.camera_alt),
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(top: 16.0),
//            child: FloatingActionButton(
//              backgroundColor: Colors.red,
//              onPressed: () {
//                isVideo = true;
//                _onImageButtonPressed(ImageSource.gallery);
//              },
//              heroTag: 'video0',
//              tooltip: 'Pick Video from gallery',
//              child: const Icon(Icons.video_library),
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.only(top: 16.0),
//            child: FloatingActionButton(
//              backgroundColor: Colors.red,
//              onPressed: () {
//                isVideo = true;
//                _onImageButtonPressed(ImageSource.camera);
//              },
//              heroTag: 'video1',
//              tooltip: 'Take a Video',
//              child: const Icon(Icons.videocam),
//            ),
//          ),
//        ],
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _ImageView(_imagePath),
            RaisedButton(
              onPressed: _takePhoto,
              child: Text('Take A Photo'),
            ),
            RaisedButton(
              onPressed: _openGallery,
              child: Text('Choose from Gallery'),
            )
          ],
        ),
      )
    );
  }

  Widget _ImageView(imgPath) {
    if(imgPath == null) {
      return Center(
        child: Text('请选择图片或拍照'),
      );
    }
      else {
        return Image.file(imgPath);
    }
  }

  _takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _imagePath = image;
    });
  }

  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imagePath = image;
    });
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                  InputDecoration(hintText: "Enter maxWidth if desired"),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                  InputDecoration(hintText: "Enter maxHeight if desired"),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration:
                  InputDecoration(hintText: "Enter quality if desired"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    double width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    double height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    int quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
