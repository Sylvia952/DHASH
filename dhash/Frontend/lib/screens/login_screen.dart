import 'package:flutter/material.dart';
// Utiliser le nom de package du Frontend (dhash_frontend)
import 'package:dhash_frontend/services/auth_api_service.dart'; 
import 'package:dhash_frontend/screens/home_screen.dart'; 
import 'package:dhash_frontend/screens/register_screen.dart'; // NOUVEAU

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Utiliser le AuthApiService défini précédemment
  final AuthApiService _authService = AuthApiService(); 
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    // Ajout d'une simple validation de formulaire
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Appel de l'API Backend via le service
      await _authService.loginUser( // Appel correct de la méthode du service
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
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
        // Nettoyage du message d'erreur pour un affichage plus convivial
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        _errorMessage = errorMsg.contains('Vérifiez vos identifiants')
            ? 'Email ou mot de passe incorrect.'
            : errorMsg;
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
            // ... (Restant du Widget build, inchangé) ...
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
            
            // Lien 'Mot de passe oublié'
            TextButton(
              onPressed: () {
                // TODO: Naviguer vers ResetPasswordScreen
              },
              child: const Text('Mot de passe oublié ?'),
            ),

            // Lien vers l'inscription (Utilise le RegisterScreen créé ci-dessous)
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