import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/pages/detail/detail_tab.dart';
import 'package:test_custom/model/product_model.dart';
import 'package:test_custom/pages/favorite/favorite.dart';
import 'package:test_custom/sqflite/db_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseManager database;
  Future<List<Product>> getAllProducts() async {
    Database db = await database.db;
    List<Map<String, dynamic>> rawProducts = await db.query("products");

    return Product.fromJsonList(rawProducts);
  }

  @override
  void initState() {
    database = DatabaseManager.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY STORE'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoritePage(),
                ),
              );
            },
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: getAllProducts(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text("Tidak ada data"),
            );
          }
          List<Product> allProduct = snap.data!;
          return ListView.builder(
            itemCount: allProduct.length,
            itemBuilder: (context, index) {
              Product product = allProduct[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailTabPage(
                        totalProducts: allProduct.length,
                        selected: index,
                      ),
                    ),
                  );
                },
                title: Text(product.title!),
              );
            },
          );
        },
      ),
    );
  }
}
