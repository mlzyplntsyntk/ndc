import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Db {
  Db._();
  static final Db db = Db._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");

    return await openDatabase(path, 
      version: 3, 
      onOpen: (db) {}, 
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE json_data ("
          "id INTEGER PRIMARY KEY,"
          "content_type TEXT,"
          "content TEXT"
          ")");

        await db.execute("CREATE TABLE session_details ("
          "id INTEGER PRIMARY KEY,"
          "is_fav INTEGER,"
          "link TEXT,"
          "detail TEXT"
        ")");
      },
      onUpgrade: (Database db, int version, int test) async {
        
      }
    );
  }

}
