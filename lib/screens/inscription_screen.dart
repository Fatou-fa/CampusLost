import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Écran 3 : création d'un compte.
///
/// L'utilisateur ne s'inscrit qu'une seule fois : ensuite, l'application
/// le garde connecté.
class InscriptionScreen extends StatelessWidget {
  const InscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: Couleurs.marronFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // SingleChildScrollView : le formulaire défile quand le clavier s'ouvre
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Une seule fois : ensuite, l'application vous garde connecté(e).",
              style: TextStyle(color: Couleurs.texteDiscret),
            ),
            const SizedBox(height: 24),

            // Prénom et nom côte à côte
            Row(
              children: [
                Expanded(child: _champ('Prénom', 'Awa')),
                const SizedBox(width: 12),
                Expanded(child: _champ('Nom', 'Ndiaye')),
              ],
            ),
            const SizedBox(height: 16),
            _champ('Téléphone', '77 000 00 00', clavier: TextInputType.phone),
            const SizedBox(height: 16),
            _champ('Email', 'prenom.nom@ugb.edu.sn',
                clavier: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _champ('Mot de passe', '8 caractères minimum', cache: true),
            const SizedBox(height: 32),

            // Bouton principal
            ElevatedButton(
              onPressed: () {
                // Plus tard : envoyer l'inscription à l'API
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Couleurs.marron,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Créer mon compte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Votre numéro n'est visible que des utilisateurs connectés.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Couleurs.texteDiscret),
            ),
          ],
        ),
      ),
    );
  }

  /// Crée un champ de saisie avec son libellé.
  /// [cache] masque le texte (mot de passe), [clavier] choisit le type de clavier.
  Widget _champ(
    String libelle,
    String exemple, {
    bool cache = false,
    TextInputType clavier = TextInputType.text,
  }) {
    return TextField(
      obscureText: cache,
      keyboardType: clavier,
      decoration: InputDecoration(
        labelText: libelle,
        hintText: exemple,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
