import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'theme/couleurs.dart';

/// Point d'entrée de CampusLost.
///
/// Avant d'afficher le premier écran, on regarde si un utilisateur est déjà
/// connecté sur ce téléphone (connexion unique) :
///  - oui → on ouvre directement l'accueil ;
///  - non → on ouvre l'écran de bienvenue (inscription / connexion).
Future<void> main() async {
  // Obligatoire avant d'utiliser un plugin (SharedPreferences) dans main()
  WidgetsFlutterBinding.ensureInitialized();

  final utilisateur = await AuthService().chargerSession();

  runApp(
    // ProviderScope : obligatoire avec Riverpod, il contient tous les providers.
    // overrideWithValue donne à Riverpod la session lue sur le téléphone.
    ProviderScope(
      overrides: [utilisateurInitialProvider.overrideWithValue(utilisateur)],
      child: const CampusLostApp(),
    ),
  );
}

/// Racine de l'application CampusLost.
/// ConsumerWidget : un widget qui peut lire les providers avec « ref ».
class CampusLostApp extends ConsumerWidget {
  const CampusLostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusLost',
      debugShowCheckedModeBanner: false, // retire le bandeau « DEBUG »
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.marron),
        useMaterial3: true,
        // Messages flottants, au-dessus de la barre du bas
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        // Transitions « iOS » sur tous les téléphones : l'écran glisse depuis
        // la droite, et on peut revenir en arrière en faisant glisser son doigt
        // du bord gauche vers la droite (en plus des boutons de retour).
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // go_router gère toute la navigation
      routerConfig: ref.watch(routerProvider),
    );
  }
}
