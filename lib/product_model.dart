class Product {
  int? id;
  String? title;
  String? description;
  String? category;
  int? price;

  Product({this.id, this.title, this.description, this.category, this.price});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    category = json['category'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['category'] = category;
    data['price'] = price;
    return data;
  }

  static List<Product> fromJsonList(List? data) {
    if (data == null) {
      return [];
    }
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
