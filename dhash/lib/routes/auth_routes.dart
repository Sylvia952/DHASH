import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dhash_api_dart/services/auth_service.dart';

// Crée le routeur et définit les routes d'authentification
Router getAuthRouter() {
  final router = Router();
  final authService = AuthService();

  // POST /api/v1/auth/register
  router.post('/register', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    try {
      final result = await authService.registerUser(
        data['email'],
        data['password'],
        data['profilePhotoURL'],
      );
      // Retourne l'utilisateur et le token JWT
      return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      // Gestion d'erreur (ex: utilisateur déjà existant)
      return Response.badRequest(body: jsonEncode({'message': e.toString()}));
    }
  });

  // POST /api/v1/auth/login
  router.post('/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    try {
      final result = await authService.loginUser(
        data['email'],
        data['password'],
      );
      return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      // Gestion d'erreur (ex: email ou mot de passe invalide)
      return Response.unauthorized(jsonEncode({'message': e.toString()}));
    }
  });

  return router;
}