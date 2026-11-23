import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../theme/couleurs.dart';

/// Flèche de retour toujours présente.
///
/// - S'il y a un écran précédent : on y revient (comme le glissement).
/// - Sinon (écran ouvert directement) : on retourne à [secours],
///   par défaut l'écran de bienvenue. Aucun écran n'est donc « bloqué ».
class BoutonRetour extends StatelessWidget {
  final String secours;
  final Color couleur;

  const BoutonRetour({
    super.key,
    this.secours = Routes.bienvenue,
    this.couleur = Couleurs.marronFonce,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      icon: Icon(Icons.arrow_back, color: couleur),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(secours);
        }
      },
    );
  }
}
