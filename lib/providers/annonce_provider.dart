import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annonce_model.dart';
import '../repositories/annonce_repository.dart';
import 'auth_provider.dart';

/// Toutes les annonces, synchronisées avec Firestore en temps réel.
///
/// Lecture :  ref.watch(annoncesProvider)   → la liste des annonces
/// Action :   ref.read(annoncesProvider.notifier).ajouter(annonce)
///
/// Les actions écrivent dans Firestore ; Firestore renvoie alors la
/// nouvelle liste par le flux, et les écrans se redessinent. Grâce au
/// cache de Firestore, le changement apparaît tout de suite, même hors ligne.
final annoncesProvider =
    NotifierProvider<AnnoncesNotifier, List<Annonce>>(AnnoncesNotifier.new);

class AnnoncesNotifier extends Notifier<List<Annonce>> {
  AnnonceRepository get _repo => ref.read(annonceRepositoryProvider);

  @override
  List<Annonce> build() {
    // Les règles Firestore demandent d'être connecté pour lire les annonces.
    // ref.watch : à la connexion / déconnexion, build() est relancé.
    final moi = ref.watch(authProvider);
    if (moi == null) return [];

    final repo = ref.watch(annonceRepositoryProvider);
    repo.ajouterExemplesSiVide().catchError(_journal);

    // Écoute du flux Firestore : chaque nouvelle liste remplace l'état
    final abonnement = repo.ecouter().listen(
          (liste) => state = liste,
          onError: _journal,
        );
    ref.onDispose(abonnement.cancel); // on arrête d'écouter quand c'est fini
    return [];
  }

  /// Nouvel id pour une annonce, avant de l'envoyer.
  String nouvelId() => _repo.nouvelId();

  // Chaque action retourne null si tout va bien, sinon un message d'erreur.

  /// Publie une annonce.
  Future<String?> ajouter(Annonce annonce) => _essayer(() => _repo.ajouter(annonce));

  /// Enregistre une annonce modifiée (même id).
  Future<String?> modifier(Annonce annonce) => _essayer(() => _repo.modifier(annonce));

  /// L'objet a été rendu : l'annonce passe dans « Restituées ».
  Future<String?> marquerRestituee(String id) =>
      _essayer(() => _repo.changerStatut(id, 'restitue'));

  Future<String?> supprimer(String id) => _essayer(() => _repo.supprimer(id));

  Future<String?> _essayer(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      _journal(e);
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Affiche l'erreur dans la console de débogage.
  static void _journal(Object e) => debugPrint('CampusLost / annonces : $e');
}

/// Texte tapé dans la barre de recherche de l'accueil.
final rechercheProvider = StateProvider<String>((ref) => '');

/// Catégorie choisie sur l'accueil (null = toutes les catégories).
final categorieProvider = StateProvider<String?>((ref) => null);

/// Annonces de l'accueil : calculées à partir des trois providers ci-dessus.
/// Actives (pas restituées), qui correspondent à la recherche (titre, lieu ou
/// catégorie) et à la catégorie choisie. Recalculées automatiquement dès
/// que l'un des trois change.
final resultatsProvider = Provider<List<Annonce>>((ref) {
  final annonces = ref.watch(annoncesProvider);
  final texte = ref.watch(rechercheProvider).toLowerCase();
  final categorie = ref.watch(categorieProvider);

  return annonces
      .where((a) => !a.estRestituee)
      .where((a) =>
          a.titre.toLowerCase().contains(texte) ||
          a.lieu.toLowerCase().contains(texte) ||
          a.categorie.toLowerCase().contains(texte))
      .where((a) => categorie == null || a.categorie == categorie)
      .toList();
});

/// Annonces publiées par l'utilisateur connecté (onglet « Mes annonces »).
final mesAnnoncesProvider = Provider<List<Annonce>>((ref) {
  final moi = ref.watch(authProvider);
  if (moi == null) return [];
  return ref.watch(annoncesProvider).where((a) => a.auteurId == moi.id).toList();
});

/// Une annonce à partir de son id (null si elle a été supprimée).
/// « family » : un provider qui prend un paramètre → annonceParIdProvider(id).
final annonceParIdProvider = Provider.family<Annonce?, String>((ref, id) {
  for (final a in ref.watch(annoncesProvider)) {
    if (a.id == id) return a;
  }
  return null;
});
