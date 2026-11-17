import 'package:flutter/material.dart';

import 'models/annonce_model.dart';
import 'screens/accueil_screen.dart';
import 'screens/bienvenue_screen.dart';
import 'screens/choix_type_screen.dart';
import 'screens/detail_annonce_screen.dart';
import 'screens/formulaire_annonce_screen.dart';
import 'screens/inscription_screen.dart';
import 'screens/login_screen.dart';
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
    
      // Pas encore de navigation

      //home: const BienvenueScreen(),
      //home: const InscriptionScreen(),
      //home: const LoginScreen(), 
      //home: const AccueilScreen(),

      //home: const ChoixTypeScreen(),
      //home: const FormulaireAnnonceScreen(),              // objet trouvé
      //home: const FormulaireAnnonceScreen(type: 'perdu'), // objet perdu
      home: DetailAnnonceScreen(annonce: annonceExemple),
    );
  }
}



/// Annonce d'exemple pour tester l'écran de détail sans navigation.
final annonceExemple = Annonce(
  id: 2,
  titre: 'Trousseau de clés',
  description:
      "Deux clés sur un anneau argenté, dont une dorée. Trouvées sur une "
      "table près de l'entrée du Resto U, à l'heure du déjeuner.",
  type: 'trouve',
  statut: 'active',
  photoUrl: 'assets/images/objets/cles.png',
  date: '17/11/2025, 12 h 30',
  categorie: 'Clés',
  lieu: 'Resto U',
  auteurId: 2,
  auteurNom: 'Moussa D.',
);
