import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reclamation_model.dart';
import '../repositories/reclamation_repository.dart';
import 'annonce_provider.dart';
import 'auth_provider.dart';

/// Réclamations : « cet objet trouvé est à moi ».
///
/// Le demandeur envoie une réclamation depuis le détail d'une annonce
/// « Trouvé ». La personne qui a publié l'annonce l'accepte ou la refuse
/// dans l'onglet Demandes. Synchronisé avec Firestore en temps réel.
final reclamationsProvider =
    NotifierProvider<ReclamationsNotifier, List<Reclamation>>(
        ReclamationsNotifier.new);

class ReclamationsNotifier extends Notifier<List<Reclamation>> {
  ReclamationRepository get _repo => ref.read(reclamationRepositoryProvider);

  @override
  List<Reclamation> build() {
    final moi = ref.watch(authProvider);
    if (moi == null) return [];

    final abonnement = ref
        .watch(reclamationRepositoryProvider)
        .ecouter(moi.id)
        .listen((liste) => state = liste, onError: _journal);
    ref.onDispose(abonnement.cancel);
    return [];
  }

  /// Envoie une réclamation.
  Future<String?> reclamer({
    required String annonceId,
    required String annonceTitre,
    required String proprietaireId,
    required String demandeurId,
    required String demandeurNom,
    required String demandeurTelephone,
    required String message,
    required String detail,
  }) {
    final maintenant = DateTime.now();
    String deux(int n) => n.toString().padLeft(2, '0');
    final reclamation = Reclamation(
      id: _repo.nouvelId(),
      message: message,
      detail: detail,
      date: 'Le ${deux(maintenant.day)}/${deux(maintenant.month)} '
          'à ${deux(maintenant.hour)} h ${deux(maintenant.minute)}',
      statut: 'en_attente',
      annonceId: annonceId,
      annonceTitre: annonceTitre,
      proprietaireId: proprietaireId,
      demandeurId: demandeurId,
      demandeurNom: demandeurNom,
      demandeurTelephone: demandeurTelephone,
      creeLe: maintenant.millisecondsSinceEpoch,
    );
    return _essayer(() => _repo.ajouter(reclamation));
  }

  /// Accepte une réclamation. Les autres réclamations en attente sur la
  /// même annonce sont refusées automatiquement (un seul propriétaire).
  Future<String?> accepter(String id) {
    final choisie = state.firstWhere((r) => r.id == id);
    final statuts = <String, String>{id: 'acceptee'};
    for (final r in state) {
      if (r.id != id && r.annonceId == choisie.annonceId && r.estEnAttente) {
        statuts[r.id] = 'refusee';
      }
    }
    return _essayer(() => _repo.changerStatuts(statuts));
  }

  Future<String?> refuser(String id) =>
      _essayer(() => _repo.changerStatuts({id: 'refusee'}));

  /// Supprime les réclamations d'une annonce supprimée.
  Future<String?> supprimerPourAnnonce(String annonceId) {
    final ids = [
      for (final r in state)
        if (r.annonceId == annonceId) r.id
    ];
    if (ids.isEmpty) return Future.value(null);
    return _essayer(() => _repo.supprimer(ids));
  }

  Future<String?> _essayer(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      _journal(e);
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  static void _journal(Object e) => debugPrint('CampusLost / réclamations : $e');
}

/// Réclamations reçues sur mes annonces, les plus récentes d'abord.
final reclamationsRecuesProvider = Provider<List<Reclamation>>((ref) {
  final mesIds = ref.watch(mesAnnoncesProvider).map((a) => a.id).toSet();
  return ref
      .watch(reclamationsProvider)
      .where((r) => mesIds.contains(r.annonceId))
      .toList()
      .reversed
      .toList();
});

/// Réclamations que j'ai envoyées, les plus récentes d'abord.
final reclamationsEnvoyeesProvider = Provider<List<Reclamation>>((ref) {
  final moi = ref.watch(authProvider);
  if (moi == null) return [];
  return ref
      .watch(reclamationsProvider)
      .where((r) => r.demandeurId == moi.id)
      .toList()
      .reversed
      .toList();
});

/// Nombre de réclamations reçues qui attendent ma réponse (badge du bas).
final nbATraiterProvider = Provider<int>((ref) =>
    ref.watch(reclamationsRecuesProvider).where((r) => r.estEnAttente).length);

/// Ma réclamation sur une annonce, s'il y en a une (pour le détail).
final maReclamationSurProvider =
    Provider.family<Reclamation?, String>((ref, annonceId) {
  final moi = ref.watch(authProvider);
  if (moi == null) return null;
  for (final r in ref.watch(reclamationsProvider)) {
    if (r.annonceId == annonceId && r.demandeurId == moi.id) return r;
  }
  return null;
});
