import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:news/index_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:news/profile/account_management/account_management_page.dart';
import 'package:news/profile/feedback/feedback_page.dart';
import 'package:news/profile/feedback/advice_feedback_page.dart';
import 'package:news/profile/setting/setting_page.dart';
import 'package:news/profile/profile_page.dart';
import 'package:news/profile/register/login_page.dart';
import 'package:news/profile/register/register_page.dart';
import 'package:http/http.dart' as http;
import 'database/database.dart';
import 'models/category.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/profile.register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
        '/accountmanagement': (context) => AccountManagementPage(),
        '/feedback': (context) => FeedbackPage(),
        '/advicefeedback': (context) => AdviceFeedbackPage(),
        '/setting': (context) => SettingPage(),
      },
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}


class _SplashState extends State<Splash> {

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IndexPage()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    new Timer(new Duration(milliseconds: 500), () {
      checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        color: Colors.blue,
        child: Center(
          child: Text('Welcome to News App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ),
    );
  }
}


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();
  bool first=true;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: 'News Info',
        description: "Acknowledge and read information posted by people",
        pathImage: "assets/news.png",
        backgroundColor: Colors.blueGrey,
      ),
    );

    slides.add(
      new Slide(
        title: "News Feeds",
        description: "Watch videos and posts attached by people",
        pathImage: "assets/digital-campaign.png",
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: "Blog",
        description: "Start your own blog by posting videos and posts",
        pathImage: "assets/edit.png",
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
    slides.add(
      new Slide(
        title: "Influencer",
        description: "Become influencer with your own fans",
        pathImage: "assets/mega-influencer.png",
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
    slides.add(
      new Slide(
        title: "Explore And Subscribe",
        description: "Follow people to see more interesting information from theirs blog",
        pathImage: "assets/subscribe.png",
        backgroundColor: Colors.green,
      ),
    );

    //getCategory();
  }

  getCategory() async{
    List<Category> categoryList= await SQLiteDbProvider.db.getCategory();
    if(categoryList.length == 0 ){
      var res = await http.get("http://192.168.0.110:3000//api/category");
      if(res.statusCode ==200){
        var body= jsonDecode(res.body);
        var data=body['data']['category'];
        print("--------" + data.length.toString());
        for(int i=0;i<data.length;i++){
          Category category=new Category(data[i]['Categoryid'], data[i]['Categoryname'], data[i]['Categoryorder']);
          SQLiteDbProvider.db.insertCategory(category);
        }
      }
    }
  }

  void onDonePress() {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => IndexPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}


