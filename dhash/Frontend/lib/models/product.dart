// dhash_frontend/lib/models/product.dart

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int currentStock;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currentStock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Note: Assurez-vous que les types correspondent à ceux de votre API
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      // Convertir 'price' en double (il est possible qu'il soit envoyé comme String ou double/int)
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currentStock: json['current_stock'] as int,
      imageUrl: json['image_url'] as String? ?? 'https://via.placeholder.com/150',
    );
  }
}