import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';

/// Barre latérale (Drawer) de l'accueil, ouverte en appuyant sur le logo.
///
/// Elle affiche le profil de l'utilisateur connecté et le bouton de
/// déconnexion.
class BarreLaterale extends StatelessWidget {
  const BarreLaterale({super.key});

  @override
  Widget build(BuildContext context) {
    // watch : la barre se met à jour si l'utilisateur change
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final prenom = utilisateur?.prenom ?? '';
    final nom = utilisateur?.nom ?? '';

    return Drawer(
      backgroundColor: Couleurs.fond,
      child: Column(
        children: [
          // ---------- En-tête : logo CampusLost / UGB ----------
          Container(
            width: double.infinity,
            color: Couleurs.marronFonce,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/images/icone_app_ugb.png',
                          width: 56, height: 56),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CampusLost',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Université Gaston Berger',
                            style: TextStyle(
                                color: Color(0xFFEADCC4), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------- Profil ----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Mon profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.marronFonce,
                  ),
                ),
                const SizedBox(height: 16),
                // Avatar avec les initiales, puis le nom complet
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Couleurs.beige,
                      child: Text(
                        _initiales(prenom, nom),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marronFonce,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '$prenom $nom'.trim(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.texte,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ligne(Icons.mail_outline, 'Email', utilisateur?.email ?? ''),
                const SizedBox(height: 10),
                _ligne(Icons.phone_outlined, 'Téléphone',
                    utilisateur?.telephone ?? ''),
              ],
            ),
          ),

          // ---------- Déconnexion (en bas) ----------
          const Divider(height: 1, color: Couleurs.bordure),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Couleurs.marron),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(
                  color: Couleurs.marron,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => confirmerDeconnexion(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Première lettre du prénom et du nom (ex. « Fatou Fall » → « FF »).
  String _initiales(String prenom, String nom) {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return (p + n).toUpperCase();
  }

  /// Une information du profil dans une petite carte blanche.
  Widget _ligne(IconData icone, String libelle, String valeur) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Couleurs.marron),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(libelle,
                    style: const TextStyle(
                        fontSize: 12, color: Couleurs.texteDiscret)),
                const SizedBox(height: 2),
                Text(valeur,
                    style:
                        const TextStyle(fontSize: 15, color: Couleurs.texte)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
