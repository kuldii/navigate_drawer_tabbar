import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/model/product_model.dart';
import 'package:test_custom/sqflite/db_manager.dart';
import 'pages/home/home.dart';

Future<List<Product>> getAllProductsFromAsset() async {
  final dataString = await rootBundle.loadString('assets/myproduct.json');
  final List<dynamic> rawData = jsonDecode(dataString);
  List<Product> allProducts = Product.fromJsonList(rawData);
  return allProducts;
}

Future<void> storeAssetProduct(DatabaseManager database, List<Product> allProducts) async {
  Database db = await database.db;

  // Check data dulu, jika belum ada maka kita tambahkan ke db
  List checkdata = await db.query("products");
  if (checkdata.isEmpty) {
    // insert all asset to local db (sqflite)
    for (Product product in allProducts) {
      db.insert(
        "products",
        {
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "category": product.category,
        },
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get data from asset before run apps
  List<Product> allProducts = await getAllProductsFromAsset();

  // Initial SQFLITE
  DatabaseManager database = DatabaseManager.instance;

  // Store asset into sqflite
  await storeAssetProduct(database, allProducts);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
