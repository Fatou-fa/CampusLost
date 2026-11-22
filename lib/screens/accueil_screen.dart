import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../widgets/annonce_card.dart';
import '../widgets/barre_laterale.dart';

/// Écran d'accueil : recherche, catégories et annonces récentes.
///
/// Les annonces viennent de [AnnonceProvider] et le prénom affiché de
/// [AuthProvider]. Navigation : appui sur une annonce (détail) et appui sur
/// le logo (barre latérale). Le bouton « + » est dans la barre du bas.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch : l'écran se redessine quand la liste ou la recherche change
    final annonces = context.watch<AnnonceProvider>();
    final resultats = annonces.resultats;
    final prenom = context.watch<AuthProvider>().utilisateur?.prenom ?? '';

    return Scaffold(
      backgroundColor: Couleurs.fond,
      // Barre latérale : profil et déconnexion
      drawer: const BarreLaterale(),
      // ListView : toute la page défile, en-tête compris
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _enTete(context, prenom),
          const SizedBox(height: 20),
          _titreSection('Catégories'),
          const SizedBox(height: 12),
          _listeCategories(annonces),
          const SizedBox(height: 24),
          _titreSection(annonces.categorie ?? 'Annonces récentes',
              detail: '${resultats.length} annonces'),
          // Lien pour revenir à la liste globale quand un filtre est actif
          if (annonces.categorie != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: annonces.afficherTout,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Voir toutes les annonces'),
                style: TextButton.styleFrom(
                  foregroundColor: Couleurs.marron,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // ---------- Liste des annonces ----------
          if (resultats.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Aucune annonce pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Couleurs.texteDiscret),
              ),
            )
          else
            for (final annonce in resultats)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: AnnonceCard(
                  annonce: annonce,
                  // Ouvre le détail en lui passant l'annonce choisie
                  onTap: () => Navigator.pushNamed(context, Routes.detail,
                      arguments: annonce),
                ),
              ),
          const SizedBox(height: 24),
        ],
      ),

    );
  }

  /// En-tête marron arrondi : logo, salutation, déconnexion et recherche.
  Widget _enTete(BuildContext context, String prenom) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        color: Couleurs.marronFonce,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                // Logo CampusLost / UGB dans un cercle beige : un appui
                // ouvre la barre latérale. Builder fournit un context situé
                // SOUS le Scaffold, nécessaire pour que Scaffold.of() le trouve.
                Builder(
                  builder: (contexteScaffold) => GestureDetector(
                    onTap: () => Scaffold.of(contexteScaffold).openDrawer(),
                    child: Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Couleurs.beigeClair,
                        shape: BoxShape.circle,
                        border: Border.all(color: Couleurs.beige, width: 2),
                      ),
                      child: Image.asset(
                          'assets/images/logo_campuslost_ugb.png'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bonjour ${_majuscule(prenom)}',
                  style: const TextStyle(
                    color: Color(0xFFEADCC4),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Titre en police manuscrite, avec un dégradé sur les lettres
            _titreDegrade('Bienvenue au carrefour\ndes objets'),
            const SizedBox(height: 18),
            // Barre de recherche
            TextField(
              onChanged: (texte) =>
                  context.read<AnnonceProvider>().rechercher(texte),
              decoration: InputDecoration(
                hintText: 'Rechercher un objet…',
                prefixIcon: const Icon(Icons.search, color: Couleurs.marron),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Texte dont les lettres sont colorées par un dégradé
  /// (beige clair → doré → corail).
  /// ShaderMask peint le dégradé uniquement là où il y a du texte.
  Widget _titreDegrade(String texte) {
    return ShaderMask(
      shaderCallback: (zone) => const LinearGradient(
        colors: [Color(0xFFFBF2E1), Color(0xFFE8BE6E), Color(0xFFE07A5F)],
      ).createShader(zone),
      child: Text(
        texte,
        style: const TextStyle(
          fontFamily: 'Pacifico', // déclarée dans pubspec.yaml
          fontSize: 28,
          height: 1.35,
          color: Colors.white, // obligatoire : le dégradé remplace ce blanc
        ),
      ),
    );
  }

  /// Met la première lettre en majuscule (« fatou » → « Fatou »).
  String _majuscule(String mot) {
    if (mot.isEmpty) return mot;
    return mot[0].toUpperCase() + mot.substring(1);
  }

  /// Titre de section, avec un petit texte à droite si besoin.
  Widget _titreSection(String titre, {String? detail}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Couleurs.marronFonce,
            ),
          ),
          if (detail != null)
            Text(detail,
                style: const TextStyle(fontSize: 13, color: Couleurs.texteDiscret)),
        ],
      ),
    );
  }

  /// Catégories affichées en grille : si elles ne tiennent pas sur une ligne,
  /// elles passent à la ligne suivante (Wrap), sans défilement horizontal.
  /// La première tuile, « Toutes », affiche la liste globale des annonces.
  /// [annonces] est le provider déjà lu dans build() (on n'utilise pas
  /// context.read ici, interdit pendant la construction de l'écran).
  Widget _listeCategories(AnnonceProvider annonces) {
    final choisie = annonces.categorie; // null = toutes

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12, // espace horizontal entre deux catégories
        runSpacing: 16, // espace vertical entre deux lignes
        children: [
          // Tuile « Toutes » : retire le filtre
          _tuile(
            libelle: 'Toutes',
            icone: const Icon(Icons.apps_rounded,
                size: 40, color: Couleurs.marron),
            estChoisie: choisie == null,
            onTap: annonces.afficherTout,
          ),
          // Une tuile par catégorie
          for (final categorie in AnnonceProvider.categories)
            _tuile(
              libelle: categorie[0],
              icone: Image.asset(categorie[1], fit: BoxFit.contain),
              estChoisie: categorie[0] == choisie,
              onTap: () => annonces.choisirCategorie(categorie[0]),
            ),
        ],
      ),
    );
  }

  /// Une tuile de catégorie : image dans un carré blanc arrondi et libellé.
  /// La tuile choisie a un fond beige, une bordure marron et un texte gras.
  Widget _tuile({
    required String libelle,
    required Widget icone,
    required bool estChoisie,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: estChoisie ? Couleurs.beigeClair : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: estChoisie ? Couleurs.marron : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Couleurs.marronFonce.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: icone,
            ),
            const SizedBox(height: 8),
            Text(
              libelle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Couleurs.texte,
                fontWeight: estChoisie ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
