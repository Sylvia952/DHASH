// lib/routes/auth_routes.dart

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

Router getAuthRouter() {
  final router = Router();
  
  // Ajoutez ici vos routes /register et /login
  router.post('/register', (Request request) => Response.ok('Register OK'));
  router.post('/login', (Request request) => Response.ok('Login OK'));
  
  return router;
}