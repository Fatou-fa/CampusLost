import 'package:campuslost/theme/couleurs.dart';
import 'package:flutter/material.dart';

class MesAnnoncesScreen extends StatefulWidget {
  const MesAnnoncesScreen({super.key});

  @override
  State<MesAnnoncesScreen> createState() => _MesAnnoncesScreenState();
}

class _MesAnnoncesScreenState extends State<MesAnnoncesScreen> {
  // 0 = En cours, 1 = Restituées
  int _ongletActif = 0;

  // Données de démonstration
  final List<Map<String, dynamic>> _annoncesEnCours = [
    {
      'statut': 'PERDU',
      'titre': "Carte d'étudiant",
      'details': "Bibliothèque · aujourd'hui",
      'icone': Icons.badge_outlined,
    },
    {
      'statut': 'TROUVÉ',
      'titre': 'Clé USB',
      'details': 'Salle informatique · lundi · 1 réclamation',
      'icone': Icons.usb_outlined,
    },
  ];

  final List<Map<String, dynamic>> _annoncesRestituees = [
    {
      'statut': 'TROUVÉ',
      'titre': 'Trousse noire',
      'details': 'Amphi A · la semaine dernière',
      'icone': Icons.work_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final annoncesAffichees =
    _ongletActif == 0 ? _annoncesEnCours : _annoncesRestituees;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              const Text(
                'Mes annonces',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
              const SizedBox(height: 20),

              // Sélecteur d'onglets (En cours / Restituées)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Couleurs.beigeTrouve,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildOnglet(
                      index: 0,
                      titre: 'En cours (${_annoncesEnCours.length})',
                    ),
                    _buildOnglet(
                      index: 1,
                      titre: 'Restituées (${_annoncesRestituees.length})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Liste des cartes d'annonces
              Expanded(
                child: ListView.separated(
                  itemCount: annoncesAffichees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildCarteAnnonce(annoncesAffichees[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Barre de navigation inférieure avec bouton central +
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Construit un bouton d'onglet (En cours ou Restituées)
  Widget _buildOnglet({required int index, required String titre}) {
    final estActif = _ongletActif == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _ongletActif = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: estActif ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: estActif
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: estActif ? FontWeight.bold : FontWeight.w500,
              color: estActif ? Couleurs.marronFonce : Couleurs.texteDiscret,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit une carte d'annonce (PERDU ou TROUVÉ)
  Widget _buildCarteAnnonce(Map<String, dynamic> annonce) {
    final estPerdu = annonce['statut'] == 'PERDU';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carré d'icône beige à gauche
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Couleurs.beigeTrouve,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  annonce['icone'] as IconData,
                  color: Couleurs.marron,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Badge + Titre + Sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge PERDU / TROUVÉ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: estPerdu
                            ? Couleurs.beigeClair
                            : Couleurs.beigeTrouve,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        annonce['statut'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marron,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Titre de l'objet
                    Text(
                      annonce['titre'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Couleurs.texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Lieu et date
                    Text(
                      annonce['details'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Couleurs.texteDiscret,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Boutons d'action uniquement pour les annonces "En cours"
          if (_ongletActif == 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Action Modifier
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Couleurs.texte,
                    side: const BorderSide(color: Couleurs.bordure),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text(
                    'Modifier',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Basculer l'annonce vers Restituées
                    setState(() {
                      _annoncesEnCours.remove(annonce);
                      _annoncesRestituees.add(annonce);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Couleurs.marron,
                    side: const BorderSide(color: Couleurs.bordure),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 17),
                  label: const Text(
                    'Restituée',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construit la barre de navigation du bas avec le bouton rond central +
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
              _buildNavItem(Icons.list_alt_rounded, 'Mes annonces', true),
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
              _buildNavItem(Icons.person_outline, 'Profil', false),
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