import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchPeople extends StatefulWidget {
  @override
  _CustomSearchPeopleState createState() => _CustomSearchPeopleState();
}

class _CustomSearchPeopleState extends State<CustomSearchPeople> {
  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  bool isWriting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey),
        title: GestureDetector(
          onTap: () => showSearch(
              context: context,
              delegate: SearchPeople(hintText: 'Search for People...')),
          child: new Container(
              //width: 300.0,
              height: 50.0,
              //padding: EdgeInsets.only(left: 10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Search for People...',
                      style: TextStyle(
                        color: Colors.black54,
                        //fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              )),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchPeople(hintText: 'Search for People...'));
            },
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          primary: true,
          child: Column(
            children: <Widget>[
              _recommendProfile(),
              Container(
                height: 5.0,
                //padding: EdgeInsets.only(top: 5.0,),
                margin: EdgeInsets.only(top: 3.0),
                color: Colors.black12,
              ),
              _recommendProfile(),
              Container(
                height: 5.0,
                //padding: EdgeInsets.only(top: 5.0,),
                margin: EdgeInsets.only(top: 3.0),
                color: Colors.black12,
              ),
              _recommendProfile(),
              Container(
                height: 5.0,
                //padding: EdgeInsets.only(top: 5.0,),
                margin: EdgeInsets.only(top: 3.0),
                color: Colors.black12,
              ),
              _recommendProfile(),
              Container(
                height: 5.0,
                //padding: EdgeInsets.only(top: 5.0,),
                margin: EdgeInsets.only(top: 3.0),
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  isWritingTo(bool param0) {
    setState(() {
      isWriting = param0;
    });
  }

  Container _recentSearch() {
    return Container(
      height: 100.0,
      child: Column(
        children: <Widget>[],
      ),
    );
  }

  Container _recommendProfile() {
    return Container(
      height: 250.0,
      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Recommend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('See More...'),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 220.0,
            child: ListView.builder(
                primary: false,
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    //padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                    child: ListTile(
                      title: Text('Sai Thein Han'),
                      subtitle: Text(
                        '1k Followers',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      leading: Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          image: DecorationImage(
                            image: AssetImage('assets/minion.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      trailing: Container(
                        height: 20.0,
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                //width: 12.0,
                                height: 12.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                  size: 12.0,
                                ),
                              ),
                              Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class SearchPeople extends SearchDelegate<String> {
  String hintText = 'Search for People';
  SearchPeople({this.hintText})
      : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  final cities = [
    'Myanmar',
    'Malaysia',
    'Singapore',
    'Vietnam',
    'Burma',
    'Australia',
    'America',
    'Burma',
    'Hungary',
    'Holland',
    'Zambia',
    'Thailand',
    'Tanzania',
    'Japan',
    'Korea',
    'Cambodia',
    'Cameron',
    'China',
    'Denmark',
    'Egypt',
    'England',
    'Finland',
    'France',
    'Greece',
    'Italy',
    'Portugal',
    'Russia',
    'Switzerland',
    'Netherland',
    'USA',
  ];
  final recentCities = [
    'Myanmar',
    'Malaysia',
    'Singapore',
    'Vietnam',
    'Burma',
    'Australia',
  ];

  bool hasQuery;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? Container(
              width: 20.0,
              child: GestureDetector(
                child: Container(
                  width: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  margin: EdgeInsets.only(top: 18.0, bottom: 18.0),
                  child: Center(
                    child: Icon(
                      Icons.clear,
                      size: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  query = '';
                  hasQuery = false;
                },
              ),
            )
          : Container(),
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          query = '';
          hasQuery = false;
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return hasQuery
        ? Container(
            width: 100.0,
            height: 100.0,
            color: Colors.red,
            child: Center(
              child: Text(query),
            ),
          )
        : Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 100.0,
                  child: Center(
                    child: Text('recent search'),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentCities
        : cities.where((p) => p.startsWith(query)).toList();

    return Container(
      height: MediaQuery.of(context).size.height,
      /*child: ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (BuildContext context,int index){
              return ListTile(
                onTap: (){
                  query=suggestionList[index];
                  hasQuery=true;
                  recentCities.add(suggestionList[index]);
                  showResults(context);
                },
                leading: Icon(Icons.history),
                title: RichText(
                  text: TextSpan(
                    text: suggestionList[index].substring(0,query.length),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.subdirectory_arrow_right),
              );
            },
          ),*/
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.dark,
      primaryTextTheme: theme.textTheme,
    );
  }
}
