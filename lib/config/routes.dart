import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/accueil_screen.dart';
import '../screens/bienvenue_screen.dart';
import '../screens/choix_type_screen.dart';
import '../screens/conversation_screen.dart';
import '../screens/detail_annonce_screen.dart';
import '../screens/formulaire_annonce_screen.dart';
import '../screens/inscription_screen.dart';
import '../screens/login_screen.dart';
import '../screens/mes_annonces_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/modifier_profil_screen.dart';
import '../screens/principal_screen.dart';
import '../screens/profil_screen.dart';
import '../screens/reclamations_screen.dart';

/// Adresses des écrans (go_router navigue avec des adresses, comme un site web).
///
///   context.go(Routes.accueil)          → remplace tout par l'accueil
///   context.push(Routes.detail(3))      → ouvre le détail par-dessus
///   context.pop()                       → revient à l'écran précédent
class Routes {
  // Écrans accessibles sans être connecté
  static const bienvenue = '/bienvenue';
  static const connexion = '/connexion';
  static const inscription = '/inscription';

  // Les 4 onglets de la barre du bas
  static const accueil = '/accueil';
  static const mesAnnonces = '/mes-annonces';
  static const reclamations = '/reclamations';
  static const profil = '/profil';

  // Écrans ouverts par-dessus les onglets
  static const publier = '/publier';
  static const modifierProfil = '/modifier-profil';
  static const messages = '/messages';
  static String formulaire(String type) => '/formulaire/$type'; // perdu / trouve
  static String detail(String id) => '/annonce/$id';
  static String modifierAnnonce(String id) => '/modifier-annonce/$id';

  /// Conversation ; [texte] pré-remplit la zone de saisie (?texte=…).
  static String conversation(String id, {String texte = ''}) => texte.isEmpty
      ? '/conversation/$id'
      : '/conversation/$id?texte=${Uri.encodeComponent(texte)}';

  static const _publiques = [bienvenue, connexion, inscription];
}

/// Le routeur de l'application, fourni par Riverpod pour pouvoir lire
/// la session (authProvider) dans la redirection.
final routerProvider = Provider<GoRouter>((ref) {
  final dejaConnecte = ref.read(authProvider) != null;

  return GoRouter(
    initialLocation: dejaConnecte ? Routes.accueil : Routes.bienvenue,

    // Protection des écrans : appelée avant chaque changement d'écran.
    // Retourne une autre adresse pour rediriger, ou null pour laisser passer.
    redirect: (context, state) {
      final connecte = ref.read(authProvider) != null;
      final pagePublique = Routes._publiques.contains(state.matchedLocation);
      if (!connecte && !pagePublique) return Routes.bienvenue;
      if (connecte && pagePublique) return Routes.accueil;
      return null;
    },

    routes: [
      GoRoute(path: Routes.bienvenue, builder: (_, _) => const BienvenueScreen()),
      GoRoute(path: Routes.connexion, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.inscription, builder: (_, _) => const InscriptionScreen()),

      // Les 4 onglets : StatefulShellRoute garde chaque onglet en mémoire
      // (position, recherche…) et affiche la barre du bas autour.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PrincipalScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.accueil, builder: (_, _) => const AccueilScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.mesAnnonces, builder: (_, _) => const MesAnnoncesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.reclamations, builder: (_, _) => const ReclamationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.profil, builder: (_, _) => const ProfilScreen()),
          ]),
        ],
      ),

      // Écrans plein écran, par-dessus la barre du bas
      GoRoute(path: Routes.publier, builder: (_, _) => const ChoixTypeScreen()),
      GoRoute(
        path: '/formulaire/:type', // :type = paramètre dans l'adresse
        builder: (_, state) =>
            FormulaireAnnonceScreen(type: state.pathParameters['type'] ?? 'trouve'),
      ),
      GoRoute(
        path: '/modifier-annonce/:id',
        builder: (_, state) => FormulaireAnnonceScreen(
            annonceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/annonce/:id',
        builder: (_, state) =>
            DetailAnnonceScreen(annonceId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: Routes.modifierProfil,
          builder: (_, _) => const ModifierProfilScreen()),
      GoRoute(path: Routes.messages, builder: (_, _) => const MessagesScreen()),
      GoRoute(
        path: '/conversation/:id',
        builder: (_, state) => ConversationScreen(
          conversationId: state.pathParameters['id']!,
          // Paramètre facultatif dans l'adresse : ?texte=…
          texteInitial: state.uri.queryParameters['texte'] ?? '',
        ),
      ),
    ],

    // Adresse inconnue
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});
