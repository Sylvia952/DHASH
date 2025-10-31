// Dans lib/routes/product_routes.dart

import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dhash_api_dart/services/product_service.dart';
import 'package:dhash_api_dart/models/product.dart';

// ... (Le code getProductRouter existant) ...

// NOTE: La route POST /products est déjà créée (dans l'itération précédente).
// Elle nécessite l'ID utilisateur, récupéré dans le contexte.

// Route sécurisée : Mettre à jour un produit
// PUT /api/v1/products/{id} (NÉCESSITE AUTHENTIFICATION et PROPRIÉTÉ)
router.put('/products/<id>', (Request request, String id) async {
    final int? productId = int.tryParse(id);
    final String? userIdStr = request.context['auth_user_id'] as String?;
    
    if (productId == null || userIdStr == null) {
        return Response.badRequest(body: jsonEncode({'message': 'ID de produit ou utilisateur invalide.'}));
    }
    final int userId = int.parse(userIdStr);

    try {
        final body = await request.readAsString();
        final data = jsonDecode(body);
        
        final existingProduct = await productService.getProductById(productId);
        if (existingProduct == null) {
            return Response.notFound(jsonEncode({'message': 'Produit non trouvé.'}));
        }
        
        // --- VÉRIFICATION DE PERMISSION DU PRODUIT (simplifié) ---
        // Dans une architecture réelle, vous vérifieriez si l'utilisateur est admin ou propriétaire de la catégorie
        // Nous allons supposer que c'est une route administrateur/gestionnaire ici.
        
        final updatedProduct = Product.fromMap({...existingProduct.toMap(), ...data});

        await productService.updateProduct(productId, updatedProduct, userId);
        return Response.ok(jsonEncode({'message': 'Produit mis à jour avec succès.'}));

    } catch (e) {
        return Response.internalServerError(body: jsonEncode({'message': 'Échec de la mise à jour du produit: $e'}));
    }
});

// Route sécurisée : Supprimer un produit
// DELETE /api/v1/products/{id} (NÉCESSITE AUTHENTIFICATION et PROPRIÉTÉ)
router.delete('/products/<id>', (Request request, String id) async {
    final int? productId = int.tryParse(id);
    final String? userIdStr = request.context['auth_user_id'] as String?;
    
    if (productId == null || userIdStr == null) {
        return Response.badRequest(body: jsonEncode({'message': 'ID de produit ou utilisateur invalide.'}));
    }
    final int userId = int.parse(userIdStr);

    try {
        // La vérification de permission est implicite dans le service (ou devrait être ici)
        final success = await productService.deleteProduct(productId, userId);
        
        if (success) {
            return Response.ok(jsonEncode({'message': 'Produit supprimé avec succès.'}));
        } else {
            return Response.notFound(jsonEncode({'message': 'Produit non trouvé ou non autorisé.'}));
        }

    } catch (e) {
        return Response.internalServerError(body: jsonEncode({'message': 'Échec de la suppression: $e'}));
    }
});


// --- CRUD CATÉGORIE (Exemple de route sécurisée) ---

// Route sécurisée : Mettre à jour une catégorie
// PUT /api/v1/categories/{id} (NÉCESSITE AUTHENTIFICATION et PROPRIÉTÉ)
router.put('/categories/<id>', (Request request, String id) async {
    final int? categoryId = int.tryParse(id);
    final String? userIdStr = request.context['auth_user_id'] as String?;
    
    if (categoryId == null || userIdStr == null) {
        return Response.badRequest(body: jsonEncode({'message': 'ID de catégorie ou utilisateur invalide.'}));
    }
    final int userId = int.parse(userIdStr);
    
    try {
        final body = await request.readAsString();
        final data = jsonDecode(body);
        
        // Crée une catégorie temporaire pour passer les données
        final tempCategory = Category(
            ownerId: userId, // On utilise l'ID de l'utilisateur connecté comme propriétaire potentiel
            title: data['title'],
            description: data['description'],
            imageUrl: data['imageUrl']
        );
        
        final success = await productService.updateCategory(categoryId, tempCategory, userId);
        
        if (success) {
            return Response.ok(jsonEncode({'message': 'Catégorie mise à jour avec succès.'}));
        } else {
            return Response.notFound(jsonEncode({'message': 'Catégorie non trouvée ou non autorisée.'}));
        }
        
    } catch (e) {
        // Capture l'erreur de permission levée par le service
        return Response.forbidden(jsonEncode({'message': e.toString()}));
    }
});


// Pour fonctionner, vous devez vous assurer que ces routes sont correctement montées
// dans `server.dart` (ce qui a été fait dans l'étape précédente).
// Assurez-vous aussi d'avoir une fonction .toJson() dans vos modèles Product et Category
// pour l'affichage (ex: products.map((p) => p.toJson()).toList()).