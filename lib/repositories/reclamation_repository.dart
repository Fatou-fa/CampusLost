import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reclamation_model.dart';

/// Rôle : lire et écrire les réclamations (collection « reclamations »).
class ReclamationRepository {
  ReclamationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _reclamations =>
      _db.collection('reclamations');

  /// Les réclamations où j'interviens (envoyées ou reçues), en temps réel,
  /// de la plus ancienne à la plus récente.
  Stream<List<Reclamation>> ecouter(String moiId) {
    return _reclamations
        .where('participants', arrayContains: moiId)
        .snapshots()
        .map((resultat) {
      final liste = [
        for (final doc in resultat.docs) Reclamation.depuisMap(doc.id, doc.data())
      ];
      liste.sort((a, b) => a.creeLe.compareTo(b.creeLe));
      return liste;
    });
  }

  String nouvelId() => _reclamations.doc().id;

  Future<void> ajouter(Reclamation r) =>
      _reclamations.doc(r.id).set(r.versMap());

  /// Change le statut de plusieurs réclamations en une seule fois
  /// (exemple : une acceptée, les autres refusées).
  Future<void> changerStatuts(Map<String, String> statutParId) async {
    final lot = _db.batch();
    statutParId.forEach((id, statut) {
      lot.update(_reclamations.doc(id), {'statut': statut});
    });
    await lot.commit();
  }

  Future<void> supprimer(List<String> ids) async {
    final lot = _db.batch();
    for (final id in ids) {
      lot.delete(_reclamations.doc(id));
    }
    await lot.commit();
  }
}

final reclamationRepositoryProvider = Provider<ReclamationRepository>(
  (ref) => ReclamationRepository(FirebaseFirestore.instance),
);
