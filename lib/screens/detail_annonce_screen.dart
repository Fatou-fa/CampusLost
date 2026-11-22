import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../theme/couleurs.dart';

/// Détail d'une annonce : grande photo de l'objet, informations, description
/// et personne qui l'a publiée. Ouvert depuis l'accueil (appui sur une
/// carte) ; le bouton en haut à gauche ramène à la liste.
class DetailAnnonceScreen extends StatelessWidget {
  final Annonce annonce;

  const DetailAnnonceScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _photo(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Titre et lieu ----------
                Text(
                  annonce.titre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.marronFonce,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: Couleurs.texteDiscret),
                    const SizedBox(width: 4),
                    Text(
                      annonce.lieu,
                      style: const TextStyle(
                          fontSize: 15, color: Couleurs.texteDiscret),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------- Catégorie et date, côte à côte ----------
                Row(
                  children: [
                    Expanded(
                      child: _info(Icons.sell_outlined, 'Catégorie',
                          annonce.categorie),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _info(Icons.calendar_today_outlined,
                          annonce.estPerdue ? 'Perdu le' : 'Trouvé le',
                          annonce.date),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Description ----------
                _carte(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marronFonce,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        annonce.description.isEmpty
                            ? 'Aucune description.'
                            : annonce.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: Couleurs.texte,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Personne qui a publié ----------
                _carte(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Couleurs.beige,
                        child: Text(
                          _initiales(annonce.auteurNom),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Couleurs.marronFonce,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              annonce.auteurNom,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Couleurs.texte,
                              ),
                            ),
                            Text(
                              annonce.estPerdue
                                  ? "A perdu l'objet"
                                  : "A trouvé l'objet",
                              style: const TextStyle(
                                  fontSize: 13, color: Couleurs.texteDiscret),
                            ),
                          ],
                        ),
                      ),
                      // Moyens de contact (affichage seulement)
                      _pastille(Icons.phone_outlined),
                      const SizedBox(width: 8),
                      _pastille(Icons.chat_outlined),
                    ],
                  ),
                ),

                // ---------- Conseil (objet trouvé seulement) ----------
                if (!annonce.estPerdue) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Couleurs.beigeClair,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: Couleurs.marron, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "C'est à vous ? Le trouveur vous posera une question "
                            "pour vérifier que l'objet vous appartient.",
                            style: TextStyle(
                                fontSize: 13, color: Couleurs.marron, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Grande photo de l'objet sur fond beige, avec le bouton retour
  /// et le badge Perdu / Trouvé.
  Widget _photo(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Couleurs.beigeTrouve,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Photo centrée, en grand
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: annonce.photoUrl != null
                    ? Image.asset(annonce.photoUrl!, height: 240)
                    : const Icon(Icons.inventory_2_outlined,
                        size: 120, color: Couleurs.marron),
              ),
            ),
            // Bouton retour (seulement s'il y a un écran précédent)
            if (Navigator.canPop(context))
              Positioned(
                left: 12,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Couleurs.marron),
                    tooltip: 'Retour',
                  ),
                ),
              ),
            // Badge en haut à droite
            Positioned(
              right: 20,
              top: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: annonce.estPerdue ? Colors.white : Couleurs.marron,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  annonce.estPerdue ? 'Perdu' : 'Trouvé',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: annonce.estPerdue ? Couleurs.marron : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Petite carte blanche : icône, libellé et valeur.
  Widget _info(IconData icone, String libelle, String valeur) {
    return _carte(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Couleurs.beigeTrouve,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 20, color: Couleurs.marron),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(libelle,
                    style: const TextStyle(
                        fontSize: 12, color: Couleurs.texteDiscret)),
                Text(
                  valeur,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Couleurs.texte,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fond blanc arrondi avec une ombre douce, réutilisé par plusieurs blocs.
  Widget _carte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Couleurs.marronFonce.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Pastille ronde avec une icône de contact (affichage seulement).
  Widget _pastille(IconData icone) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Couleurs.beigeClair,
        shape: BoxShape.circle,
      ),
      child: Icon(icone, size: 20, color: Couleurs.marron),
    );
  }

  /// Initiales à partir d'un nom, par exemple « Moussa D. » donne « MD ».
  String _initiales(String nom) {
    final mots = nom.split(' ').where((m) => m.isNotEmpty).toList();
    return mots.map((m) => m[0]).take(2).join().toUpperCase();
  }
}
