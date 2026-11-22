import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Écran « Publier une annonce » : l'utilisateur indique s'il a perdu
/// ou trouvé un objet. Affichage seul pour l'instant (pas de navigation).
class ChoixTypeScreen extends StatelessWidget {
  const ChoixTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---------- En-tête marron, comme sur l'accueil ----------
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            decoration: const BoxDecoration(
              color: Couleurs.marronFonce,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: const SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  Text(
                    'Publier une annonce',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Que souhaitez-vous signaler ?',
                    style: TextStyle(color: Color(0xFFEADCC4), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ---------- Les deux choix ----------
          _carteChoix(
            image: 'assets/images/objets/choix_perdu.png',
            titre: "J'ai perdu un objet",
            texte: 'Décrivez-le : la communauté du campus vous aide à le retrouver.',
          ),
          const SizedBox(height: 16),
          _carteChoix(
            image: 'assets/images/objets/choix_trouve.png',
            titre: "J'ai trouvé un objet",
            texte: "Déclarez-le pour qu'il retrouve vite son propriétaire.",
          ),
        ],
      ),
    );
  }

  /// Carte d'un choix : illustration à gauche, titre et explication à droite.
  Widget _carteChoix({
    required String image,
    required String titre,
    required String texte,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Ombre douce, comme les cartes de l'accueil
        boxShadow: [
          BoxShadow(
            color: Couleurs.marronFonce.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Illustration dans un carré beige
          Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Couleurs.beigeTrouve,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          // Expanded : le texte passe à la ligne s'il est trop long
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.marronFonce,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  texte,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Couleurs.texteDiscret,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
