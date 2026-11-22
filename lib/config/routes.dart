import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../screens/accueil_screen.dart';
import '../screens/bienvenue_screen.dart';
import '../screens/choix_type_screen.dart';
import '../screens/detail_annonce_screen.dart';
import '../screens/formulaire_annonce_screen.dart';
import '../screens/inscription_screen.dart';
import '../screens/login_screen.dart';

/// Noms des écrans et construction de chaque page.
///
/// On navigue avec un nom, par exemple :
///   Navigator.pushNamed(context, Routes.accueil);
/// Les écrans qui ont besoin d'une donnée la reçoivent dans `arguments` :
///   Navigator.pushNamed(context, Routes.detail, arguments: annonce);
class Routes {
  static const String bienvenue = '/bienvenue';
  static const String connexion = '/connexion';
  static const String inscription = '/inscription';
  static const String accueil = '/accueil';
  static const String choixType = '/publier';
  static const String formulaire = '/publier/formulaire';
  static const String detail = '/annonce';

  /// Appelée par MaterialApp chaque fois qu'on demande un écran par son nom.
  static Route<dynamic> generer(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case connexion:
        page = const LoginScreen();
        break;
      case inscription:
        page = const InscriptionScreen();
        break;
      case accueil:
        page = const AccueilScreen();
        break;
      case choixType:
        page = const ChoixTypeScreen();
        break;
      case formulaire:
        // 'perdu' ou 'trouve', envoyé par l'écran « Publier une annonce »
        final type = settings.arguments as String? ?? 'trouve';
        page = FormulaireAnnonceScreen(type: type);
        break;
      case detail:
        page = DetailAnnonceScreen(annonce: settings.arguments as Annonce);
        break;
      case bienvenue:
      default:
        page = const BienvenueScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
