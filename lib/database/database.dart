import 'dart:async';
import 'dart:io';
import 'package:news/models/follow.dart';
import 'package:news/models/following.dart';
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
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE User ("
              "userID INTEGER PRIMARY KEY,"
              "userName TEXT,"
              "password TEXT,"
              "phone TEXT"
              ")"
          );

          await db.execute("CREATE TABLE Follow ("
              "followID INTEGER,"
              "userID INTEGER,"
              "followerID INTEGER,"
              "followDate DATETIME"
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
        "INSERT Into User (userID, userName, password, phone) VALUES (?, ?, ?, ?)", [user.userID, user.userName, user.password, user.phone]);
    return result;
  }

  insertFollower(Follow follow) async{
    final db = await database;
    var result = await db.rawInsert(
      "INSERT Into Follow (followID, userID, followerID, followDate) VALUES (?, ?, ?, ?)", [follow.followID, follow.userID, follow.followerID, follow.followDate]
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

  deleteFollower() async{
    final db= await database;
    db.delete("Follow");
  }

  deleteFollowing() async{
    final db = await database;
    db.delete("Following");
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






