import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/utilisateur_model.dart';

/// Rôle : encapsuler Firebase Auth et le profil Firestore.
/// Les écrans et les providers ne manipulent jamais le SDK Firebase.
///
///  - Firebase Auth garde l'e-mail et le mot de passe ;
///  - Firestore garde le profil (collection « utilisateurs », document = uid).
///
/// Connexion unique : Firebase Auth mémorise la session sur le téléphone.
/// Au lancement suivant, [chargerSession] retrouve l'utilisateur.
class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Compte de démonstration : créé automatiquement à la première connexion.
  static const emailDemo = 'demo@ugb.edu.sn';
  static const motDePasseDemo = 'campus123';

  CollectionReference<Map<String, dynamic>> get _profils =>
      _db.collection('utilisateurs');

  /// Retourne l'utilisateur déjà connecté, ou null.
  Future<Utilisateur?> chargerSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _lireProfil(user);
  }

  /// Crée le compte Firebase, puis enregistre le profil dans Firestore.
  Future<Utilisateur> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
  }) async {
    try {
      final resultat = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: motDePasse,
      );
      final user = resultat.user;
      if (user == null) throw Exception("L'inscription n'a pas abouti");
      await user.updateDisplayName('$prenom $nom'.trim());

      final utilisateur = Utilisateur(
        id: user.uid,
        nom: nom.trim(),
        prenom: prenom.trim(),
        email: email.trim().toLowerCase(),
        telephone: telephone.trim(),
      );
      await _profils.doc(user.uid).set(utilisateur.versMap());
      return utilisateur;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageLisible(e));
    }
  }

  /// Vérifie l'e-mail et le mot de passe auprès de Firebase.
  /// Lève une exception avec un message en français en cas d'échec.
  Future<Utilisateur> connecter(String email, String motDePasse) async {
    final emailSaisi = email.trim().toLowerCase();
    try {
      final resultat = await _auth.signInWithEmailAndPassword(
        email: emailSaisi,
        password: motDePasse,
      );
      return _lireProfil(resultat.user!);
    } on FirebaseAuthException catch (e) {
      // Première utilisation du compte de démonstration : on le crée
      if (emailSaisi == emailDemo && motDePasse == motDePasseDemo) {
        return inscrire(
          nom: 'Démo',
          prenom: 'Étudiant',
          email: emailDemo,
          telephone: '770000000',
          motDePasse: motDePasseDemo,
        );
      }
      throw Exception(_messageLisible(e));
    }
  }

  /// Met à jour le prénom, le nom et le téléphone de l'utilisateur connecté.
  Future<Utilisateur> modifierProfil({
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Session expirée : reconnectez-vous');

    final utilisateur = Utilisateur(
      id: user.uid,
      nom: nom.trim(),
      prenom: prenom.trim(),
      email: user.email ?? '',
      telephone: telephone.trim(),
    );
    // merge : on garde les autres champs éventuels du document
    await _profils.doc(user.uid).set(utilisateur.versMap(), SetOptions(merge: true));
    await user.updateDisplayName('$prenom $nom'.trim());
    return utilisateur;
  }

  /// Ferme la session Firebase.
  Future<void> deconnecter() => _auth.signOut();

  /// Lit le profil Firestore de [user]. S'il n'existe pas (ancien compte)
  /// ou si le téléphone est hors ligne, on construit un profil minimal.
  Future<Utilisateur> _lireProfil(User user) async {
    try {
      final doc = await _profils.doc(user.uid).get();
      final data = doc.data();
      if (data != null) return Utilisateur.depuisMap(user.uid, data);
    } on FirebaseException {
      // Hors ligne : on continue avec les informations de Firebase Auth
    }
    final morceaux = (user.displayName ?? '').split(' ');
    return Utilisateur(
      id: user.uid,
      prenom: morceaux.first,
      nom: morceaux.length > 1 ? morceaux.sublist(1).join(' ') : '',
      email: user.email ?? '',
      telephone: '',
    );
  }

  /// Traduit les codes d'erreur de Firebase Auth en phrases simples.
  String _messageLisible(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet e-mail';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum)';
      case 'network-request-failed':
        return 'Pas de connexion Internet';
      case 'too-many-requests':
        return 'Trop de tentatives : réessayez dans quelques minutes';
      default:
        return 'Erreur : ${e.message ?? e.code}';
    }
  }
}

/// Le repository, partagé par toute l'application.
/// Dans les tests, on le remplace par un faux avec overrideWithValue.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance),
);
