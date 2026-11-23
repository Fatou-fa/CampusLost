import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/utilisateur_model.dart';
import '../repositories/auth_repository.dart';

/// Utilisateur trouvé au démarrage (dans main.dart, après Firebase.initializeApp).
/// Il est fourni à Riverpod avec `overrideWithValue` dans le ProviderScope.
final utilisateurInitialProvider = Provider<Utilisateur?>((ref) => null);

/// Utilisateur connecté (null = personne n'est connecté).
///
/// Lecture dans un écran :      ref.watch(authProvider)
/// Appel d'une action :         ref.read(authProvider.notifier).connecter(...)
final authProvider =
    NotifierProvider<AuthNotifier, Utilisateur?>(AuthNotifier.new);

/// Les actions sur la session. Chaque action retourne null si tout s'est
/// bien passé, sinon le message d'erreur à afficher.
class AuthNotifier extends Notifier<Utilisateur?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Valeur de départ : la session trouvée au lancement de l'application.
  @override
  Utilisateur? build() => ref.read(utilisateurInitialProvider);

  Future<String?> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
  }) {
    return _executer(() => _repo.inscrire(
          nom: nom,
          prenom: prenom,
          email: email,
          telephone: telephone,
          motDePasse: motDePasse,
        ));
  }

  Future<String?> connecter(String email, String motDePasse) {
    return _executer(() => _repo.connecter(email, motDePasse));
  }

  Future<String?> modifierProfil({
    required String nom,
    required String prenom,
    required String telephone,
  }) {
    return _executer(() => _repo.modifierProfil(
          nom: nom,
          prenom: prenom,
          telephone: telephone,
        ));
  }

  Future<void> deconnecter() async {
    await _repo.deconnecter();
    state = null; // tous les écrans qui « watch » authProvider se redessinent
  }

  /// Lance une action ; en cas de succès, le nouvel utilisateur devient l'état.
  Future<String?> _executer(Future<Utilisateur> Function() action) async {
    try {
      state = await action();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
