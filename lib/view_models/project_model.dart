

import 'package:news/api.dart';
import 'package:news/models/category.dart';
import 'package:news/view_models/view_state_list_model.dart';
import 'package:news/view_models/view_state_refresh_list_model.dart';

class ProjectCategoryModel extends ViewStateListModel<Category> {
  @override
  Future<List<Category>> loadData() async {
    return await Api.fetchProjectCategories();
  }
}

class ProjectListModel extends ViewStateRefreshListModel<Category> {
  @override
  Future<List<Category>> loadData({int pageNum}) async {
    return await Api.fetchArticles(pageNum, cid: 294);
  }
//  @override
//  onCompleted(List data) {
//    GlobalFavouriteStateModel.refresh(data);
//  }
}
