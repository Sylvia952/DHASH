// Dans lib/services/product_service.dart

// Fonction utilitaire pour vérifier si l'utilisateur est le propriétaire ou un admin
Future<bool> _isOwnerOrAdmin(String tableName, int itemId, int userId) async {
    final conn = await Database.getConnection();
    
    // Pour les produits, nous allons chercher l'ID du propriétaire de la catégorie associée
    // (Simplifié ici pour l'exemple : il faudrait une jointure complexe ou ajouter owner_id à product)
    // Pour cet exemple, nous vérifierons seulement si le produit existe :
    if (tableName == 'products') {
        // Logique avancée : trouver la catégorie du produit, puis le propriétaire de la catégorie
        // Simplification: Nous allons simplement permettre la mise à jour ici et implémenter la vérif dans le routeur.
        return true; 
    }
    
    // Pour les catégories (la vérification est plus simple si owner_id est dans la table)
    final results = await conn.execute(
        'SELECT owner_id FROM $tableName WHERE id = ?',
        [itemId]
    );

    if (results.rows.isEmpty) return false;
    final ownerId = results.rows.first.assoc()['owner_id'];

    // Dans la vraie vie, vous vérifieriez aussi si l'utilisateur est admin
    return ownerId == userId.toString(); 
}

// UPDATE Product - Mise à jour de la méthode pour la permission
Future<bool> updateProduct(int productId, Product product, int requestingUserId) async {
    // Dans une architecture complète, vous vérifiez ici la permission
    // Par souci de simplicité et de modularité du service, la vérification sera faite dans le Routeur.
    
    final conn = await Database.getConnection();
    final result = await conn.execute(
        'UPDATE products SET title=?, description=?, price=?, current_stock=?, main_image_url=?, is_public=?, is_validated=?, category_id=? WHERE id=?',
        [
          product.title,
          product.description,
          product.price,
          product.currentStock,
          product.mainImageUrl,
          product.isPublic ? 1 : 0,
          product.isValidated ? 1 : 0,
          product.categoryId,
          productId
        ]);
    
    return result.affectedRows.toInt() > 0;
}

// DELETE Product - Mise à jour de la méthode
Future<bool> deleteProduct(int productId, int requestingUserId) async {
    // La vérification de permission sera faite dans le Routeur.
    final conn = await Database.getConnection();
    final result = await conn.execute('DELETE FROM products WHERE id = ?', [productId]);
    
    return result.affectedRows.toInt() > 0;
}

// UPDATE Category
Future<bool> updateCategory(int categoryId, Category category, int requestingUserId) async {
    if (!await _isOwnerOrAdmin('categories', categoryId, requestingUserId)) {
        throw 'Permission refusée: Vous n\'êtes pas le propriétaire de cette catégorie.';
    }
    
    final conn = await Database.getConnection();
    final result = await conn.execute(
        'UPDATE categories SET title=?, description=?, image_url=? WHERE id=?',
        [category.title, category.description, category.imageUrl, categoryId]);
        
    return result.affectedRows.toInt() > 0;
}

// DELETE Category
Future<bool> deleteCategory(int categoryId, int requestingUserId) async {
    if (!await _isOwnerOrAdmin('categories', categoryId, requestingUserId)) {
        throw 'Permission refusée: Vous n\'êtes pas le propriétaire de cette catégorie.';
    }
    
    final conn = await Database.getConnection();
    final result = await conn.execute('DELETE FROM categories WHERE id = ?', [categoryId]);
    
    return result.affectedRows.toInt() > 0;
}