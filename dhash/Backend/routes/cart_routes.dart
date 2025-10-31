import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dhash_api_dart/services/cart_service.dart';

Router getCartRouter() {
  final router = Router();
  final cartService = CartService();

  // Middleware pour récupérer l'ID utilisateur (déjà fait par checkAuth)
  Response _checkUser(Request request) {
    final userIdStr = request.context['auth_user_id'] as String?;
    if (userIdStr == null) {
      return Response.forbidden(jsonEncode({'message': 'Utilisateur non identifié.'}));
    }
    return Response.ok(userIdStr); // Renvoie l'ID pour l'utiliser dans la closure
  }

  // POST /api/v1/cart/add : Ajouter/Mettre à jour un article
  router.post('/add', (Request request) async {
    final userCheck = _checkUser(request);
    if (userCheck.statusCode != 200) return userCheck;
    final userId = int.parse(await userCheck.readAsString());

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final int? productId = data['productId'];
      final int? quantity = data['quantity'];

      if (productId == null || quantity == null || quantity <= 0) {
        return Response.badRequest(body: jsonEncode({'message': 'Données d\'article invalides.'}));
      }

      await cartService.addItemToCart(userId, productId, quantity);
      return Response.ok(jsonEncode({'message': 'Article ajouté au panier.'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'message': e.toString()}));
    }
  });

  // POST /api/v1/cart/apply-promo : Appliquer un code promo
  router.post('/apply-promo', (Request request) async {
    final userCheck = _checkUser(request);
    if (userCheck.statusCode != 200) return userCheck;
    final userId = int.parse(await userCheck.readAsString());
    
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final String? code = data['code'];
      
      if (code == null) {
          return Response.badRequest(body: jsonEncode({'message': 'Code promo manquant.'}));
      }
      
      await cartService.applyPromoCode(userId, code);
      return Response.ok(jsonEncode({'message': 'Code promo appliqué avec succès.'}));
      
    } catch (e) {
        // Gère l'erreur levée par le service ('Code promo invalide...')
        return Response.badRequest(body: jsonEncode({'message': e.toString()})); 
    }
  });

  // POST /api/v1/cart/validate : Valider le panier avant paiement
  router.post('/validate', (Request request) async {
    final userCheck = _checkUser(request);
    if (userCheck.statusCode != 200) return userCheck;
    final userId = int.parse(await userCheck.readAsString());
    
    try {
        final validationResult = await cartService.validateCart(userId);
        // Ici, vous enverriez l'e-mail avec la liste (fonctionnalité client).
        return Response.ok(jsonEncode(validationResult));
    } catch (e) {
        return Response.internalServerError(body: jsonEncode({'message': e.toString()}));
    }
  });


  return router;
}