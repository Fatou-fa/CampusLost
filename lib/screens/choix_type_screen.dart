import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../theme/couleurs.dart';

/// Écran « Publier une annonce » : l'utilisateur indique s'il a perdu
/// ou trouvé un objet. Un appui sur une carte ouvre le formulaire
/// correspondant (type 'perdu' ou 'trouve').
class ChoixTypeScreen extends StatelessWidget {
  const ChoixTypeScreen({super.key});

  // Couleurs propres à cet écran : chaude pour « perdu », verte pour « trouvé »
  static const corailClair = Color(0xFFE07A5F);
  static const corailFonce = Color(0xFFC8553D);
  static const vertClair = Color(0xFF4E9A72);
  static const vertFonce = Color(0xFF2F6A4C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: Column(
        children: [
          _enTete(context),
          // Les deux cartes, centrées dans l'espace restant
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    _carteChoix(
                      image: 'assets/images/objets/choix_perdu.png',
                      titre: "J'ai perdu\nun objet",
                      texte: 'La communauté du campus vous aide à le retrouver.',
                      couleurs: const [corailClair, corailFonce],
                      onTap: () => _ouvrirFormulaire(context, 'perdu'),
                    ),
                    const SizedBox(height: 18),
                    _carteChoix(
                      image: 'assets/images/objets/choix_trouve.png',
                      titre: "J'ai trouvé\nun objet",
                      texte: "Aidez-le à retrouver vite son propriétaire.",
                      couleurs: const [vertClair, vertFonce],
                      onTap: () => _ouvrirFormulaire(context, 'trouve'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ouvre le formulaire en remplaçant cet écran : après la publication,
  /// le retour ramène directement à l'accueil.
  void _ouvrirFormulaire(BuildContext context, String type) {
    Navigator.pushReplacementNamed(context, Routes.formulaire, arguments: type);
  }

  /// En-tête marron avec des objets dessinés qui « flottent » à droite.
  Widget _enTete(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Couleurs.marronFonce,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 180,
          // Stack : on superpose le texte et les petites images
          child: Stack(
            children: [
              // Objets décoratifs, légèrement transparents
              Positioned(
                right: 18,
                top: 26,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('assets/images/objets/cles.png', width: 70),
                ),
              ),
              Positioned(
                right: 78,
                top: 82,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('assets/images/objets/telephone.png',
                      width: 64),
                ),
              ),
              Positioned(
                right: 6,
                top: 98,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('assets/images/objets/carte.png', width: 74),
                ),
              ),
              // Bouton retour vers l'accueil
              Positioned(
                left: 8,
                top: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Retour',
                ),
              ),
              // Textes
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 58, 150, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publier une annonce',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Que souhaitez-vous signaler ?',
                      style: TextStyle(color: Color(0xFFEADCC4), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grande carte colorée : texte blanc à gauche, illustration à droite
  /// dans un cercle clair.
  Widget _carteChoix({
    required String image,
    required String titre,
    required String texte,
    required List<Color> couleurs,
    required VoidCallback onTap,
  }) {
    // GestureDetector : rend toute la carte cliquable
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 14, 22),
      decoration: BoxDecoration(
        // Dégradé en diagonale : plus vivant qu'une couleur unie
        gradient: LinearGradient(
          colors: couleurs,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: couleurs.last.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texte,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Illustration dans un cercle clair
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
        ],
      ),
      ),
    );
  }
}
