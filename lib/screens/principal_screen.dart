import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reclamation_provider.dart';
import '../widgets/barre_navigation.dart';
import 'accueil_screen.dart';
import 'mes_annonces_screen.dart';
import 'profil_screen.dart';
import 'reclamations_screen.dart';

/// Écran principal après la connexion : les 4 onglets et la barre du bas.
///
/// IndexedStack garde les 4 pages en mémoire : quand on change d'onglet,
/// chaque page retrouve sa position (défilement, recherche…).
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _onglet = 0; // 0 Accueil, 1 Mes annonces, 2 Réclamations, 3 Profil

  void _allerA(int onglet) => setState(() => _onglet = onglet);

  @override
  Widget build(BuildContext context) {
    // Nombre de réclamations reçues en attente, pour le badge
    final moi = context.watch<AuthProvider>().utilisateur;
    final mesIds = moi == null
        ? <int>[]
        : context
            .watch<AnnonceProvider>()
            .deAuteur(moi.id)
            .map((a) => a.id)
            .toList();
    final aTraiter = context.watch<ReclamationProvider>().enAttente(mesIds);

    return PopScope(
      // Bouton retour Android : revient d'abord à l'accueil avant de quitter
      canPop: _onglet == 0,
      onPopInvokedWithResult: (aQuitte, _) {
        if (!aQuitte) _allerA(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _onglet,
          children: [
            const AccueilScreen(),
            const MesAnnoncesScreen(),
            const ReclamationsScreen(),
            ProfilScreen(allerA: _allerA),
          ],
        ),
        bottomNavigationBar: BarreNavigation(
          index: _onglet,
          badge: aTraiter,
          onChange: _allerA,
          onPublier: () => Navigator.pushNamed(context, Routes.choixType),
        ),
      ),
    );
  }
}
