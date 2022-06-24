import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';

class DetailTabPage extends StatefulWidget {
  const DetailTabPage({Key? key, required this.allProducts, required this.selected}) : super(key: key);

  final List<Product> allProducts;
  final int selected;

  @override
  State<DetailTabPage> createState() => _DetailTabPageState();
}

class _DetailTabPageState extends State<DetailTabPage> with SingleTickerProviderStateMixin {
  late TabController tabC = TabController(
    length: widget.allProducts.length,
    vsync: this,
    initialIndex: widget.selected,
  );

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
          tabs: widget.allProducts
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
            itemCount: widget.allProducts.length,
            itemBuilder: (context, index) {
              Product product = widget.allProducts[index];
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
        children: widget.allProducts
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
  }
}
