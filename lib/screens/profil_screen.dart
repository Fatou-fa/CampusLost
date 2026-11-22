import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../models/annonce_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reclamation_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';

/// Onglet « Profil » (design de Gilbert) : identité de l'utilisateur,
/// statistiques et menu (modifier le profil, raccourcis, à propos,
/// déconnexion).
class ProfilScreen extends StatelessWidget {
  /// Change d'onglet dans l'écran principal (1 = Mes annonces, 2 = Réclamations).
  final ValueChanged<int> allerA;

  const ProfilScreen({super.key, required this.allerA});

  @override
  Widget build(BuildContext context) {
    final moi = context.watch<AuthProvider>().utilisateur;
    final annonces = context.watch<AnnonceProvider>();
    final reclamations = context.watch<ReclamationProvider>();

    final prenom = majuscule(moi?.prenom ?? '');
    final nom = majuscule(moi?.nom ?? '');
    final mesAnnonces = moi == null ? <Annonce>[] : annonces.deAuteur(moi.id);
    final nbRestituees = mesAnnonces.where((a) => a.estRestituee).length;
    final nbReclamations =
        reclamations.recues(mesAnnonces.map((a) => a.id).toList()).length;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- En-tête : avatar, nom, email ----------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Couleurs.marronFonce,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.only(bottom: 32),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Couleurs.beige,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initiales('$prenom $nom'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marronFonce,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$prenom $nom'.trim(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      moi?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if ((moi?.telephone ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        moi!.telephone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ---------- Statistiques et menu ----------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _statistique('${mesAnnonces.length}', 'Annonces',
                            () => allerA(1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statistique('$nbRestituees',
                            nbRestituees > 1 ? 'Restituées' : 'Restituée', () => allerA(1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statistique('$nbReclamations',
                            nbReclamations > 1 ? 'Réclamations' : 'Réclamation',
                            () => allerA(2)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Couleurs.bordure),
                    ),
                    child: Column(
                      children: [
                        _ligneMenu(
                          icone: Icons.edit_outlined,
                          libelle: 'Modifier mon profil',
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.modifierProfil),
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _ligneMenu(
                          icone: Icons.list_alt_rounded,
                          libelle: 'Mes annonces',
                          onTap: () => allerA(1),
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _ligneMenu(
                          icone: Icons.inbox_outlined,
                          libelle: 'Mes réclamations',
                          onTap: () => allerA(2),
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _ligneMenu(
                          icone: Icons.info_outline_rounded,
                          libelle: 'À propos de CampusLost',
                          onTap: () => _aPropos(context),
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _ligneMenu(
                          icone: Icons.logout_rounded,
                          libelle: 'Se déconnecter',
                          estDeconnexion: true,
                          onTap: () => confirmerDeconnexion(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte statistique cliquable (ex. : « 3 Annonces »).
  Widget _statistique(String chiffre, String libelle, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Couleurs.bordure),
          ),
          child: Column(
            children: [
              Text(
                chiffre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
              const SizedBox(height: 4),
              Text(libelle,
                  style: const TextStyle(fontSize: 12, color: Couleurs.texteDiscret)),
            ],
          ),
        ),
      ),
    );
  }

  /// Une ligne du menu ; la déconnexion est en rouge, sans flèche.
  Widget _ligneMenu({
    required IconData icone,
    required String libelle,
    required VoidCallback onTap,
    bool estDeconnexion = false,
  }) {
    const rouge = Color(0xFFB3261E);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icone, size: 22, color: estDeconnexion ? rouge : Couleurs.marronFonce),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                libelle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: estDeconnexion ? rouge : Couleurs.texte,
                ),
              ),
            ),
            if (!estDeconnexion)
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: Couleurs.texteDiscret),
          ],
        ),
      ),
    );
  }

  /// Fenêtre « À propos » fournie par Flutter (avec la liste des licences).
  void _aPropos(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CampusLost',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/images/icone_app_ugb.png', width: 52),
      ),
      children: const [
        SizedBox(height: 8),
        Text(
          'Objets perdus et trouvés sur le campus de '
          "l'Université Gaston Berger de Saint-Louis.",
        ),
        SizedBox(height: 12),
        Text('Réalisé par Fatou Fall et Gilbert Ngor Thiomby Diouf'),
        Text('GIT3 — IPSL, cours de développement mobile'),
      ],
    );
  }
}
