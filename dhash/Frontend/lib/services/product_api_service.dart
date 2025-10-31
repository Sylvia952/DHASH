// dhash_frontend/lib/services/product_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhash_frontend/models/product.dart';

// Adresse de base de l'API (à adapter)
const String _baseUrl = 'http://10.0.2.2:8080/api/v1';

class ProductApiService {

  // Récupérer le jeton JWT stocké pour les requêtes sécurisées
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (requireAuth) {
      final token = await _getToken();
      if (token == null) {
         throw Exception('Utilisateur non authentifié.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- 1. Récupérer la liste des Produits ---
  Future<List<Product>> fetchProducts() async {
    // La route GET /api/v1/products n'est pas sécurisée dans notre API
    final headers = await _getHeaders(); 
    final response = await http.get(Uri.parse('$_baseUrl/products'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des produits: ${response.statusCode}');
    }
  }

  // --- 2. Ajouter un Article au Panier (Nécessite Authentification) ---
  Future<void> addItemToCart({required int productId, required int quantity}) async {
    final headers = await _getHeaders(requireAuth: true);
    final body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/cart/add'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Échec de l\'ajout au panier.');
    }
  }
}