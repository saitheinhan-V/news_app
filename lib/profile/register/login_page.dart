import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:news/api.dart';
import 'package:news/config/storage_manager.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/user_info.dart';
import 'package:news/profile/register/register_page.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:news/models/user.dart';
import 'package:news/database/database.dart';
import 'package:dio/dio.dart';
import 'package:news/view_models/user_model.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool pwdLogin = true;
  bool authLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('登陆'),
        elevation: 10.0,
        flexibleSpace: FlexibleSpaceBar(
          background: Image(
            image: AssetImage("assets/profile/triangle.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            tooltip: 'Search',
            onPressed: () => debugPrint('Button is pressed.'),
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 25.0,left:25.0, right:25.0),
                  child: Visibility(
                    visible: pwdLogin ? true : false,
                    child: PasswordLoginForm(),
                  ),
              ),
              Container(
                  padding: EdgeInsets.only(left:25.0, right:25.0),
                  child: Visibility(
                    visible: authLogin ? true : false,
                    child: AuthCodeLoginForm(),
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      child:  Text(
                        '密码登陆 ',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: pwdLogin? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight ),
                      ),
                      onTap: () {
                        setState(() {
                          pwdLogin = true;
                          authLogin = false;
                        });
                        print('Pressed login with password');
                        print('pwdLogin: '+ pwdLogin.toString());
                        print('authLogin: ' + authLogin.toString());
                      }
                  ),
                  Text(
                    '/',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  InkWell(
                    child:  Text(
                      ' 验证码登陆',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: authLogin? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight ),
                    ),
                    onTap: () {
                      setState(() {
                        pwdLogin = false;
                        authLogin = true;
                      });
                      print('Pressed login with auth');
                      print('pwdLogin: '+ pwdLogin.toString());
                      print('authLogin: ' + authLogin.toString());
                    },
                  ),

                ],
              ),
              Container(
                //child: GoToRegisterPage(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      '你还没有账号？',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),
                    ),
                    FlatButton(
                      child: Text(
                        '去注册',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        //Navigator.pushNamed(context, "/profile.register");
                        _movedToRegisterPage(context,RegisterPage());
                      },
                      splashColor: Colors.transparent,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _movedToRegisterPage(BuildContext context, RegisterPage registerPage) async{
    User user=await Navigator.push(context, MaterialPageRoute(builder: (context)=> registerPage)) as User;
    //SQLiteDbProvider.db.delete();
    //SQLiteDbProvider.db.insert(user);
    Navigator.pop(context, user);
  }
}


class PasswordLoginForm extends StatefulWidget {
  @override
  _PasswordLoginFormState createState() => _PasswordLoginFormState();
}

class _PasswordLoginFormState extends State<PasswordLoginForm> {
  final loginFormKey = GlobalKey<FormState>();
  String username, password;
  String userName='';
  int userID=0;
  bool autoValidate = false;
  TextEditingController phoneNoController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  ProgressDialog progressDialog;
  User user;

  void submitRegisterForm() {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      debugPrint('username: $username');
      debugPrint('password: $password');

//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text('注册中...'),
//      ));
      //Navigator.pushNamed(context, '/login');
      _logIn(phoneNoController.text, passwordController.text);
    } else {
      setState(() {
        autoValidate = true;
      });
    }

   // _signUp(phoneNoController.text,passwordController.text);
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

  @override
  Widget build(BuildContext context) {

    progressDialog = new ProgressDialog(context);
    progressDialog.style(
        message: 'Logging in...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 3.0,
        insetAnimCurve: Curves.easeInCirc,
        progress: 0.0,
        maxProgress: 10.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 1.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.bold)
    );

    return Form(
      key: loginFormKey,
      child: Column(
        children: <Widget>[
          Text('密码登陆', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: phoneNoController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_android),
              labelText: 'Phone Number',
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
              username = value;
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
              labelText: 'Password',
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
          GestureDetector(
            onTap: (){
              setState(() {

              });
            },
            child: Container(
              width: double.infinity,
              height: 55.0,
              child: RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.blue)
                ),
                child: Text(
                  '登陆',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                elevation: 0.0,
                //onPressed: submitRegisterForm,
                onPressed: (){
                  setState(() {
                    submitRegisterForm();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

//  insertFollower(int id) async{
//    //var followURL='https://firstgitlesson.000webhostapp.com/follower.php';
////    var response= await http.post(followURL,body: {
////      "userID" : userID.toString(),
////    });
//    var response=await http.post("http://192.168.0.110:3000//api/follower",
//      body: {
//      "Userid" : id.toString(),
//      }
//    );
//    if(response.statusCode ==200){
//      var body=jsonDecode(response.body);
//      var data=body['data']['follower'];
//      print('Data Length===='+data.length.toString());
//      SQLiteDbProvider.db.deleteFollower();
//      for(int j=0;j<data.length;j++){
//        //User user=User(j,'null','000','000');
//        Follow follow=new Follow(data[j]['Followid'],data[j]['Userid'],data[j]['Followerid'],data[j]['Followdate']);
//        SQLiteDbProvider.db.insertFollower(follow);
//      }
//    }
//  }

  showAlert(BuildContext context,String message){
    showDialog(
        context: context,
      barrierDismissible: false,
      builder: (BuildContext c){
          return AlertDialog(
            title: Text('Message'),
            content: Text(message),
            actions: <Widget>[
              new FlatButton(
                onPressed: (){
                  Navigator.pop(c);
                  progressDialog.hide();
                },
                child: Text('Ok'),
              ),
            ],
          );
      }
    );
  }

  Future<User> _getUserInfo(String token) async{

    var response=await http.get(Api.INFO_URL,headers: {
      'Authorization' : 'Bearer $token'
    });
      var dataUser=jsonDecode(response.body);
      Map userMap=dataUser['data']['user'];
      User user=User.fromJson(userMap);
      print("Name===="+user.userName);
    return user;

  }

  // get user info:{uid,name,avatorImage,introduction,gender,birthday,phone}
  Future<UserInfo> _getInfo(String token) async {
    var authorizeUrl = Api.USER_PROFILE_INFO_URL;
    UserInfo info;
    var response = await http
        .get(authorizeUrl, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200){
      var userInfo = jsonDecode(response.body);
      Map userMap = userInfo['data']['info'];
      info = UserInfo.fromJson(userMap);
    } else {
      print(response.statusCode);
    }
    return info;
  }

  _logIn(String phone,String password) async{

    progressDialog.show();
    var res= await http.post(Api.LOGIN_URL,body: {
      "Phone" : phone,
      "Password" : password,
    });
    print("Code==="+res.statusCode.toString());
    print("Data=="+res.body.toString());
    var data=jsonDecode(res.body);
    var code=data['code'];
    var msg=data['msg'];
    var token;
    if(code == 200){
      token=data['data']['token'];
      if(token !=null){
        SQLiteDbProvider.db.deleteToken();
        SQLiteDbProvider.db.insertToken(token);
        User user= await _getUserInfo(token);
        UserInfo userInfo = await _getInfo(token);
        //UserModel().saveUser(user);
       // StorageManager.sharedPreferences.setInt('userid', user.userID);
        //StorageManager.localStorage.setItem("user", user.toJSONEncodable());
         //insertFollower(user.userID);

        SQLiteDbProvider.db.delete();
        SQLiteDbProvider.db.insert(user);
        SQLiteDbProvider.db.insertUserInfo(userInfo);
        progressDialog.hide();
        Navigator.pop(context , user);
      }
    }else{
      progressDialog.hide();
      showAlert(context, msg);
    }
  }
}

class AuthCodeLoginForm extends StatefulWidget {
  @override
  _AuthCodeLoginFormState createState() => _AuthCodeLoginFormState();
}

class _AuthCodeLoginFormState extends State<AuthCodeLoginForm> {
  final registerFormKey = GlobalKey<FormState>();
  String username, password;
  bool autoValidate = false;
  bool isButtonEnable = true; // 按钮状态是否可点击
  String buttonText = "发送验证码"; // 初始文本
  int count = 60; // 初始倒计时时间
  Timer timer; // 倒计时的计时器
  TextEditingController mController = TextEditingController();

  void _buttonClickListen(){
    setState(() {
      if(isButtonEnable){   //当按钮可点击时
        isButtonEnable=false; //按钮状态标记
        _initTimer();
        return null;   //返回null按钮禁止点击
      }else{     //当按钮不可点击时
        return null;    //返回null按钮禁止点击
      }
    });
  }


  void _initTimer(){
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count--;
      setState(() {
        if(count==0){
          timer.cancel();    //倒计时结束取消定时器
          isButtonEnable=true;  //按钮可点击
          count=60;     //重置时间
          buttonText='发送验证码';  //重置按钮文本
        }else{
          buttonText='重新发送($count)'; //更新文本内容
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();  //销毁计时器
    timer=null;
    super.dispose();
  }

  void submitRegisterForm() {
    if (registerFormKey.currentState.validate()) {
      registerFormKey.currentState.save();
      debugPrint('username: $username');
      debugPrint('password: $password');

//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text('注册中...'),
//      ));

      Navigator.pushNamed(context, '/login');
    } else {
      setState(() {
        autoValidate = true;
      });
    }
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
  @override
  Widget build(BuildContext context) {
    return Form(
      key: registerFormKey,
      child: Column(
        children: <Widget>[
          Text('验证码登陆', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
          SizedBox(
            height: 20,
          ),
          TextFormField(
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
              username = value;
            },
            validator: validateUsername,
            autovalidate: autoValidate,
          ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            decoration: InputDecoration(
              prefixText: '验证码',
              labelText: '密码',
              suffix: Container(

              ),
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
                  side: BorderSide(color: Colors.blue)
              ),
              child: Text(
                '登陆',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              elevation: 0.0,
              onPressed: submitRegisterForm,
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

class GoToRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        Text(
          '你还没有账号？',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),
        ),
        FlatButton(
          child: Text(
            '去注册',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            //Navigator.pushNamed(context, "/profile.register");
            //_movedToRegisterPage(context,RegisterPage());
          },
          splashColor: Colors.transparent,
        ),
      ],
    );
  }
}
