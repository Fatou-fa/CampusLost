import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../theme/couleurs.dart';

/// Carte affichant le résumé d'une annonce dans une liste.
class AnnonceCard extends StatelessWidget {
  final Annonce annonce;
  final VoidCallback? onTap; // action au clic (ouvrir le détail)

  const AnnonceCard({super.key, required this.annonce, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Beige clair pour « perdu », beige plus soutenu pour « trouvé »
    final couleurBadge =
        annonce.estPerdue ? Couleurs.beigeClair : Couleurs.beigeTrouve;
    final texteBadge = annonce.estPerdue ? 'PERDU' : 'TROUVÉ';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Couleurs.bordure),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        // Icône à gauche
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: couleurBadge,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Couleurs.marron),
        ),
        // Badge + titre
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: couleurBadge,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                texteBadge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marron,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              annonce.titre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        // Lieu et date
        subtitle: Row(
          children: [
            const Icon(Icons.place_outlined,
                size: 14, color: Couleurs.texteDiscret),
            const SizedBox(width: 4),
            // Flexible : le texte passe à la ligne au lieu de déborder
            Flexible(child: Text('${annonce.lieu} · ${annonce.date}')),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
