import 'package:campuslost/theme/couleurs.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Logo carré arrondi marron foncé avec icône beige
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Couleurs.marronFonce,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: Couleurs.beige,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 28),
                // Titre principal
                const Text(
                  'Bon retour !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.texte,
                  ),
                ),
                const SizedBox(height: 8),
                // Sous-titre
                const Text(
                  'Connectez-vous pour retrouver vos objets ou aider la communauté.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Couleurs.texteDiscret,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                // Libellé Email
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Couleurs.texte,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'prenom.nom@ugb.edu.sn',
                    hintStyle: TextStyle(
                      color: Couleurs.texteDiscret.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Couleurs.bordure),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Couleurs.marron,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email obligatoire';
                    }
                    if (!v.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Libellé Mot de passe
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Couleurs.texte,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      color: Couleurs.texteDiscret.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Couleurs.bordure),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Couleurs.marron,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Mot de passe obligatoire';
                    }
                    if (v.length < 6) {
                      return '6 caractères minimum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Lien Mot de passe oublié aligné à droite
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Action mot de passe oublié
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Couleurs.marron,
                        decoration: TextDecoration.underline,
                        decorationColor: Couleurs.marron,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton Se connecter pleine largeur sans icône
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Couleurs.marron,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connexion simulée'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mention de session persistante en bas
                const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: Couleurs.texteDiscret,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vous resterez connecté(e) sur cet appareil.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Couleurs.texteDiscret,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
