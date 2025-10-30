import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // Pour revenir à la connexion

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _photoController = TextEditingController(text: 'https://placeholder.com/default-profile.jpg'); // Placeholder pour le test
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_photoController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() {
        _errorMessage = "Veuillez remplir tous les champs. Mot de passe minimum 6 caractères.";
      });
      _isLoading = false;
      return;
    }

    try {
      // 1. Appel de l'API Backend pour l'inscription
      await _authService.register(
        _emailController.text,
        _passwordController.text,
        _photoController.text, // TODO: Remplacer par un vrai upload d'image
      );

      // 2. Inscription réussie : rediriger vers la connexion ou la page d'accueil
      if (mounted) {
        // En cas de succès, on pourrait rediriger l'utilisateur directement ou lui demander de se connecter
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie! Veuillez vous connecter.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // 3. Gestion des erreurs
      setState(() {
        _errorMessage = e.toString().contains('existe déjà')
            ? 'Cet email est déjà utilisé.'
            : 'Erreur d\'inscription: ${e.toString()}';
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
      appBar: AppBar(title: const Text('Inscription DHASH')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Créez votre compte', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Champ Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Champ Mot de passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            // Champ Photo de Profil (temporaire)
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(labelText: 'URL Photo de Profil (visage obligatoire)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("S'inscrire", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            
            // Lien vers la connexion
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Déjà un compte ? Connectez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}