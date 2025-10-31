// dhash_backend/lib/services/auth_service.dart

import 'package:argon2/argon2.dart'; 
// ANCIEN : import 'package:dhash_api_dart/config/db_connection.dart';
import 'package:dhash_backend/config/db_connection.dart'; // ✅ CORRIGÉ
// ANCIEN : import 'package:dhash_api_dart/models/user.dart';
import 'package:dhash_backend/models/user.dart'; // ✅ CORRIGÉ
import 'package:jaguar_jwt/jaguar_jwt.dart';


class AuthService {
  // Initialisation du Hasher Argon2 une seule fois
  final _argon2Hasher = Argon2Hasher();

  // Méthode pour l'inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> registerUser(
      String email, String password, String photoUrl) async {
    final conn = await Database.getConnection();
    
    // 1. Vérifier si l'utilisateur existe déjà
    var result = await conn.execute(
      'SELECT id FROM users WHERE email = ?',
      [email],
    );

    if (result.rows.isNotEmpty) {
      throw 'L\'utilisateur avec cet email existe déjà.';
    }

    // 2. Hacher le mot de passe avec Argon2
    final passwordHash = _argon2Hasher.hash(password); 

    // 3. Insérer l'utilisateur
    final insertResult = await conn.execute(
      'INSERT INTO users (email, password_hash, profile_photo_url, created_at) VALUES (?, ?, ?, NOW())',
      [email, passwordHash, photoUrl],
    );

    final newUserId = insertResult.lastInsertID.toString();
    final token = _generateToken(newUserId);

    return {'id': newUserId, 'email': email, 'token': token};
  }

  // Méthode pour la connexion
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final conn = await Database.getConnection();
    
    // 1. Chercher l'utilisateur par email
    var result = await conn.execute(
      'SELECT id, password_hash, email FROM users WHERE email = ?',
      [email],
    );

    if (result.rows.isEmpty) {
      throw 'Email ou mot de passe invalide.';
    }

    final userRow = result.rows.first.assoc();
    final String storedHash = userRow['password_hash']!;

    // 2. Vérifier le mot de passe avec Argon2
    final verified = _argon2Hasher.verify(password, storedHash); 
    
    if (!verified) {
      throw 'Email ou mot de passe invalide.';
    }

    // 3. Générer le jeton JWT
    final token = _generateToken(userRow['id']!);

    return {'id': userRow['id'], 'email': userRow['email'], 'token': token};
  }

  // Fonction utilitaire pour générer le JWT
  String _generateToken(String userId) {
    final claims = JwtClaim(
      subject: userId,
      issuer: 'DHASH_API',
      expiry: DateTime.now().add(Duration(days: 30)),
    );
    // Le secret doit être chargé depuis .env
    return issueJwt(claims, 'VOTRE_SECRET_JWT_FORT'); 
  }
}