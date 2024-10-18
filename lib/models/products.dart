class Products {
  final String name;
  final String description;
  final double price;
  final String currency;
  final String category;
  final String sku;
  int stock;
  final List<String> tags;

  Products({
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.sku,
    required this.stock,
    required this.tags,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      name: json['name'],
      description: json['description'],
      price: json['price']['amount'],
      currency: json['price']['currency'],
      category: json['category'],
      sku: json['sku'],
      stock: json['stock'],
      tags: List<String>.from(json['tags']),
    );
  }
}
