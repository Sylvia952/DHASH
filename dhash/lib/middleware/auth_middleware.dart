import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dotenv/dotenv.dart';

// Clé secrète JWT chargée au démarrage
final String jwtSecret = DotEnv()..load()['JWT_SECRET'] ?? 'default_secret_fallback';

Middleware checkAuth() {
  return (Handler innerHandler) {
    return (Request request) async {
      // 1. Les routes d'authentification sont publiques, on les laisse passer
      if (request.url.path.startsWith('auth/login') || 
          request.url.path.startsWith('auth/register')) {
        return innerHandler(request);
      }
      
      // Les routes publiques (comme GET /products) doivent être gérées
      // en utilisant un routage spécifique, mais pour les autres...

      // 2. Récupérer le jeton de l'en-tête Authorization
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(jsonEncode({'message': 'Accès refusé. Jeton manquant.'}));
      }

      // Extraire le jeton (retirer 'Bearer ')
      final token = authHeader.substring(7);

      try {
        // 3. Valider le jeton
        final JwtClaim claim = verifyJwt(token, jwtSecret);
        
        // 4. Extraire l'ID utilisateur
        final String userId = claim.subject ?? (throw 'Jeton invalide: Pas de sujet (subject).');
        
        // 5. Passer l'ID utilisateur à la requête pour les contrôleurs suivants
        final updatedRequest = request.change(context: {'auth_user_id': userId});

        // 6. Continuer vers le handler (route)
        return innerHandler(updatedRequest);
        
      } on JwtException {
        // Jeton invalide ou expiré
        return Response.forbidden(jsonEncode({'message': 'Jeton invalide ou expiré.'}));
      } catch (e) {
        // Autres erreurs de validation
        return Response.internalServerError(body: jsonEncode({'message': 'Erreur de validation du jeton: $e'}));
      }
    };
  };
}