import 'package:dhash_api_dart/config/db_connection.dart';
import 'package:dhash_api_dart/models/stock_transaction.dart';
import 'package:mysql_client/mysql_client.dart';

class StockService {

  // Méthode générique pour enregistrer et mettre à jour le stock
  Future<void> processStockMovement(StockTransaction transaction) async {
    final conn = await Database.getConnection();

    // 1. Déterminer l'opération (+ ou -)
    final String operator = (transaction.type == 'ENTREE') ? '+' : '-';

    // 2. Vérification avant la Sortie
    if (transaction.type == 'SORTIE') {
        final stockResult = await conn.execute(
            'SELECT current_stock FROM products WHERE id = ?', 
            [transaction.productId]
        );
        if (stockResult.rows.isEmpty) {
            throw 'Produit non trouvé.';
        }
        final currentStock = stockResult.rows.first.assoc()['current_stock'] as int;
        if (currentStock < transaction.quantity) {
            throw 'Stock insuffisant pour cette sortie. Stock actuel: $currentStock';
        }
    }
    
    // 3. Exécuter les deux opérations dans une transaction MySQL (si possible avec mysql_client)
    // Ici, nous simplifions l'approche transactionnelle pour la compatibilité du package Dart.

    try {
      // 3a. Enregistrer la transaction de stock
      await conn.execute(
        'INSERT INTO stock_transactions (product_id, type, quantity, user_id, date) VALUES (?, ?, ?, ?, NOW())',
        [transaction.productId, transaction.type, transaction.quantity, transaction.userId],
      );

      // 3b. Mettre à jour le stock du produit
      await conn.execute(
        'UPDATE products SET current_stock = current_stock $operator ? WHERE id = ?',
        [transaction.quantity, transaction.productId],
      );
      
    } catch (e) {
      // En cas d'erreur (idéalement, on rollback une transaction ici)
      print('Erreur lors du mouvement de stock: $e');
      throw 'Échec de l\'opération de stock.';
    }
  }
}