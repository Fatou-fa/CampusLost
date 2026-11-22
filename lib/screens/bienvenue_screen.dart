import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Première page de l'application.
///
/// En haut, une illustration sur fond marron : le logo CampusLost entouré
/// d'objets souvent perdus sur le campus. En bas, un panneau clair arrondi
/// avec le nom de l'app, son utilité et les boutons.
class BienvenueScreen extends StatelessWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond marron : il se confond avec celui de l'illustration
      backgroundColor: Couleurs.marronFonce,
      body: Column(
        children: [
          // ---------- Illustration (partie haute) ----------
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/bienvenue_illustration.png',
                  fit: BoxFit.contain, // l'image garde ses proportions
                ),
              ),
            ),
          ),

          // ---------- Panneau clair (partie basse) ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: const BoxDecoration(
              color: Couleurs.fond,
              // Coins arrondis seulement en haut
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min, // prend juste la place du contenu
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'CampusLost',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Couleurs.marronFonce,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Vous avez perdu ou trouvé un objet sur le campus ? '
                    'Retrouvez-le en quelques minutes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Couleurs.texte,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bouton principal
                  ElevatedButton(
                    onPressed: () {
                      // Plus tard : ouvrir l'écran d'inscription
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
                      'Créer un compte',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton secondaire
                  OutlinedButton(
                    onPressed: () {
                      // Plus tard : ouvrir l'écran de connexion
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Couleurs.marron,
                      side: const BorderSide(color: Couleurs.marron, width: 1.5),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "J'ai déjà un compte",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mention discrète de l'université
                  const Text(
                    'Université Gaston Berger de Saint-Louis',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, color: Couleurs.texteDiscret),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
