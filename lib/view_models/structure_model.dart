

import 'package:news/view_models/view_state_list_model.dart';
import 'package:news/view_models/view_state_refresh_list_model.dart';
import 'package:news/api.dart';

class StructureCategoryModel extends ViewStateListModel {
  @override
  Future<List> loadData() async {
    return await Api.fetchTreeCategories();
  }
}

class RecommendUserModel extends ViewStateListModel {

  @override
  Future<List> loadData() async{
    return await Api.fetchRecommendUsers();
  }

}

class FollowingUserModel extends ViewStateListModel {
  @override
  Future<List> loadData() async{
    return await Api.fetchFollowing();
  }

}

class ArticleListModel extends ViewStateRefreshListModel {
  final int cid;

  ArticleListModel(this.cid);

  @override
  Future<List> loadData({int pageNum}) async {
    return await Api.fetchArticles(pageNum, cid: cid);
  }

//  @override
//  onCompleted(List data) {
//    GlobalFavouriteStateModel.refresh(data);
//  }
}

class MomentListModel extends ViewStateRefreshListModel {

  MomentListModel();

  @override
  Future<List> loadData({int pageNum}) async{
    return await Api.fetchMoments();
  }


}

class VideoListModel extends ViewStateRefreshListModel {
  final int cid;

  VideoListModel(this.cid);

  @override
  Future<List> loadData({int pageNum}) async {
    return await Api.getVideo(cid: cid);
  }
}

/// 网址导航
//class NavigationSiteModel extends ViewStateListModel {
//  @override
//  Future<List> loadData() async {
//    return await WanAndroidRepository.fetchNavigationSite();
//  }
//}

