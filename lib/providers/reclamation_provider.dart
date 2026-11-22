import 'package:flutter/foundation.dart';

import '../models/reclamation_model.dart';

/// Réclamations : « cet objet trouvé est à moi ».
///
/// Le demandeur envoie une réclamation depuis le détail d'une annonce
/// « Trouvé ». La personne qui a publié l'annonce l'accepte ou la refuse
/// dans l'onglet Réclamations.
///
/// TEMPORAIRE : en mémoire, en attendant l'API PHP.
class ReclamationProvider extends ChangeNotifier {
  // Exemple : Awa réclame les écouteurs trouvés par le compte de démonstration
  final List<Reclamation> _reclamations = [
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

  /// Réclamations reçues sur les annonces dont les ids sont donnés
  /// (= les annonces de l'utilisateur connecté). Les plus récentes d'abord.
  List<Reclamation> recues(List<int> idsMesAnnonces) => _reclamations
      .where((r) => idsMesAnnonces.contains(r.annonceId))
      .toList()
      .reversed
      .toList();

  /// Réclamations envoyées par un utilisateur.
  List<Reclamation> envoyees(int demandeurId) => _reclamations
      .where((r) => r.demandeurId == demandeurId)
      .toList()
      .reversed
      .toList();

  /// Nombre de réclamations reçues qui attendent une réponse (badge).
  int enAttente(List<int> idsMesAnnonces) =>
      recues(idsMesAnnonces).where((r) => r.estEnAttente).length;

  /// La réclamation de cet utilisateur sur cette annonce, s'il y en a une.
  Reclamation? deUtilisateurSur(int annonceId, int demandeurId) {
    for (final r in _reclamations) {
      if (r.annonceId == annonceId && r.demandeurId == demandeurId) return r;
    }
    return null;
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
    for (final r in _reclamations) {
      if (r.id >= prochainId) prochainId = r.id + 1;
    }
    _reclamations.add(Reclamation(
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
    ));
    notifyListeners();
  }

  /// Accepte une réclamation. Les autres réclamations en attente sur la
  /// même annonce sont refusées automatiquement (l'objet n'a qu'un propriétaire).
  void accepter(int id) {
    final choisie = _reclamations.firstWhere((r) => r.id == id);
    for (var i = 0; i < _reclamations.length; i++) {
      final r = _reclamations[i];
      if (r.id == id) {
        _reclamations[i] = r.copieAvecStatut('acceptee');
      } else if (r.annonceId == choisie.annonceId && r.estEnAttente) {
        _reclamations[i] = r.copieAvecStatut('refusee');
      }
    }
    notifyListeners();
  }

  void refuser(int id) {
    final index = _reclamations.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _reclamations[index] = _reclamations[index].copieAvecStatut('refusee');
    notifyListeners();
  }

  /// Supprime les réclamations d'une annonce supprimée.
  void supprimerPourAnnonce(int annonceId) {
    _reclamations.removeWhere((r) => r.annonceId == annonceId);
    notifyListeners();
  }
}
