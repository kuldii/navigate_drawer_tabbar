import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_custom/detail_tab.dart';
import 'package:test_custom/product_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<Product>> getAllProduct() async {
      final dataString = await rootBundle.loadString('assets/myproduct.json');
      final List<dynamic> rawData = jsonDecode(dataString);
      List<Product> allProduct = Product.fromJsonList(rawData);
      return allProduct;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY STORE'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: getAllProduct(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snap.hasData) {
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
                        allProducts: allProduct,
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
