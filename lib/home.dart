import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController tabC;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Product>> getAllProduct() async {
    final dataString = await rootBundle.loadString('assets/myproduct.json');
    final List<dynamic> rawData = jsonDecode(dataString);
    List<Product> allProduct = Product.fromJsonList(rawData);
    tabC = TabController(length: allProduct.length, vsync: this);
    return allProduct;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: getAllProduct(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('MY STORE'),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('MY STORE'),
              centerTitle: true,
            ),
            body: const Center(
              child: Text("Tidak ada data"),
            ),
          );
        }
        List<Product> allProduct = snap.data!;
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: const Text('MY STORE'),
            centerTitle: true,
            bottom: TabBar(
              controller: tabC,
              isScrollable: true,
              tabs: allProduct
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
                itemCount: allProduct.length,
                itemBuilder: (context, index) {
                  Product product = allProduct[index];
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
            children: allProduct
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
