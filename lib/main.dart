import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/model/product_model.dart';
import 'package:test_custom/model/tag_model.dart';
import 'package:test_custom/sqflite/db_manager.dart';
import 'pages/home/home.dart';

Future<List<Tag>> generateTags() async {
  List<String> dataTags = [
    "Laptop",
    "Perangkat Keras",
    "Perangkat Lunak",
    "Komputer Kantor",
    "PC Gaming",
    "Bluetooth Device",
    "Audio Device",
  ];

  List<Tag> allTags = List.generate(
    dataTags.length,
    (index) => Tag(id: index + 1, title: dataTags[index]),
  );

  return allTags;
}

Future<List<Product>> getAllProductsFromAsset() async {
  final dataProducts = await rootBundle.loadString('assets/myproduct.json');
  final List<dynamic> rawDataProduct = jsonDecode(dataProducts);
  List<Product> allProducts = Product.fromJsonList(rawDataProduct);
  return allProducts;
}

Future<void> storeAssetTag(DatabaseManager database, List<Tag> allTags) async {
  Database db = await database.db;

  // Check data dulu, jika belum ada maka kita tambahkan ke db
  List checkdata = await db.query("tags");
  if (checkdata.isEmpty) {
    // insert all asset to local db (sqflite)
    for (Tag tag in allTags) {
      db.insert(
        "tags",
        {
          "id": tag.id,
          "title": tag.title,
        },
      );
    }
  }
}

Future<void> storeProductTag(DatabaseManager database, List<Product> allProducts, List<Tag> allTags) async {
  Database db = await database.db;

  // Check data dulu, jika belum ada maka kita tambahkan ke db
  List checkdata = await db.query("product_tag");
  if (checkdata.isEmpty) {
    List<List<int>> customProductTag = [
      [1, 4, 5], // Product 1 => Tags ID ([1, 4, 5])
      [1, 4], // Product 2 => Tags ID ([1, 4])
      [1, 4], // Product 3 => Tags ID ([1, 4])
      [2, 6], // Product 4 => Tags ID ([2, 6])
      [2, 7], // Product 5 => Tags ID ([2, 7])
      [2, 6], // Product 6 => Tags ID ([2, 6])
      [3], // Product 7 => Tags ID ([3])
      [3], // Product 8 => Tags ID ([3])
    ];
    // insert all product tag to local db (sqflite)
    for (int i = 1; i <= customProductTag.length; i++) {
      List<int> tags = customProductTag[i - 1];

      for (int x = 1; x <= tags.length; x++) {
        await db.insert(
          "product_tag",
          {
            "product_id": i,
            "tag_id": tags[x - 1],
          },
        );
      }
    }
  }
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

  // Initial SQFLITE
  DatabaseManager database = DatabaseManager.instance;

  // =============================

  // Generate data tag before run apps
  List<Tag> allTags = await generateTags();

  // Store tag into sqflite
  await storeAssetTag(database, allTags);

  // =============================

  // Get data product from asset before run apps
  List<Product> allProducts = await getAllProductsFromAsset();

  // Store asset product into sqflite
  await storeAssetProduct(database, allProducts);

  // =============================

  // Product tag into sqflite
  await storeProductTag(database, allProducts, allTags);

  // ** FOR TESTING ONLY (CHECK DATABASE SQFLITE) **
  // Database db = await database.db;
  // print(await db.query("products"));
  // print("");
  // print(await db.query("tags"));
  // print("");
  // print(await db.query("product_tag"));

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
