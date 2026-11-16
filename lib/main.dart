import 'package:campuslost/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'screens/accueil_screen.dart';
import 'theme/couleurs.dart';

void main() {
  runApp(const CampusLostApp());
}

/// Racine de l'application CampusLost.
class CampusLostApp extends StatelessWidget {
  const CampusLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusLost',
      debugShowCheckedModeBanner: false, // retire le bandeau « DEBUG »
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.marron),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
