import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:news/models/article.dart';

class ArticleItemWidget extends StatelessWidget {
  final Article article;
  final int index;
  final GestureTapCallback onTap;

  /// 首页置顶
  final bool top;

  /// 隐藏收藏按钮
  final bool hideFavourite;

  ArticleItemWidget(this.article,
      {this.index, this.onTap, this.top: false, this.hideFavourite: false})
      : super(key: ValueKey(article.articlePostID));



  @override
  Widget build(BuildContext context) {
    var backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    /// 用于Hero动画的标记
    UniqueKey uniqueKey = UniqueKey();
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (){
             // _setPage(context);
            },
            child: Container(
              padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0),
              child: Text(article.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black12,
            height: 1.0,
            margin: EdgeInsets.only(top: 5.0),
          ),
          GestureDetector(
            onTap: (){

            },
            child: Container(
              height: 30.0,
              padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 2.0,bottom: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('sai thein han',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('0 Comment',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text("15",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 5.0,
            padding: EdgeInsets.only(top: 5.0,),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}

//class ArticleTitleWidget extends StatelessWidget {
//  final String title;
//
//  ArticleTitleWidget(this.title);
//
//  @override
//  Widget build(BuildContext context) {
//    return Html(
//      padding: EdgeInsets.symmetric(vertical: 5),
//      useRichText: false,
//      data: title,
//      defaultTextStyle: Theme.of(context).textTheme.subtitle,
//    );
//  }
//}

/// 收藏按钮
//class ArticleFavouriteWidget extends StatelessWidget {
//  final Article article;
//  final UniqueKey uniqueKey;
//
//  ArticleFavouriteWidget(this.article, this.uniqueKey);
//
//  @override
//  Widget build(BuildContext context) {
//    return ProviderWidget<FavouriteModel>(
//      model: FavouriteModel(
//          globalFavouriteModel: Provider.of(context, listen: false)),
//      builder: (_, favouriteModel, __) => GestureDetector(
//          behavior: HitTestBehavior.opaque, //否则padding的区域点击无效
//          onTap: () async {
//            if (!favouriteModel.isBusy) {
//              addFavourites(context,
//                  article: article, model: favouriteModel, tag: uniqueKey);
//            }
//          },
//          child: Padding(
//              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
//              child: Hero(
//                tag: uniqueKey,
//                child: ScaleAnimatedSwitcher(
//                    child: favouriteModel.isBusy
//                        ? SizedBox(
//                            height: 24,
//                            width: 24,
//                            child: CupertinoActivityIndicator(radius: 5))
//                        : Consumer<UserModel>(
//                      builder: (context,userModel,child)=>Icon(
//                          userModel.hasUser && article.collect
//                              ? Icons.favorite
//                              : Icons.favorite_border,
//                          color: Colors.redAccent[100]),
//                    )),
//              ))),
//    );
//  }
//}
