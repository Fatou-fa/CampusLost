import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Affiche la photo d'une annonce, quelle que soit son origine :
///  - une image fournie avec l'application (chemin « assets/… ») ;
///  - une photo enregistrée dans Firestore (texte « data:image/…;base64,… ») ;
///  - une photo qui vient d'être prise (chemin d'un fichier du téléphone) ;
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

  /// Photos déjà décodées : on ne refait pas le calcul à chaque affichage.
  static final Map<String, Uint8List> _cache = {};

  @override
  Widget build(BuildContext context) {
    final icone = Icon(Icons.inventory_2_outlined,
        color: Couleurs.marron, size: tailleIcone);

    final c = chemin;
    if (c == null || c.isEmpty) return icone;

    if (c.startsWith('assets/')) {
      return Image.asset(c, height: hauteur, fit: ajustement);
    }

    if (c.startsWith('data:image')) {
      final octets = _cache.putIfAbsent(
          c, () => base64Decode(c.substring(c.indexOf(',') + 1)));
      return Image.memory(
        octets,
        height: hauteur,
        fit: ajustement,
        gaplessPlayback: true, // pas de clignotement au redessin
        errorBuilder: (_, _, _) => icone,
      );
    }

    // Photo du téléphone ; si le fichier n'existe plus, on montre l'icône
    return Image.file(
      File(c),
      height: hauteur,
      fit: ajustement,
      errorBuilder: (_, _, _) => icone,
    );
  }
}
