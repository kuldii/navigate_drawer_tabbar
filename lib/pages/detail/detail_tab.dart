import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/sqflite/db_manager.dart';
import '../../model/product_model.dart';

class DetailTabPage extends StatefulWidget {
  const DetailTabPage({Key? key, required this.totalProducts, required this.selected}) : super(key: key);

  final int totalProducts;
  final int selected;

  @override
  State<DetailTabPage> createState() => _DetailTabPageState();
}

class _DetailTabPageState extends State<DetailTabPage> with SingleTickerProviderStateMixin {
  late DatabaseManager database;
  late TabController tabC = TabController(length: widget.totalProducts, vsync: this, initialIndex: widget.selected);

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Product>> getAllProducts() async {
    Database db = await database.db;
    List<Map<String, dynamic>> rawProducts = await db.query("products");

    return Product.fromJsonList(rawProducts);
  }

  Future<void> toogleFavorite(int id, int favorite) async {
    Database db = await database.db;
    await db.update(
      "products",
      {
        "favorite": (favorite == 1) ? 0 : 1,
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
    return FutureBuilder<List<Product>>(
      future: getAllProducts(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(
            child: Text("Tidak ada data"),
          );
        }
        List<Product> allProducts = snap.data!;
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('MY STORE'),
            centerTitle: true,
            bottom: TabBar(
              controller: tabC,
              isScrollable: true,
              tabs: allProducts
                  .map(
                    (e) => Tab(
                      text: e.title,
                    ),
                  )
                  .toList(),
            ),
          ),
          endDrawer: Drawer(
            child: SafeArea(
              child: ListView.builder(
                itemCount: allProducts.length,
                itemBuilder: (context, index) {
                  Product product = allProducts[index];
                  return ListTile(
                    onTap: () {
                      scaffoldKey.currentState!.closeEndDrawer();
                      tabC.animateTo(index);
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(product.title!),
                  );
                },
              ),
            ),
          ),
          body: TabBarView(
            controller: tabC,
            children: allProducts
                .map(
                  (e) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Rp ${NumberFormat.currency(locale: "id_ID").format(e.price!).replaceAll("IDR", "")}",
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            e.description!,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          e.category!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              toogleFavorite(e.id!, e.favorite!);
                            });
                          },
                          icon: Icon((e.favorite == 1) ? Icons.favorite : Icons.favorite_border),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
