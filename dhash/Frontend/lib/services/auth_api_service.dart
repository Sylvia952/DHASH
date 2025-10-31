// dhash_frontend/lib/services/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Remplacez par l'adresse et le port de votre API Backend Dart
// Utilisez 10.0.2.2 pour un émulateur Android
const String _baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

class AuthApiService {
  
  // Sauvegarde le jeton JWT dans le stockage local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // --- 1. Inscription de l'Utilisateur ---
  Future<String> registerUser({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Inscription réussie, retourne le message
      return body['message'] ?? 'Inscription réussie. Veuillez vous connecter.';
    } else {
      // Erreur (ex: email déjà utilisé)
      throw Exception(body['message'] ?? 'Échec de l\'inscription.');
    }
  }

  // --- 2. Connexion de l'Utilisateur ---
  // Retourne le jeton JWT pour vérification, mais surtout le stocke.
  Future<String> loginUser({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = body['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        return token;
      }
      throw Exception('Jeton JWT non reçu.');
    } else {
      // Erreur (ex: identifiants incorrects)
      throw Exception(body['message'] ?? 'Échec de la connexion. Vérifiez vos identifiants.');
    }
  }
}