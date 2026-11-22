import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Affiche la photo d'une annonce, quelle que soit son origine :
///  - une image fournie avec l'application (chemin « assets/… ») ;
///  - une photo prise avec le téléphone (chemin d'un fichier) ;
///  - rien (null) : une icône de carton à la place.
class PhotoAnnonce extends StatelessWidget {
  final String? chemin;
  final double? hauteur;
  final BoxFit ajustement;
  final double tailleIcone;

  const PhotoAnnonce({
    super.key,
    required this.chemin,
    this.hauteur,
    this.ajustement = BoxFit.contain,
    this.tailleIcone = 36,
  });

  @override
  Widget build(BuildContext context) {
    final icone = Icon(Icons.inventory_2_outlined,
        color: Couleurs.marron, size: tailleIcone);

    if (chemin == null || chemin!.isEmpty) return icone;

    if (chemin!.startsWith('assets/')) {
      return Image.asset(chemin!, height: hauteur, fit: ajustement);
    }
    // Photo du téléphone ; si le fichier n'existe plus, on montre l'icône
    return Image.file(
      File(chemin!),
      height: hauteur,
      fit: ajustement,
      errorBuilder: (_, _, _) => icone,
    );
  }
}
