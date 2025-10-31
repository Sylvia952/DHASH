import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dhash_api_dart/services/stock_service.dart';
import 'package:dhash_api_dart/models/stock_transaction.dart';

Router getStockRouter() {
  final router = Router();
  final stockService = StockService();

  // Route sécurisée : Enregistrement d'une Entrée en stock
  // POST /api/v1/stock/in
  router.post('/in', (Request request) async {
    return _handleStockRequest(request, 'ENTREE', stockService);
  });

  // Route sécurisée : Enregistrement d'une Sortie de stock
  // POST /api/v1/stock/out
  router.post('/out', (Request request) async {
    return _handleStockRequest(request, 'SORTIE', stockService);
  });

  return router;
}

// Handler commun pour les deux types de mouvements
Future<Response> _handleStockRequest(
    Request request, String type, StockService service) async {
  final String? userIdStr = request.context['auth_user_id'] as String?;
  if (userIdStr == null) {
    return Response.forbidden(jsonEncode({'message': 'Utilisateur non identifié.'}));
  }
  final int userId = int.parse(userIdStr);

  try {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    
    final int? productId = data['productId'];
    final int? quantity = data['quantity'];

    if (productId == null || quantity == null || quantity <= 0) {
      return Response.badRequest(body: jsonEncode({'message': 'ID de produit ou quantité invalide.'}));
    }

    final transaction = StockTransaction(
      productId: productId,
      type: type,
      quantity: quantity,
      userId: userId,
      date: DateTime.now(),
    );

    await service.processStockMovement(transaction);
    return Response.ok(jsonEncode({'message': 'Mouvement de stock (${type}) enregistré avec succès.'}));

  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'message': e.toString()}));
  }
}