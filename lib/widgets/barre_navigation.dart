import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Barre de navigation du bas (design de Gilbert) :
/// Accueil · Mes annonces · [+] · Réclamations · Profil.
///
/// [index] est l'onglet affiché (0 à 3), [onChange] est appelé quand
/// l'utilisateur touche un onglet, [onPublier] quand il touche le « + ».
/// [badge] affiche un petit compteur sur « Réclamations » (0 = rien).
class BarreNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  final VoidCallback onPublier;
  final int badge;

  const BarreNavigation({
    super.key,
    required this.index,
    required this.onChange,
    required this.onPublier,
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
              // Bouton central rond pour publier
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: 'Publier une annonce',
                    child: GestureDetector(
                      onTap: onPublier,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Couleurs.marron,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Couleurs.marronFonce.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
              ),
              _onglet(2, Icons.inbox_outlined, Icons.inbox_rounded, 'Réclamations',
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
