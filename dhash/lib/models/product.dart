class Category {
  final int? id;
  final int ownerId;
  final String title;
  final String description;
  final String? imageUrl;
  // ... autres champs

  Category({this.id, required this.ownerId, required this.title, required this.description, this.imageUrl});
  
  // Fonction utilitaire pour convertir un résultat MySQL en objet Dart
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }
}

class Product {
  final int? id;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final int currentStock;
  final String mainImageUrl;
  final bool isPublic;
  final bool isValidated;
  // ... autres champs

  Product({
    this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.currentStock,
    required this.mainImageUrl,
    this.isPublic = false,
    this.isValidated = false,
  });

  // Fonction utilitaire pour convertir un résultat MySQL en objet Dart
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      currentStock: map['current_stock'] as int,
      mainImageUrl: map['main_image_url'] as String,
      isPublic: map['is_public'] == 1,
      isValidated: map['is_validated'] == 1,
    );
  }
}