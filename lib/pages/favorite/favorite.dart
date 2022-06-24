import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/model/product_model.dart';
import 'package:test_custom/sqflite/db_manager.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late DatabaseManager database;
  Future<List<Product>> getAllProducts() async {
    Database db = await database.db;
    List<Map<String, dynamic>> rawProducts = await db.query(
      "products",
      where: "favorite = 1",
    );

    return Product.fromJsonList(rawProducts);
  }

  Future<void> removeFavorite(int id) async {
    Database db = await database.db;
    await db.update(
      "products",
      {
        "favorite": 0,
      },
      where: "id = $id",
    );
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
        title: const Text('MY FAVORITE'),
        centerTitle: true,
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
                title: Text(product.title!),
                subtitle: Text("Rp ${NumberFormat.currency(locale: "id_ID").format(product.price!).replaceAll("IDR", "")}"),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Delete Favorite",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Are you sure to delete this item ?",
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("CANCEL"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await removeFavorite(product.id!).then(
                                            (value) => Navigator.pop(context),
                                          );
                                          setState(() {});
                                        },
                                        child: const Text("DELETE"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });

                    // setState(() {
                    //   removeFavorite(product.id!);
                    // });
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
