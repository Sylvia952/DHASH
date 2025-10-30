import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Assurez-vous d'avoir ce fichier
import 'home_screen.dart'; // Écran de redirection après connexion

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Appel de l'API Backend via le service
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      // 2. Navigation réussie (Le token est stocké dans shared_preferences)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // 3. Gestion des erreurs de l'API
      setState(() {
        _errorMessage = e.toString().contains('Email ou mot de passe invalide')
            ? 'Email ou mot de passe incorrect.'
            : 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion DHASH')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo DHASH (À implémenter)
            const Text('DHASH', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Se connecter', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            
            // Lien 'Mot de passe oublié' (Fonctionnalité prévue)
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers ResetPasswordScreen
              },
              child: const Text('Mot de passe oublié ?'),
            ),

            // Lien vers l'inscription
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Pas encore de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}

// Fichier temporaire pour éviter les erreurs de navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('DHASH Home')), body: const Center(child: Text('Bienvenue sur DHASH !')));
  }
}