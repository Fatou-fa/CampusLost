import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reclamation_model.dart';
import 'annonce_provider.dart';
import 'auth_provider.dart';

/// Réclamations : « cet objet trouvé est à moi ».
///
/// Le demandeur envoie une réclamation depuis le détail d'une annonce
/// « Trouvé ». La personne qui a publié l'annonce l'accepte ou la refuse
/// dans l'onglet Réclamations.
///
/// TEMPORAIRE : en mémoire, en attendant l'API PHP.
final reclamationsProvider =
    NotifierProvider<ReclamationsNotifier, List<Reclamation>>(
        ReclamationsNotifier.new);

class ReclamationsNotifier extends Notifier<List<Reclamation>> {
  /// Exemple : Awa réclame les écouteurs trouvés par le compte de démonstration.
  @override
  List<Reclamation> build() {
    return [
      Reclamation(
        id: 1,
        message: 'Bonjour, je pense que ce sont mes écouteurs, '
            'je les ai perdus mardi en sortant du pavillon.',
        detail: 'Mes initiales « AN » sont gravées sur le boîtier',
        date: 'Il y a 20 min',
        statut: 'en_attente',
        annonceId: 6,
        annonceTitre: 'Écouteurs sans fil',
        demandeurId: 201,
        demandeurNom: 'Awa N.',
        demandeurTelephone: '771234567',
      ),
    ];
  }

  /// Envoie une réclamation.
  void reclamer({
    required int annonceId,
    required String annonceTitre,
    required int demandeurId,
    required String demandeurNom,
    required String demandeurTelephone,
    required String message,
    required String detail,
  }) {
    var prochainId = 1;
    for (final r in state) {
      if (r.id >= prochainId) prochainId = r.id + 1;
    }
    state = [
      ...state,
      Reclamation(
        id: prochainId,
        message: message,
        detail: detail,
        date: "À l'instant",
        statut: 'en_attente',
        annonceId: annonceId,
        annonceTitre: annonceTitre,
        demandeurId: demandeurId,
        demandeurNom: demandeurNom,
        demandeurTelephone: demandeurTelephone,
      ),
    ];
  }

  /// Accepte une réclamation. Les autres réclamations en attente sur la
  /// même annonce sont refusées automatiquement (un seul propriétaire).
  void accepter(int id) {
    final choisie = state.firstWhere((r) => r.id == id);
    state = [
      for (final r in state)
        if (r.id == id)
          r.copieAvecStatut('acceptee')
        else if (r.annonceId == choisie.annonceId && r.estEnAttente)
          r.copieAvecStatut('refusee')
        else
          r
    ];
  }

  void refuser(int id) => state = [
        for (final r in state) r.id == id ? r.copieAvecStatut('refusee') : r
      ];

  /// Supprime les réclamations d'une annonce supprimée.
  void supprimerPourAnnonce(int annonceId) =>
      state = state.where((r) => r.annonceId != annonceId).toList();
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
    Provider.family<Reclamation?, int>((ref, annonceId) {
  final moi = ref.watch(authProvider);
  if (moi == null) return null;
  for (final r in ref.watch(reclamationsProvider)) {
    if (r.annonceId == annonceId && r.demandeurId == moi.id) return r;
  }
  return null;
});
