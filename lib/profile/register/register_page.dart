import 'package:flutter/material.dart';
import 'package:news/models/follow.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news/models/user.dart';
import 'package:news/database/database.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('注册'),
        elevation: 10.0,
        flexibleSpace: FlexibleSpaceBar(
          background: Image(
            image: AssetImage("assets/profile/triangle.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
      body: Container(
        //color: Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.all(25.0),
              child: RegisterFormDemo(),
            ),
            Container(child: GoToLoginPage()),
          ],
        ),
      ),
    );
  }
}

class AppBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Image.asset(
          "assets/profile/triangle.png",
          width: double.infinity,
          height: 130.0,
          fit: BoxFit.fill,
        ),
        Positioned(
          top: 35.0,
          left: 20.0,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.arrow_back_ios,
                size: 30.0,
              ),
              Text(
                'Back',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        Positioned(
          top: 35.0,
          right: 20.0,
          child: Icon(
            Icons.more_horiz,
            size: 30.0,
          ),
        ),
        Positioned(
          top: 65.0,
          child: Text(
            '注册',
            style: TextStyle(fontSize: 28.0),
          ),
        ),
      ],
    );
  }
}

class RegisterFormDemo extends StatefulWidget {
  @override
  _RegisterFormDemoState createState() => _RegisterFormDemoState();
}

class _RegisterFormDemoState extends State<RegisterFormDemo> {
  final registerFormKey = GlobalKey<FormState>();
  String userName, password, phone;
  int userID = 0;
  String iMEI = '00000000';
  bool autoValidate = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ProgressDialog pr;
  var baseUrl = "http://192.168.0.110:8081/user";

  void submitRegisterForm() {
    if (registerFormKey.currentState.validate()) {
      registerFormKey.currentState.save();
      debugPrint('username: $userName');
      debugPrint('password: $password');

//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text('注册中...'),
//      ));

      //Navigator.pushNamed(context, '/login');
      setState(() {
        _signUp(
            nameController.text, phoneController.text, passwordController.text);
      });
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  Future<List> checkUser(String text1, String text2, String text3) async {
    var loginUrl = 'https://firstgitlesson.000webhostapp.com/account_login.php';
    var response = await http.post(loginUrl, body: {
      "phone": text2,
      "password": text3,
    });
    var data = jsonDecode(response.body);
    return data;
  }

  insertFollower(int id) async {
    var response = await http.post(baseUrl + "/" + id.toString());
    var data = jsonDecode(response.body);
    print('Data Length====' + data.length.toString());
    SQLiteDbProvider.db.deleteFollower();
    for (int j = 0; j < data.length; j++) {
      //User user=User(j,'null','000','000');
      Follow follow = new Follow(data[j]['Followid'], data[j]['Userid'],
          data[j]['Followerid'], data[j]['Followdate']);
      SQLiteDbProvider.db.insertFollower(follow);
    }
  }

  Future<List<User>> getUser(String ph, String pw) async {
    List<User> userLists = List<User>();
    var res = await http.post(baseUrl + "/" + ph + "/" + pw);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data.length != 0) {
        User user = User(
            data['Userid'], data['Username'], data['Password'], data['Phone']);
        userLists.add(user);
      }
    }
    return userLists;
  }

  Future<User> _getUserInfo(String token) async {
    var authorizeUrl = "http://10.0.2.2:3000/api/auth/info";

    var response = await http
        .get(authorizeUrl, headers: {'Authorization': 'Bearer $token'});
    var dataUser = jsonDecode(response.body);
    Map userMap = dataUser['data']['user'];
    User user = User.fromJson(userMap);
    print("Name====" + user.userName);
    return user;
  }

  _signUp(String name, String phoneNo, String passWord) async {
    var registerUrl = "http://10.0.2.2:3000/api/auth/register";

//    List<User> usersData= await getUser(phoneNo, passWord);
//    User users=usersData[0];
//      if(users.userID != 0){
//        print('User already exist');
//
//      }else{
//        print('User doesnot exist');
//        var res= await http.post(baseUrl+"/"+name+"/"+phoneNo+"/"+passWord);
//        if(res.statusCode == 200){
//          print("Account creation success");
//          List<User> userData= await getUser(phoneNo,passWord);
//          if(userData.length!=0){
//            User user=userData[0];
//            insertFollower(user.userID);
//            SQLiteDbProvider.db.delete();
//            SQLiteDbProvider.db.insert(user);
//            Navigator.pop(context , user);
//          }
//          //progressDialog.hide();
//        }
//      }

    var res = await http.post(registerUrl, body: {
      "Username": name,
      "Phone": phoneNo,
      "Password": passWord,
    });
    print("Code===" + res.statusCode.toString());
    print("Data==" + res.body.toString());
    var data = jsonDecode(res.body);
    var code = data['code'];
    var msg = data['msg'];
    var token;
    if (code == 200) {
      token = data['data']['token'];
      if (token != null) {
        SQLiteDbProvider.db.deleteToken();
        SQLiteDbProvider.db.insertToken(token);
        User user = await _getUserInfo(token);
        //insertFollower(user.userID);
        SQLiteDbProvider.db.delete();
        SQLiteDbProvider.db.insert(user);
        Navigator.pop(context, user);
      }
    }
    print(msg + "===" + token);
    //progressDialog.hide();
    //pr.show();
    //var loginUrl='https://firstgitlesson.000webhostapp.com/account_login.php';
    //var selectUrl='https://firstgitlesson.000webhostapp.com/select.php';
    //var response = await http.get(Uri.encodeFull(selectUrl),headers: {"Accept":"application/json"});
//    print(nameController.text+ passwordController.text);
//    Future<List> futureList=checkUser(name, phoneNo, passWord);
//    List dataUser= await futureList;
//    print("User=======");
//    if(dataUser.length==0){
//      print('000000000000000');
//      //insert into database for new user
//      var signUpUrl='https://firstgitlesson.000webhostapp.com/account_signup.php';
//      http.post(signUpUrl,body: {
//        "username" : nameController.text,
//        "password": passwordController.text,
//        "phone" : phoneController.text,
//        "imei" : iMEI,
//      });
//      //get user info after insert
//      Future<List> futureList=checkUser(name, phoneNo, passWord);
//      List data= await futureList;
//      if(data.length!=0){
//        //if(phoneNo==data[0]['phone'] && passWord==data[0]['password']){
//        userID=int.parse(data[0]['userID']);
//        userName=data[0]['userName'];
//        User user=User(userID,userName,data[0]['password'],data[0]['phone']);
//        //print(data[0]['userID'].toString() + data[0]['userName'] + data[0]['phone']);
//        print('Register success!');
//        SQLiteDbProvider.db.delete();
//        SQLiteDbProvider.db.insert(user);
//        Navigator.pop(context , user);
//        //}
//      }else{
//        print('Failed to register!');
//      }
//    }else{
//      print('11111111111111');
//      print('Already Registered');
//    }
  }

  String validateUsername(value) {
    if (value.isEmpty) {
      return '手机号不能为空!';
    }
    return null;
  }

  String validatePassword(value) {
    if (value.isEmpty) {
      return '密码不能为空!';
    }
    return null;
  }

  String validatePhone(value) {
    if (value.isEmpty) {
      return '密码不能为空!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: registerFormKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            // obscure --> 隐藏
            controller: nameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Username',
              helperText: '',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
            onSaved: (value) {
              phone = value;
            },
            validator: validatePhone,
            autovalidate: autoValidate,
          ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_android),
              labelText: '手机号',
              hintText: '',
              helperText: '',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
            onSaved: (value) {
              userName = value;
            },
            validator: validateUsername,
            autovalidate: autoValidate,
          ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            // obscure --> 隐藏
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              labelText: '输入验证码',
              helperText: '',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
            onSaved: (value) {
              password = value;
            },
            validator: validatePassword,
            autovalidate: autoValidate,
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            width: double.infinity,
            height: 55.0,
            child: RaisedButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.blue)),
              child: Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              elevation: 0.0,
              onPressed: () {
                setState(() {
                  submitRegisterForm();
                });
              },
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }
}

class GoToLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '你已有账号了？',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),
        ),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(
          child: Text(
            '去登陆',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent),
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
          splashColor: Colors.transparent,
        ),
      ],
    );
  }
}
