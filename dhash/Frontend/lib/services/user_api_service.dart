// dhash_frontend/lib/services/user_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Remplacez par l'adresse et le port de votre API Backend Dart
// Si vous testez sur un émulateur Android, utilisez 10.0.2.2
const String _baseUrl = 'http://10.0.2.2:8080/api/v1/user';

class UserApiService {

  // Récupérer le jeton JWT stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // En-têtes pour les requêtes sécurisées
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- 1. Récupérer le Profil ---
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/profile'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      // Jeton invalide ou expiré
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw Exception('Échec de la récupération du profil: ${response.body}');
    }
  }

  // --- 2. Mettre à Jour le Profil (Email/Photo) ---
  Future<void> updateProfile({String? email, String? photoUrl}) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    final response = await http.put(Uri.parse('$_baseUrl/profile'), headers: headers, body: body);

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Échec de la mise à jour du profil.');
    }
  }

  // --- 3. Modifier le Mot de Passe ---
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    final response = await http.post(Uri.parse('$_baseUrl/change-password'), headers: headers, body: body);

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Échec de la modification du mot de passe.');
    }
  }
}