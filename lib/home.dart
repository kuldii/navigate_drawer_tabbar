import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late List<Product> allProduct;
  late TabController tabC;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> data = [
    {
      "name": "Asus ROG GL503GE",
      "price": 15000000,
    },
    {
      "name": "Acer Aspire",
      "price": 9000000,
    },
    {
      "name": "Macbook M1",
      "price": 19000000,
    },
    {
      "name": "Logitech Mouse",
      "price": 190000,
    },
    {
      "name": "Blue Yeti",
      "price": 2500000,
    },
    {
      "name": "Simbadda",
      "price": 5500000,
    },
    {
      "name": "MS Office 365",
      "price": 1000000,
    },
    {
      "name": "Linux Ubuntu",
      "price": 200000,
    },
  ];

  @override
  void initState() {
    allProduct = List.generate(
      data.length,
      (index) {
        return Product(
          id: index,
          name: data[index]["name"],
          price: data[index]["price"],
          desc:
              "Ini deskripsi untuk produk ${data[index]["name"]} yang akan dijual dengan harga Rp ${(NumberFormat.currency(locale: "id_ID").format(data[index]["price"])).replaceAll("IDR", "")}. Buruan dibeli, tunggu apa lagi CHECK OUT SEKARANG !!",
        );
      },
    );
    tabC = TabController(length: allProduct.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  text: e.name,
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
                title: Text(product.name!),
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
                      e.name!,
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
                        e.desc!,
                        textAlign: TextAlign.center,
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
