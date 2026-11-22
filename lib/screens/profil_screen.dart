import 'package:campuslost/screens/login_screen.dart';
import 'package:campuslost/theme/couleurs.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête marron foncé avec avatar, nom et email
            Container(
              width: double.infinity,
              color: Couleurs.marronFonce,
              padding: const EdgeInsets.only(bottom: 32),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Cercle beige avec initiales AN
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Couleurs.beige,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'AN',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marronFonce,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nom complet
                    const Text(
                      'Awa Ndiaye',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Adresse email UGB
                    Text(
                      'awa.ndiaye@ugb.edu.sn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu principal (Statistiques + Menu)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Ligne des 3 cartes statistiques
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('3', 'Annonces')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('1', 'Restituée')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('1', 'Réclamation')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Carte blanche regroupant toutes les options du menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Couleurs.bordure),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.edit_outlined,
                          label: 'Modifier mon profil',
                          onTap: () {
                            // Action modifier le profil
                          },
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _buildMenuItem(
                          icon: Icons.list_alt_rounded,
                          label: 'Mes annonces',
                          onTap: () {
                            // Naviguer vers Mes annonces
                          },
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _buildMenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          onTap: () {
                            // Ouvrir les notifications
                          },
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        _buildMenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'À propos de CampusLost',
                          onTap: () {
                            // Afficher À propos
                          },
                        ),
                        const Divider(height: 1, color: Couleurs.bordure),
                        // Option Se déconnecter en rouge sans flèche à droite
                        _buildMenuItem(
                          icon: Icons.logout_rounded,
                          label: 'Se déconnecter',
                          estDeconnexion: true,
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          },
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Construit une carte statistique (ex: 3 Annonces)
  Widget _buildStatCard(String chiffre, String libelle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            libelle,
            style: const TextStyle(
              fontSize: 12,
              color: Couleurs.texteDiscret,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une ligne du menu d'options
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool estDeconnexion = false,
  }) {
    final couleurTexte =
    estDeconnexion ? const Color(0xFFB3261E) : Couleurs.texte;
    final couleurIcone =
    estDeconnexion ? const Color(0xFFB3261E) : Couleurs.marronFonce;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: couleurIcone),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: couleurTexte,
                ),
              ),
            ),
            if (!estDeconnexion)
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Couleurs.texteDiscret,
              ),
          ],
        ),
      ),
    );
  }

  /// Barre de navigation inférieure avec onglet « Profil » actif
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Couleurs.bordure)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Accueil', false),
              _buildNavItem(Icons.list_alt_rounded, 'Mes annonces', false),
              // Bouton central rond beige (+)
              GestureDetector(
                onTap: () {
                  // Action publier une annonce
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Couleurs.beige,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Couleurs.texte,
                    size: 28,
                  ),
                ),
              ),
              _buildNavItem(Icons.inbox_outlined, 'Réclamations', false),
              _buildNavItem(Icons.person_outline, 'Profil', true),
            ],
          ),
        ),
      ),
    );
  }

  /// Élément individuel de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, bool actif) {
    final couleur = actif ? Couleurs.marron : Couleurs.texteDiscret;

    return GestureDetector(
        onTap: () {
          // Navigation entre les écrans
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: couleur, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: actif ? FontWeight.bold : FontWeight.w500,
                color: couleur,
              ),
            ),
          ],
        ),
    );
  }
}