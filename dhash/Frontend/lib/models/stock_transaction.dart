class StockTransaction {
  final int? id;
  final int productId;
  final String type; // 'ENTREE' ou 'SORTIE'
  final int quantity;
  final int userId;
  final DateTime date;

  StockTransaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.userId,
    required this.date,
  });

  // Conversion d'une ligne de résultat MySQL en objet Dart
  factory StockTransaction.fromMap(Map<String, dynamic> map) {
    return StockTransaction(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      userId: map['user_id'] as int,
      date: map['date'] as DateTime,
    );
  }
}