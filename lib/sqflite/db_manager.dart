import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  DatabaseManager._privateConstructor();
  static DatabaseManager instance = DatabaseManager._privateConstructor();

  Database? _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initDB();
      return _db!;
    } else {
      return _db!;
    }
  }

  Future initDB() async {
    Directory documentDir = await getApplicationDocumentsDirectory();

    String path = join(documentDir.path, "product.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, versi) async {
        await db.execute(
          '''
            CREATE TABLE products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              price INTEGER NOT NULL,
              favorite INTEGER DEFAULT 0,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              category TEXT NOT NULL
            )
          ''',
        );
        await db.execute(
          '''
            CREATE TABLE tags (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL
            )
          ''',
        );
        await db.execute(
          '''
            CREATE TABLE product_tag (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              product_id INTEGER NOT NULL,
              tag_id INTEGER NOT NULL
            )
          ''',
        );
      },
    );
  }

  Future closeDB() async {
    _db = await instance.db;
    _db!.close();
  }
}
