import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Écran 6 : formulaire de publication d'une annonce.
///
/// Le même écran sert pour un objet perdu et pour un objet trouvé :
/// seuls le titre et quelques champs changent selon [type].
class FormulaireAnnonceScreen extends StatelessWidget {
  /// 'perdu' ou 'trouve'
  final String type;

  const FormulaireAnnonceScreen({super.key, this.type = 'trouve'});

  // Listes fixes, en attendant de les charger depuis la base de données
  static const categories = [
    "Papiers d'identité",
    'Électronique',
    'Clés',
    'Vêtements',
    'Fournitures',
    'Autre',
  ];
  static const lieux = [
    'Bibliothèque',
    'Resto U',
    'Amphithéâtres',
    'Pavillons',
    'Salle informatique',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    final estTrouve = type == 'trouve';

    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: Text(
          estTrouve ? 'Objet trouvé' : 'Objet perdu',
          style: const TextStyle(
            color: Couleurs.marronFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Photo (facultative) ----------
            OutlinedButton.icon(
              onPressed: () {
                // Plus tard : ouvrir l'appareil photo ou la galerie
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Ajouter une photo (facultatif)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(110),
                foregroundColor: Couleurs.marron,
                backgroundColor: Couleurs.beigeClair,
                side: const BorderSide(color: Couleurs.marron),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Champs ----------
            _champ('Titre', estTrouve ? 'Ex. : Trousseau de clés' : "Ex. : Carte d'étudiant"),
            const SizedBox(height: 14),
            _liste('Catégorie', categories),
            const SizedBox(height: 14),
            _liste(estTrouve ? 'Lieu de découverte' : 'Lieu de la perte', lieux),
            const SizedBox(height: 14),
            _champ('Date', "Aujourd'hui"),
            const SizedBox(height: 14),

            // Uniquement pour un objet trouvé : où est-il maintenant ?
            if (estTrouve) ...[
              _liste("Où est l'objet ?", const ['Avec moi', 'Déposé à la scolarité']),
              const SizedBox(height: 14),
            ],

            _champ('Description', 'Couleur, forme, porte-clés…', lignes: 3),
            const SizedBox(height: 14),

            // ---------- Conseil (objet trouvé seulement) ----------
            if (estTrouve)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Couleurs.beigeClair,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Couleurs.marron, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gardez un détail pour vous : il servira à vérifier le vrai propriétaire.',
                        style: TextStyle(color: Couleurs.marron),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // ---------- Bouton principal ----------
            ElevatedButton(
              onPressed: () {
                // Plus tard : envoyer l'annonce à l'API
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
                "Publier l'annonce",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Style commun à tous les champs du formulaire.
  InputDecoration _style(String libelle, [String? exemple]) {
    return InputDecoration(
      labelText: libelle,
      hintText: exemple,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Champ de texte ; [lignes] > 1 pour une zone de texte plus haute.
  Widget _champ(String libelle, String exemple, {int lignes = 1}) {
    return TextField(
      maxLines: lignes,
      decoration: _style(libelle, exemple),
    );
  }

  /// Liste déroulante. La première valeur est sélectionnée par défaut.
  Widget _liste(String libelle, List<String> choix) {
    return DropdownButtonFormField<String>(
      initialValue: choix.first,
      decoration: _style(libelle),
      items: choix
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (valeur) {
        // Plus tard : mémoriser la valeur choisie
      },
    );
  }
}
