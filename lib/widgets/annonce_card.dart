import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../theme/couleurs.dart';

/// Carte d'une annonce (affichage seul) : photo de l'objet, badge
/// Perdu / Trouvé, titre, lieu et date.
class AnnonceCard extends StatelessWidget {
  final Annonce annonce;
  const AnnonceCard({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    // Perdu : beige clair et texte brun ; Trouvé : marron et texte blanc
    final fondBadge = annonce.estPerdue ? Couleurs.beigeClair : Couleurs.marron;
    final texteBadge = annonce.estPerdue ? Couleurs.marron : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Ombre douce : la carte semble posée sur la page
        boxShadow: [
          BoxShadow(
            color: Couleurs.marronFonce.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ---------- Photo de l'objet ----------
              Container(
                width: 84,
                height: 84,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Couleurs.beigeTrouve,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: annonce.photoUrl != null
                    ? Image.asset(annonce.photoUrl!, fit: BoxFit.contain)
                    : const Icon(Icons.inventory_2_outlined,
                        color: Couleurs.marron, size: 36),
              ),
              const SizedBox(width: 14),

              // ---------- Textes ----------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Perdu / Trouvé
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: fondBadge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        annonce.estPerdue ? 'Perdu' : 'Trouvé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: texteBadge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      annonce.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Couleurs.texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Lieu
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 15, color: Couleurs.texteDiscret),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            annonce.lieu,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: Couleurs.texteDiscret),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 15, color: Couleurs.texteDiscret),
                        const SizedBox(width: 4),
                        Text(
                          annonce.date,
                          style: const TextStyle(
                              fontSize: 13, color: Couleurs.texteDiscret),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}
