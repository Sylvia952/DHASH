// dhash_frontend/lib/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:dhash_frontend/models/product.dart';
import 'package:dhash_frontend/services/product_api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductApiService _apiService = ProductApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
  }

  // Fonction pour ajouter l'article au panier
  void _addToCart(int productId) async {
    try {
      await _apiService.addItemToCart(productId: productId, quantity: 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté au panier !'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        // Gérer les erreurs de stock ou d'authentification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur panier: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  // Widget affichant un seul produit
  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit (prenant l'espace disponible en haut)
          Expanded(
            child: Center(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
          // Détails
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${product.price.toStringAsFixed(2)} €', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                Text('Stock: ${product.currentStock}', style: TextStyle(fontSize: 12, color: product.currentStock > 0 ? Colors.green : Colors.red)),
              ],
            ),
          ),
          
          // Bouton d'ajout au panier
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Ajouter'),
                onPressed: product.currentStock > 0 ? () => _addToCart(product.id) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Disponibles'),
        actions: [
          // TODO: Ajouter un bouton Panier pour naviguer vers CartScreen
          IconButton(
            icon: const Icon(Icons.shopping_cart), 
            onPressed: () {
               // Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit disponible.'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 produits par ligne
              childAspectRatio: 0.7, // Ratio hauteur/largeur pour laisser de la place aux détails
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          );
        },
      ),
    );
  }
}