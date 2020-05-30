import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news/database/database.dart';
import 'package:news/helper/refresh_helper.dart';
import 'package:news/home/widgets/article_skeleton.dart';
import 'package:news/home/widgets/skeleton.dart';
import 'package:news/home/widgets/video_skeleton.dart';
import 'package:news/models/user.dart';

import 'package:news/models/video.dart';
import 'package:news/provider/provider_widget.dart';

import 'package:news/video/pages/commentpage/videocomment.dart';
import 'package:news/video/video_list_item.dart';
import 'package:news/view_models/structure_model.dart';
import 'package:news/view_models/view_state_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';

class VideoListPage extends StatefulWidget {
  final int id;

  VideoListPage({Key key, this.id}) : super(key: key);

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<VideoController> vc = [];
  List<String> vcs = [];
  List<Video> videoList = List<Video>();
  File file;
  Dio dio;
  bool isLoading;

  int categoryid;
  int userID = 0;
  String userName;
  List<User> userList = List<User>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<VideoListModel>(
      model: VideoListModel(widget.id),
      onModelReady: (model) => model.initData(),
      builder: (context, model, child) {
        if (model.isBusy) {
          return SkeletonList(
            builder: (context, index) => ArticleSkeletonItem(),
          );
        } else if (model.isError && model.list.isEmpty) {
          return ViewStateErrorWidget(
              error: model.viewStateError, onPressed: model.initData);
        } else if (model.isEmpty) {
          return ViewStateEmptyWidget(onPressed: model.initData);
        }
        return SmartRefresher(
          controller: model.refreshController,
          header: WaterDropHeader(),
          //footer: RefresherFooter(),
          onRefresh: model.refresh,
          //onLoading: model.loadMore,
          enablePullUp: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                  ListView.builder(
                      itemCount: model.list.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        Video video = model.list[index];
                        return VideoContent(
                          video: video,
                        );
                      }
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
