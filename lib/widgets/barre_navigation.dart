import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Barre de navigation du bas (design de Gilbert) :
/// Accueil · Mes annonces · [espace du +] · Demandes · Profil.
///
/// Le bouton « + » n'est pas dans la barre : c'est [BoutonPublier], posé
/// à cheval sur le bord supérieur de la barre par le Scaffold
/// (floatingActionButtonLocation: centerDocked). La barre lui laisse
/// un espace vide au milieu.
///
/// [index] est l'onglet affiché (0 à 3), [onChange] est appelé quand
/// l'utilisateur touche un onglet. [badge] affiche un petit compteur sur
/// « Demandes » (0 = rien).
class BarreNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  final int badge;

  const BarreNavigation({
    super.key,
    required this.index,
    required this.onChange,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Couleurs.bordure)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _onglet(0, Icons.home_outlined, Icons.home_rounded, 'Accueil'),
              _onglet(1, Icons.list_alt_outlined, Icons.list_alt_rounded,
                  'Mes annonces'),
              // Espace réservé au bouton « + » qui flotte au-dessus
              const SizedBox(width: 76),
              _onglet(2, Icons.inbox_outlined, Icons.inbox_rounded, 'Demandes',
                  compteur: badge),
              _onglet(3, Icons.person_outline, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  /// Un onglet : icône (pleine si actif) + libellé, avec un badge facultatif.
  Widget _onglet(int numero, IconData icone, IconData iconeActive, String libelle,
      {int compteur = 0}) {
    final actif = index == numero;
    final couleur = actif ? Couleurs.marron : Couleurs.texteDiscret;

    return Expanded(
      child: InkWell(
        onTap: () => onChange(numero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge : widget Material 3 qui pose un compteur sur l'icône
            Badge(
              isLabelVisible: compteur > 0,
              label: Text('$compteur'),
              backgroundColor: const Color(0xFFC8553D),
              child: Icon(actif ? iconeActive : icone, color: couleur, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: actif ? FontWeight.bold : FontWeight.w500,
                color: couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton rond « + » pour publier une annonce, entouré d'un halo
/// marron transparent pour bien le distinguer.
class BoutonPublier extends StatelessWidget {
  final VoidCallback onPressed;

  const BoutonPublier({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(8),
      // Cercle extérieur transparent (le « halo »)
      decoration: BoxDecoration(
        color: Couleurs.marron.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Couleurs.marron,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Couleurs.marronFonce,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Tooltip(
            message: 'Publier une annonce',
            child: Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 34),
            ),
          ),
        ),
      ),
    );
  }
}
