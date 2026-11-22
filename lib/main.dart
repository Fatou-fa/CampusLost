import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'providers/annonce_provider.dart';
import 'providers/auth_provider.dart';
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

  final auth = AuthProvider();
  await auth.chargerSession();

  runApp(
    // MultiProvider rend les providers accessibles à tous les écrans
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => AnnonceProvider()),
      ],
      child: const CampusLostApp(),
    ),
  );
}

/// Racine de l'application CampusLost.
class CampusLostApp extends StatelessWidget {
  const CampusLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    // read : on lit l'état une seule fois, au démarrage
    final dejaConnecte = context.read<AuthProvider>().estConnecte;

    return MaterialApp(
      title: 'CampusLost',
      debugShowCheckedModeBanner: false, // retire le bandeau « DEBUG »
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.marron),
        useMaterial3: true,
      ),
      // Premier écran selon la session, puis navigation par nom (Routes)
      initialRoute: dejaConnecte ? Routes.accueil : Routes.bienvenue,
      onGenerateRoute: Routes.generer,
    );
  }
}
