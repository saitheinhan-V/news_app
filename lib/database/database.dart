import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:news/models/category.dart';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
import 'package:news/models/token.dart';
import 'package:news/models/user_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:news/models/user.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "News.db");
    return await openDatabase(
        path,
        version: 2,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE User ("
              "userID INTEGER,"
              "userName TEXT,"
              "phone TEXT,"
              "password TEXT,"
              "createDate TEXT,"
              "profilePic TEXT,"
              "IMEI TEXT,"
              "QQ TEXT,"
              "sex int,"
              "email TEXT,"
              "address TEXT,"
              "birthday TEXT,"
              "introduction TEXT"
              ")"
          );

          await db.execute("CREATE TABLE Follow ("
              "followID INTEGER,"
              "userID INTEGER,"
              "followerID INTEGER,"
              "followDate DATETIME"
              ")"
          );

          await db.execute("CREATE TABLE Token ("
            "id INTEGER PRIMARY KEY,"
              "value TEXT"
              ")"
          );

          await db.execute("CREATE TABLE Following ("
              "userID INTEGER,"
              "userName TEXT,"
              "phone TEXT,"
              "password TEXT,"
              "createDate TEXT,"
              "profilePic TEXT,"
              "IMEI TEXT,"
              "QQ TEXT,"
              "sex int,"
              "email TEXT,"
              "address TEXT,"
              "birthday TEXT,"
              "introduction TEXT"
              ")"
          );

          await db.execute("CREATE TABLE Category("
             "categoryID INTEGER,"
              "categoryName TEXT,"
              "categoryOrder INTEGER"
              ")"
          );

          await db.execute("CREATE TABLE UserInfo ("
              "uid INTEGER PRIMARY KEY,"
              "userName TEXT,"
              "avatorImage TEXT,"
              "introduction TEXT,"
              "gender INT,"
              "birthday TEXT,"
              "phone TEXT"
              ")");




          //db.execute("insert into quotes (quote, author) values ('Be happy in the moment, that’s enough. Each moment is all we need, not more.', 'Mother Teresa')");
          // db.execute("insert into quotes (quote, author) values ('Be here now', 'Ram Dass')");

          //await db.execute("INSERT INTO User ('userID', 'userName', 'password', 'phone') values( 1, 'SSS', '100100','100100')");
         // await db.execute("INSERT INTO User ('userID', 'userName', 'password', 'phone') values( 2, 'S', '100','100')");
          //await db.execute("INSERT INTO Product ('id', 'name', 'description', 'price','image') values (?, ?, ?, ?, ?)",[2, "Pixel", "Pixel is the most feature phone ever", 800,"pixel.png"]);
          //await db.execute("INSERT INTO Product ('id', 'name', 'description', 'price','image') values (?, ?, ?, ?, ?)", [3, "Laptop", "Laptop is most productive development tool", 2000, "laptop.jpg"]);
          //await db.execute("INSERT INTO Product ('id', 'name', 'description', 'price','image') values (?, ?, ?, ?, ?)", [4, "Tablet", "Laptop is most productive development tool", 1500, "tablet.png"]);
         // await db.execute("INSERT INTO Product ('id', 'name', 'description', 'price','image') values (?, ?, ?, ?, ?)", [5, "Pendrive", "Pendrive is useful storage medium", 100, "pendrive.jpeg"]);
         // await db.execute("INSERT INTO Product ('id', 'name', 'description', 'price','image') values (?, ?, ?, ?, ?)",[6, "Floppy Drive", "Floppy drive is useful rescue storagemedium", 20, "floppy.jpeg"]);
        });
  }

  Future<List<User>> getUser() async {
    final db = await database;
    //List<Map> results = await db.query("User", columns: User.columns, orderBy: "userID ASC");
    List<Map> results = await db.query("User", columns: User.columns);
    List<User> users = new List();
    results.forEach((result) {
      User user = User.fromMap(result);
      users.add(user);
    });
    return users;
  }

  Future<List<Category>> getCategory() async {
    final db = await database;
    List<Map> results = await db.query("Category", columns: Category.columns);
    List<Category> categories = new List<Category>();
    results.forEach((result) {
      Category category = Category.fromMap(result);
      categories.add(category);
    });
    return categories;
  }



  Future<List<Follow>> getFollower() async{
    final db = await database;
    List<Map> results= await db.query("Follow", columns: Follow.columns);
    List<Follow> follows= new List();
    results.forEach((result){
      Follow follow = Follow.fromMap(result);
      follows.add(follow);
    });
    return follows;
  }

  Future<List<Following>> getFollowing() async{
    final db = await database;
    List<Map> results= await db.query("Following", columns: Following.columns);
    List<Following> follows= new List();
    results.forEach((result){
      Following following = Following.fromMap(result);
      follows.add(following);
    });
    return follows;

  }

  Future<Following> getFollowingById(int id) async{
    final db=await database;
    var result= await db.rawQuery("SELECT * FROM Following WHERE userID = $id ");
    if(result.length >0){
      return new Following.fromMap(result.first);
    }
    else{
      return null;
    }
  }

  Future<List<Token>> getToken() async{
    final db = await database;
    List<Map> results= await db.query("Token", columns: Token.columns);
    List<Token> tokens= new List();
    results.forEach((result){
      Token token = Token.fromMap(result);
      tokens.add(token);
    });
    return tokens;
  }

  Future<UserInfo> getUserInfo() async {
    final db = await database;
    List<Map> results = await db.query("UserInfo", columns: UserInfo.columns);
    UserInfo info;
    results.forEach((result) {
      UserInfo userInfo = UserInfo.fromMap(result);
      info = userInfo;
    });
    return info;
  }

  Future<String> getTokenString() async {
    final db = await database;
    String str;
    List<Map> results = await db.query("Token", columns: Token.columns);
    results.forEach((result) {
      Token token = Token.fromMap(result);
      str = token.value;
    });
    return str;
  }

  Future<void> updateUserInfo(UserInfo userInfo) async {
    print("Updating UserInfo in MYSQLite................");
    final db = await database;
    print("DB Connecting..............");
    await db.update(
      "UserInfo",
      userInfo.toMap(),
      where: "uid = ?",
      whereArgs: [userInfo.uid],
    );
    print("MYSQLite UserInfo table updated!");
  }

  insertUserInfo(UserInfo userInfo) async {
    print("Inserting UserInfo in MYSQLite................");
    final db = await database;
    print("DB Connecting..............");
    var result = await db.rawInsert(
        "INSERT Into UserInfo (uid, userName, avatorImage, introduction, gender, birthday, phone) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [
          userInfo.uid,
          userInfo.userName,
          userInfo.avatorImage,
          userInfo.introduction,
          userInfo.gender,
          userInfo.birthday,
          userInfo.phone
        ]);
    print("MYSQLite UserInfo table inserted!");
    return result;
  }


//  Future<Product> getProductById(int id) async {
//    final db = await database;
//    var result = await db.query("Product", where: "id = ", whereArgs:
//    [id]);
//    return result.isNotEmpty ? Product.fromMap(result.first) : Null;
//  }


  insert(User user) async {
    final db = await database;
    //var maxIdResult = await db.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM User");
    //var id = maxIdResult.first["last_inserted_id"];
    var result = await db.rawInsert(
        "INSERT Into User (userID, userName, phone, password, createDate, profilePic, IMEI, QQ, sex, email, address, birthday, introduction) VALUES (?, ?, ?, ?, ?,?,?,?,?,?,?,?,?)",
        [user.userID, user.userName, user.phone, user.password, user.createDate, user.profilePic, user.IMEI, user.QQ, user.sex, user.email, user.address, user.birthday, user.introduction]);

    return result;
  }

  insertFollower(Follow follow) async{
    final db = await database;
    var result = await db.rawInsert(
      "INSERT Into Follow (followID, userID, followerID, followDate) VALUES (?, ?, ?, ?)", [follow.followID, follow.userID, follow.followerID, follow.followDate]
    );
    return result;
  }

  insertCategory(Category category) async{
    final db = await database;
    var result = await db.rawInsert(
        "INSERT Into Category (categoryID, categoryName, categoryOrder ) VALUES (?, ?, ?)", [category.categoryID,category.categoryName,category.categoryOrder]
    );
    return result;
  }


  insertFollowing(Following following) async{
    final db = await database;
    var result= await db.rawInsert(
      "INSERT Into Following (userID, userName, phone, password, createDate, profilePic, IMEI, QQ, sex, email, address, birthday, introduction) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
      [following.userID,following.userName,following.phone,following.password,following.createDate,following.profilePic,following.IMEI,following.QQ,
      following.sex,following.email,following.address,following.birthday,following.introduction]
    );
    return result;
  }

  insertToken(String token) async{
    final db = await database;
    var result = await db.rawInsert(
      "INSERT Into Token (id, value) VALUES (?, ?)", [ 1, token]
    );
    return result;
  }

  deleteFollower() async{
    final db= await database;
    db.delete("Follow");
  }

  Future<int> deleteFollowingById(int id) async {
    final db= await database;
    return await db.delete("Following", where: 'userID = ?', whereArgs: [id]);
  }

  deleteFollowing() async{
    final db = await database;
    db.delete("Following");
  }

  deleteToken() async{
    final db= await database;
    db.delete("Token");
  }

  deleteCategory() async{
    final db= await database;
    db.delete("Category");
  }


//  update(Product product) async {
//    final db = await database;
//    var result = await db.update("Product", product.toMap(),
//        where: "id = ?", whereArgs: [product.id]);
//    return result;
//  }


//  delete(int id) async {
//    final db = await database;
//    db.delete("Product", where: "id = ?", whereArgs: [id]);
//  }

delete() async{
    final db= await database;
    db.delete("User");
}

}






