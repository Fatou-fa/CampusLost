import 'package:shared_preferences/shared_preferences.dart';

import '../models/utilisateur_model.dart';

/// Gère le compte et la session de l'utilisateur.
///
/// Connexion unique : une fois inscrit ou connecté, l'utilisateur est
/// mémorisé sur le téléphone grâce à SharedPreferences. Aux lancements
/// suivants, l'application l'ouvre directement sur l'accueil.
///
/// TEMPORAIRE : en attendant l'API PHP, le compte est enregistré sur le
/// téléphone. Quand l'API sera prête, seules les méthodes de ce fichier
/// changeront (appels à ApiConfig) ; les écrans et les providers resteront
/// identiques.
class AuthService {
  // Clés utilisées dans SharedPreferences
  static const _connecte = 'session_connecte';
  static const _demo = 'session_demo'; // vrai si connecté au compte démo
  static const _id = 'utilisateur_id';
  static const _nom = 'utilisateur_nom';
  static const _prenom = 'utilisateur_prenom';
  static const _email = 'utilisateur_email';
  static const _telephone = 'utilisateur_telephone';
  static const _motDePasse = 'compte_mot_de_passe'; // simulation uniquement

  /// Compte de démonstration, utilisable sans inscription.
  static const emailDemo = 'demo@ugb.edu.sn';
  static const motDePasseDemo = 'campus123';

  /// Identifiant donné au compte créé sur ce téléphone.
  static const idCompteLocal = 100;

  /// Utilisateur du compte de démonstration.
  static final Utilisateur utilisateurDemo = Utilisateur(
    id: 99,
    nom: 'Démo',
    prenom: 'Étudiant',
    email: emailDemo,
    telephone: '770000000',
  );

  /// Retourne l'utilisateur mémorisé, ou null si personne n'est connecté.
  Future<Utilisateur?> chargerSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_connecte) ?? false)) return null;
    if (prefs.getBool(_demo) ?? false) return utilisateurDemo;
    return _lireUtilisateur(prefs);
  }

  /// Crée le compte, puis ouvre la session.
  Future<Utilisateur> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_id, idCompteLocal);
    await prefs.setString(_nom, nom);
    await prefs.setString(_prenom, prenom);
    await prefs.setString(_email, email.trim().toLowerCase());
    await prefs.setString(_telephone, telephone);
    await prefs.setString(_motDePasse, motDePasse);
    await prefs.setBool(_demo, false);
    await prefs.setBool(_connecte, true);
    return _lireUtilisateur(prefs);
  }

  /// Vérifie l'email et le mot de passe, puis ouvre la session.
  /// Lève une exception avec un message lisible en cas d'échec.
  Future<Utilisateur> connecter(String email, String motDePasse) async {
    final prefs = await SharedPreferences.getInstance();
    final emailSaisi = email.trim().toLowerCase();

    // Compte de démonstration : on ne touche pas au compte local
    if (emailSaisi == emailDemo && motDePasse == motDePasseDemo) {
      await prefs.setBool(_demo, true);
      await prefs.setBool(_connecte, true);
      return utilisateurDemo;
    }

    // Compte créé sur ce téléphone
    final emailEnregistre = prefs.getString(_email);
    final mdpEnregistre = prefs.getString(_motDePasse);
    if (emailEnregistre == null) {
      throw Exception("Aucun compte sur ce téléphone : créez d'abord un compte");
    }
    if (emailEnregistre == emailSaisi && mdpEnregistre == motDePasse) {
      await prefs.setBool(_demo, false);
      await prefs.setBool(_connecte, true);
      return _lireUtilisateur(prefs);
    }
    throw Exception('Email ou mot de passe incorrect');
  }

  /// Met à jour le prénom, le nom et le téléphone du compte local.
  Future<Utilisateur> modifierProfil({
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_demo) ?? false) {
      throw Exception('Le compte de démonstration ne peut pas être modifié');
    }
    await prefs.setString(_nom, nom);
    await prefs.setString(_prenom, prenom);
    await prefs.setString(_telephone, telephone);
    return _lireUtilisateur(prefs);
  }

  /// Ferme la session. Le compte reste enregistré pour une reconnexion.
  Future<void> deconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_connecte, false);
    await prefs.setBool(_demo, false);
  }

  Utilisateur _lireUtilisateur(SharedPreferences prefs) {
    return Utilisateur(
      id: prefs.getInt(_id) ?? idCompteLocal,
      nom: prefs.getString(_nom) ?? '',
      prenom: prefs.getString(_prenom) ?? '',
      email: prefs.getString(_email) ?? '',
      telephone: prefs.getString(_telephone) ?? '',
    );
  }
}
