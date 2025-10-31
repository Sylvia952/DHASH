import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import '../../lib/screens/home_screen.dart'; // Écran d'accueil après connexion

void main() {
  // Assure que les Widgets sont initialisés avant de lancer l'application
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DhashApp());
}

class DhashApp extends StatelessWidget {
  const DhashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DHASH App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Le Widget FutureBuilder vérifie le statut d'authentification
      home: const AuthCheckScreen(), 
    );
  }
}

// --- Écran de Vérification de l'Authentification ---
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  // Fonction pour vérifier la présence d'un jeton JWT
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // On considère que l'utilisateur est connecté si un token existe
    return prefs.getString('jwt_token') != null; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        // Afficher un indicateur de chargement pendant la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si la vérification est terminée
        if (snapshot.hasData && snapshot.data == true) {
          // Si le jeton est présent, aller à l'accueil
          return const HomeScreen(); 
        } else {
          // Si le jeton est absent, aller à la connexion
          return const LoginScreen();
        }
      },
    );
  }
}

// NOTE: Assurez-vous d'avoir bien importé 'package:shared_preferences/shared_preferences.dart' dans pubspec.yaml
// Si HomeScreen n'existe pas encore, vous pouvez utiliser la version simple que nous avons créée précédemment.