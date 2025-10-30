import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart'; // NÉCESSAIRE pour Router()
import 'package:dotenv/dotenv.dart';

// Importations des composants du Backend
import 'package:dhash_api_dart/routes/auth_routes.dart'; // Routes d'authentification
import 'package:dhash_api_dart/routes/product_routes.dart'; // Routes des produits (Nouveau)
import 'package:dhash_api_dart/config/db_connection.dart'; // Connexion MySQL
import 'package:dhash_api_dart/middleware/auth_middleware.dart'; // 🔐 Middleware JWT (Nouveau)

void main(List<String> args) async {
  // 1. Charger les variables d'environnement (.env)
  final env = DotEnv()..load();
  final port = int.parse(env['PORT'] ?? '8080');

  // 2. Initialiser la connexion à la base de données (MySQL)
  try {
    await Database.getConnection();
  } catch (e) {
    print('Échec de la connexion à la base de données: $e');
    exit(1); // Arrêter si la DB n'est pas accessible
  }

  // 3. Définir le Pipeline de Handlers (Middleware + Routes)
  final routerHandler = Router();
  
  // Routes publiques (Authentification)
  routerHandler.mount('/api/v1/auth', getAuthRouter());
  
  // Routes sécurisées (Produits, Catégories, Stocks, etc.)
  routerHandler.mount('/api/v1/products', getProductRouter()); // Ajout des routes produits

  // Pipeline global pour toutes les requêtes
  final handler = Pipeline()
      .addMiddleware(logRequests())     // 1. Logging des requêtes
      .addMiddleware(_jsonContentType()) // 2. S'assurer que les réponses sont en JSON
      .addMiddleware(checkAuth())        // 🔐 3. VÉRIFICATION JWT POUR TOUTES LES REQUÊTES
      .addHandler(routerHandler);       // 4. Le routeur principal

  // 4. Démarrer le serveur
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Serveur DHASH démarré sur http://${server.address.host}:${server.port}');
}

// Middleware pour forcer Content-Type: application/json
// (Fonction inchangée)
Middleware _jsonContentType() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      // S'assurer que les réponses non-erreur sont en JSON
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return response.change(headers: {'content-type': 'application/json'});
      }
      return response;
    };
  };
}

// Middleware utilitaire pour le logging des requêtes
// (Fonction inchangée)
Middleware logRequests() => (Handler innerHandler) {
  return (Request request) async {
    final watch = Stopwatch()..start();
    final response = await innerHandler(request);
    watch.stop();
    print(
        '[${DateTime.now().toIso8601String()}] ${response.statusCode} | ${request.method} ${request.url} - ${watch.elapsedMilliseconds}ms');
    return response;
  };
};