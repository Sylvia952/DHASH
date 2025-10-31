// dhash_frontend/lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pour la déconnexion
import 'package:dhash_frontend/services/user_api_service.dart';
import 'package:dhash_frontend/screens/login_screen.dart'; // Assurez-vous d'avoir cet écran

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserApiService _apiService = UserApiService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await _apiService.fetchUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('403') ? 'Session expirée. Veuillez vous reconnecter.' : e.toString();
        _isLoading = false;
        if (_errorMessage!.contains('Session expirée')) {
            _handleLogout(); // Déconnexion automatique
        }
      });
    }
  }

  // --- Logique de Déconnexion ---
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (Le code de build existant est inchangé) ...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Photo de Profil
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_userProfile!['profile_photo_url'] ?? 'https://via.placeholder.com/150'),
                        child: _userProfile!['profile_photo_url'] == null ? const Icon(Icons.person, size: 50) : null,
                      ),
                      TextButton(
                          onPressed: () => _showEditDialog('URL Photo de Profil', 'photoUrl'),
                          child: const Text('Modifier la photo')
                      ),
                      const SizedBox(height: 16),
                      
                      // Informations
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(_userProfile!['email']),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog('Email', 'email'),
                          ),
                        ),
                      ),
                      
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Membre depuis'),
                          // Note: L'API renvoie created_at en String, on prend juste la date
                          subtitle: Text(_userProfile!['created_at'].substring(0, 10)), 
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Bouton de modification de mot de passe
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock),
                        label: const Text('Changer le Mot de Passe'),
                        onPressed: _showChangePasswordDialog,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bouton de Déconnexion 
                      TextButton(
                        onPressed: _handleLogout,
                        child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
    );
  }

  // --- Dialogue de Modification de Champ (Email ou Photo) ---
  void _showEditDialog(String title, String fieldName) {
    final TextEditingController controller = TextEditingController(
      text: _userProfile![fieldName] ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
          keyboardType: fieldName == 'email' ? TextInputType.emailAddress : TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(context); 
              
              try {
                // Montrer un indicateur de chargement
                setState(() => _isLoading = true); 

                await _apiService.updateProfile(
                  email: fieldName == 'email' ? controller.text.trim() : null,
                  photoUrl: fieldName == 'photoUrl' ? controller.text.trim() : null,
                );
                
                // Récupérer le profil mis à jour pour rafraîchir l'écran
                await _fetchProfile(); 
                
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${e.toString()}')),
                );
                setState(() => _isLoading = false); // Cacher le chargement en cas d'erreur
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  // --- Dialogue de Modification de Mot de Passe ---
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le Mot de Passe'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Ancien Mot de Passe'),
                validator: (v) => v!.isEmpty ? 'Veuillez entrer votre ancien mot de passe.' : null,
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau Mot de Passe (min 6 chars)'),
                validator: (v) => v!.length < 6 ? 'Le mot de passe doit faire au moins 6 caractères.' : null,
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer Nouveau Mot de Passe'),
                validator: (v) => v != newPasswordController.text ? 'Les mots de passe ne correspondent pas.' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(context);
              
              try {
                setState(() => _isLoading = true);

                await _apiService.changePassword(
                  oldPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                // Si succès, forcer la déconnexion pour réauthentification (sécurité)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mot de passe mis à jour. Veuillez vous reconnecter.')),
                );
                _handleLogout();
                
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${e.toString()}')),
                );
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}