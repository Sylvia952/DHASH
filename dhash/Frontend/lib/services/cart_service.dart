// Code simplifié : Gestion des interactions avec les tables carts et cart_items
import 'package:dhash_api_dart/config/db_connection.dart';
import 'package:mysql_client/mysql_client.dart';

class CartService {

  // Récupérer le panier actif d'un utilisateur
  Future<int?> getOrCreateCartId(int userId) async {
    final conn = await Database.getConnection();
    var result = await conn.execute(
        'SELECT id FROM carts WHERE user_id = ?',
        [userId]
    );

    if (result.rows.isNotEmpty) {
      return result.rows.first.assoc()['id'] as int;
    } else {
      // Créer un nouveau panier si aucun n'existe
      var insertResult = await conn.execute(
          'INSERT INTO carts (user_id, created_at, updated_at) VALUES (?, NOW(), NOW())',
          [userId]
      );
      return insertResult.lastInsertID.toInt();
    }
  }

  // Ajouter/Mettre à jour un produit dans le panier
  Future<void> addItemToCart(int userId, int productId, int quantity) async {
    final cartId = await getOrCreateCartId(userId);
    final conn = await Database.getConnection();

    // 1. Vérifier si le produit est déjà dans le panier
    var existingItem = await conn.execute(
        'SELECT id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?',
        [cartId, productId]
    );
    
    if (existingItem.rows.isNotEmpty) {
      // 2. Si oui, mettre à jour la quantité
      final existingQty = existingItem.rows.first.assoc()['quantity'] as int;
      final newQty = existingQty + quantity;
      
      await conn.execute(
          'UPDATE cart_items SET quantity = ?, updated_at = NOW() WHERE id = ?',
          [newQty, existingItem.rows.first.assoc()['id']]
      );
    } else {
      // 3. Si non, insérer un nouvel élément
      await conn.execute(
          'INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)',
          [cartId, productId, quantity]
      );
    }
    // Mettre à jour l'horodatage du panier
    await conn.execute('UPDATE carts SET updated_at = NOW() WHERE id = ?', [cartId]);
  }

  // Appliquer un code promo
  Future<void> applyPromoCode(int userId, String code) async {
      final cartId = await getOrCreateCartId(userId);
      final conn = await Database.getConnection();

      // 1. Trouver le code promo valide
      final promoResult = await conn.execute(
          'SELECT id FROM promo_codes WHERE code = ? AND is_active = 1 AND (expiry_date IS NULL OR expiry_date > NOW())',
          [code]
      );

      if (promoResult.rows.isEmpty) {
          throw 'Code promo invalide ou expiré.';
      }
      
      final promoId = promoResult.rows.first.assoc()['id'] as int;

      // 2. Mettre à jour le panier avec le code promo
      await conn.execute(
          'UPDATE carts SET promo_code_id = ?, updated_at = NOW() WHERE id = ?',
          [promoId, cartId]
      );
  }
  
  // Fonction de validation du panier (pré-paiement) - très complexe en réalité
  // Elle devrait vérifier le stock, calculer le prix final et préparer la commande.
  Future<Map<String, dynamic>> validateCart(int userId) async {
      // TODO: Implémenter la vérification du stock, l'application de la promo et le calcul du total
      return {'total_final': 100.00, 'items_count': 3, 'status': 'ready_to_pay'};
  }
}