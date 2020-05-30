import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:news/api.dart';
import 'package:news/database/database.dart';
import 'package:news/home/page_details/article_page_details.dart';
import 'package:news/home/widgets/article_skeleton.dart';
import 'package:news/home/widgets/skeleton.dart';
import 'package:news/models/article.dart';
import 'package:http/http.dart' as http;
import 'package:news/models/check_time.dart';
import 'package:news/models/following.dart';
import 'package:news/models/user.dart';
import 'package:news/view_models/structure_model.dart';
import 'package:news/provider/provider_widget.dart';
import 'package:news/view_models/view_state_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:news/helper/refresh_helper.dart';



class ArticlePage extends StatefulWidget {
  final int id;
  ArticlePage({this.id});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with AutomaticKeepAliveClientMixin {

  int categoryID;

  List<Article> articleList=[];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryID= widget.id;

//    getArticle(categoryID).then((value){
//      setState(() {
//        articleList=value;
//        print("Article list======="+articleList.length.toString());
//      });
//    });
  }


  Future<List<Article>> getArticle(int id) async{
    List<Article> articles=[];
    var response= await http.post(Api.GET_ARTICLE_URL,
    body: {
      "Categoryid" : id.toString(),
    });
    if(response.statusCode ==200){
      var body= jsonDecode(response.body);
      var data= body['data'];
      for(int i=0;i<data.length;i++){
        Map map= data[i];
        Article article = Article.fromJson(map);
        articles.add(article);
      }
    }
    print("Article list*****"+articles.length.toString());
    return articles;
  }

  List<Widget> getDelegate() {
    List<Widget> _generalDelegates = List<Widget>();
    for (var i = 0; i < articleList.length; i++) {
      Article article=articleList[i];
      _generalDelegates.add(ArticleContent(article: article,));
    }
    print("General===="+_generalDelegates.length.toString());
    return _generalDelegates;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<ArticleListModel>(
      model: ArticleListModel(widget.id),
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
            footer: RefresherFooter(),
            onRefresh: model.refresh,
            //onLoading: model.loadMore,
            enablePullUp: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  ImageContent(),
                  ListView.builder(
                          itemCount: model.list.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            Article article = model.list[index];
                            return ArticleContent(article: article,);
                          }
                          ),
                ],
              ),
            ),

        );
      },
    );
//    return Container(
//      child: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            ImageContent(),
//            Container(
//              height: 5.0,
//              color: Colors.black12,
//            ),
//            Container(
//              child: FutureBuilder<List<Article>>(
//                future: getArticle(categoryID),
//                builder: (context , snapshot){
//                  if(snapshot.hasError){
//                    return Center(
//                      child: Container(
//                        margin: EdgeInsets.only(top: 50.0),
//                        child: Column(
//                          children: <Widget>[
//                            Icon(Icons.error,size: 50.0,color: Colors.grey,),
//                            SizedBox(height: 10.0,),
//                            Text('Network Error, check your connection!',style: TextStyle(color: Colors.red,fontSize: 15.0,fontWeight: FontWeight.bold),),
//                          ],
//                        ),
//                      ),
//                    );
//                  }else if(snapshot.hasData){
//                    List<Article> articles=snapshot.data;
//                    return ListView.builder(
//                        itemCount: articles.length,
//                        shrinkWrap: true,
//                        physics: ClampingScrollPhysics(),
//                        itemBuilder: (context ,index){
//                          return ArticleContent(article: articles[index],);
//                        }
//                    );
//                  }
//                  return SkeletonList(
//                    builder: (context, index) => ArticleSkeletonItem(),
//                    );
//                },
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageContent extends StatefulWidget {
  @override
  _ImageContentState createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg","adv4.jpg","adv5.jpg","adv6.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*(25/100),
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          //return new Image.network("http://via.placeholder.com/350x150",fit: BoxFit.fill,);
          return new Image.asset('assets/'+images[index],fit: BoxFit.cover,);
        },
        itemCount: images.length,
        pagination: new SwiperPagination(
          builder: SwiperPagination.dots,
          alignment: Alignment.bottomCenter,
        ),
        control: new SwiperControl(
          color: Colors.blue,
          size: 25.0,
        ),
        autoplay: true,
      ),
    );
  }
}

class ArticleContent extends StatefulWidget {
  final Article article;
  ArticleContent({Key key,this.article});

  @override
  _ArticleContentState createState() => _ArticleContentState();
}

class _ArticleContentState extends State<ArticleContent> {

  Article article;
  Following following;

  int like=0;
  int view=0;
  int userID=0;
  int comment=0;

  List<User> userList=[];
  List<String> imageList=List<String>();

  DateTime created;
  DateTime now = DateTime.now();

  String name='';
  String date='';
  String cover='';

  var baseUrl="http://192.168.0.119:3000/public/";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    article=widget.article;
    cover=article.cover;

    print("Result==="+article.articlePostID.toString()+"***"+article.content+"***"+article.cover);

    checkUser().then((value){
      userList=value;
      if(userList.length != 0){
        userID=userList[0].userID;
        print("Userid=======**"+userID.toString());
      }
    });

    getCommentCount(article.articlePostID).then((value){
      setState(() {
        comment=value;
      });
    });

    getUserInfo(article.userID).then((value){
      setState(() {
        following=value;
        name=following.userName;
      });
    });

    if(cover!=null){
      var array= article.cover.split("/");
      for(int i=0;i<array.length;i++){
        imageList.add(array[i]);
      }
      print("image length===="+imageList.length.toString());
    }

    var arr= article.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    like=article.likeCount;
    view=article.viewCount;
    date=Check().checkDate(created, now);
  }

  Future<int> getCommentCount(int id) async{
    int count=0;
    var res =await http.post(Api.GET_COMMENT_COUNT_URL,
        body: {
          'Postid' : id.toString(),
          'Field' : "article",
        });
    if(res.statusCode==200){
      var data=jsonDecode(res.body);
      count= data['count'];
    }
    return count;
  }

  Future<List<User>> checkUser() async{
    Future<List<User>> futureList=SQLiteDbProvider.db.getUser();
    List<User> userLists= await futureList;
    return userLists;
  }

  Future<Following> getUserInfo(int id) async{
    var res=await http.post(Api.USER_INFO_URL,
        body: {
          'Userid' : id.toString(),
        });
    var data=jsonDecode(res.body);
    Map userMap=data['data'];
    Following following=Following.fromJson(userMap);
    return following;
  }

  void _setPage(BuildContext context) {
    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ArticlePageDetails(article: article,commentCount: comment,))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              _setPage(context);
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
          (imageList.length!=1)? GestureDetector(
            onTap: (){
              _setPage(context);
            },
            child: Container(
              margin: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
              child: Row(
                children: <Widget>[
                  imageList.length>2?  Expanded(
                    flex: 1,
                    child: Container(
                        height: 100.0,
                        padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                           // child: Image.network(baseUrl+imageList[0],fit: BoxFit.cover,)
                          child: CachedNetworkImage(
                            imageUrl: baseUrl+imageList[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ) : Container(
                      height: 200.0,
                      width: MediaQuery.of(context).size.width*(90/100),
                      margin: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          //child: Image.network(baseUrl+imageList[0],fit: BoxFit.cover,)
                        child: CachedNetworkImage(
                          imageUrl: baseUrl+imageList[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  imageList.length>=3? Expanded(
                    flex: 1,
                    child: Container(
                      height: 100.0,
                      padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          //child: Image.network(baseUrl+imageList[1],fit: BoxFit.cover,)
                        child: CachedNetworkImage(
                          imageUrl: baseUrl+imageList[1],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ) : Container(),
                  imageList.length>3? Expanded(
                    flex: 1,
                    child: Container(
                      height: 100.0,
                      padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          //child: Image.network(baseUrl+imageList[2],fit: BoxFit.cover,)
                        child: CachedNetworkImage(
                          imageUrl: baseUrl+imageList[2],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ): Container(),
                ],
              ),
            ),
          )
          : Container(height: 0.0,),
          SizedBox(
            height: 5,
          ),
//          Container(
//            color: Colors.black12,
//            height: 1.0,
//            margin: EdgeInsets.only(top: 5.0),
//          ),
//          GestureDetector(
//            onTap: (){
//              setState(() {
//                _setPage(context);
//              });
//            },
//            child: Container(
//              height: 30.0,
//              padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 2.0,bottom: 2.0),
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Expanded(
//                    flex: 1,
//                    child: Center(
//                      child: Text(name,
//                        style: TextStyle(
//                          color: Colors.black54,
//                          fontSize: 12.0,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Expanded(
//                    flex: 1,
//                    child: Center(
//                      child: Text('$comment Comment',
//                        style: TextStyle(
//                          color: Colors.black54,
//                          fontSize: 12.0,
//                        ),
//                      ),
//                    ),
//                  ),
//                  Expanded(
//                    flex: 1,
//                    child: Center(
//                      child: Text(date,
//                        style: TextStyle(
//                          color: Colors.black54,
//                          fontSize: 12.0,
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ),
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


