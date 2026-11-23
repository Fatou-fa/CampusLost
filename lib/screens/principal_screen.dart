import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../providers/reclamation_provider.dart';
import '../widgets/barre_navigation.dart';

/// Écran principal après la connexion : l'onglet affiché et la barre du bas.
///
/// [navigationShell] est fourni par go_router (StatefulShellRoute) : il
/// contient les 4 onglets et sait passer de l'un à l'autre (goBranch).
class PrincipalScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const PrincipalScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onglet = navigationShell.currentIndex;

    return PopScope(
      // Bouton retour Android : revient d'abord à l'accueil avant de quitter
      canPop: onglet == 0,
      onPopInvokedWithResult: (aQuitte, _) {
        if (!aQuitte) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        // Bouton « + » à cheval sur le haut de la barre (centerDocked).
        // On le cache quand le clavier est ouvert pour ne pas gêner la saisie.
        floatingActionButton: MediaQuery.viewInsetsOf(context).bottom > 0
            ? null
            : BoutonPublier(onPressed: () => context.push(Routes.publier)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BarreNavigation(
          index: onglet,
          // Nombre de réclamations à traiter, pour le badge
          badge: ref.watch(nbATraiterProvider),
          // Retoucher l'onglet actif le ramène à son premier écran
          onChange: (i) => navigationShell.goBranch(i, initialLocation: i == onglet),
        ),
      ),
    );
  }
}
