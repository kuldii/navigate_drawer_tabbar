import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test_custom/model/tag_model.dart';
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

  Future<Tag> getTag(int tagId) async {
    Database db = await database.db;
    List<Map<String, dynamic>> rawTags = await db.query("tags", where: "id = $tagId");

    return Tag.fromJson(rawTags.first);
  }

  Future<List<Map<String, dynamic>>> getAllProductTags(int productId) async {
    Database db = await database.db;
    List<Map<String, dynamic>> rawProductTags = await db.query("product_tag", where: "product_id = $productId");

    return rawProductTags;
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
                          e.category!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: getAllProductTags(e.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            if (snapshot.data!.isEmpty) {
                              return const SizedBox();
                            }
                            List<Map<String, dynamic>> dataTags = snapshot.data!;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  children: dataTags
                                      .map(
                                        (e) => Container(
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          color: Colors.grey[300],
                                          child: FutureBuilder<Tag>(
                                            future: getTag(e['tag_id']),
                                            builder: (context, snapTag) {
                                              if (snapTag.connectionState == ConnectionState.waiting) {
                                                return const SizedBox();
                                              }
                                              Tag tag = snapTag.data!;
                                              return Text("${tag.title}");
                                            },
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
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
