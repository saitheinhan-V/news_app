import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {


  final cities=[
    'Myanmar','Malaysia','Singapore','Vietnam','Burma','Australia',
    'America','Burma','Hungary','Holland','Zambia','Thailand','Tanzania','Japan','Korea','Cambodia',
    'Cameron','China','Denmark','Egypt','England','Finland','France','Greece','Italy','Portugal',
    'Russia','Switzerland','Netherland','USA',
  ];
  final recentCities=[
    'Myanmar','Malaysia','Singapore','Vietnam','Burma','Australia',
  ];

  bool hasQuery;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          hasQuery=false;
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return hasQuery? Container(
      width: 100.0,
      height: 100.0,
      color: Colors.red,
      child: Center(
        child: Text(query),
      ),
    ): Container();
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty? recentCities: cities.where((p) => p.startsWith(query)).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context,int index){
        return ListTile(
          onTap: (){
            query=suggestionList[index];
            hasQuery=true;
            recentCities.add(suggestionList[index]);
            showResults(context);
          },
          leading: Icon(Icons.location_city),
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