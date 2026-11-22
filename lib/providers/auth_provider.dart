import 'package:flutter/foundation.dart';

import '../models/utilisateur_model.dart';
import '../services/auth_service.dart';

/// État de connexion partagé par toute l'application.
///
/// Les écrans le lisent avec `context.watch<AuthProvider>()` (pour se
/// redessiner quand il change) ou `context.read<AuthProvider>()` (pour
/// appeler une action, par exemple dans un bouton).
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  Utilisateur? _utilisateur;
  bool _enCours = false;
  String? _erreur;

  Utilisateur? get utilisateur => _utilisateur;
  bool get estConnecte => _utilisateur != null;
  bool get enCours => _enCours; // pour afficher un indicateur de chargement
  String? get erreur => _erreur;

  /// Au démarrage : récupère l'utilisateur mémorisé sur le téléphone.
  Future<void> chargerSession() async {
    _utilisateur = await _service.chargerSession();
    notifyListeners();
  }

  /// Retourne true si l'inscription a réussi.
  Future<bool> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
  }) {
    return _executer(() => _service.inscrire(
          nom: nom,
          prenom: prenom,
          email: email,
          telephone: telephone,
          motDePasse: motDePasse,
        ));
  }

  /// Retourne true si la connexion a réussi ; sinon [erreur] contient le message.
  Future<bool> connecter(String email, String motDePasse) {
    return _executer(() => _service.connecter(email, motDePasse));
  }

  Future<void> deconnecter() async {
    await _service.deconnecter();
    _utilisateur = null;
    notifyListeners();
  }

  /// Lance une action d'authentification en gérant le chargement et l'erreur.
  Future<bool> _executer(Future<Utilisateur> Function() action) async {
    _enCours = true;
    _erreur = null;
    notifyListeners();
    try {
      _utilisateur = await action();
      return true;
    } catch (e) {
      _erreur = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _enCours = false;
      notifyListeners();
    }
  }
}
