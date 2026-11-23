import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import '../models/signalement_model.dart';
import '../repositories/message_repository.dart';
import 'auth_provider.dart';

/// Mes conversations, synchronisées avec Firestore en temps réel :
/// un message envoyé par l'autre personne apparaît tout seul.
final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
        ConversationsNotifier.new);

class ConversationsNotifier extends Notifier<List<Conversation>> {
  MessageRepository get _repo => ref.read(messageRepositoryProvider);

  @override
  List<Conversation> build() {
    final moi = ref.watch(authProvider);
    if (moi == null) return [];

    final abonnement = ref
        .watch(messageRepositoryProvider)
        .ecouter(moi.id)
        .listen((liste) => state = liste, onError: _journal);
    ref.onDispose(abonnement.cancel);
    return [];
  }

  /// Retourne l'id de la conversation sur cette annonce entre ces deux
  /// personnes ; la crée si elle n'existe pas encore.
  ///
  /// L'id est fabriqué à partir de l'annonce et du visiteur : deux appuis
  /// sur « Écrire » ouvrent donc toujours la même conversation.
  String ouvrir({
    required String annonceId,
    required String annonceTitre,
    String? annoncePhoto,
    required String proprietaireId,
    required String proprietaireNom,
    required String proprietaireTelephone,
    required String visiteurId,
    required String visiteurNom,
    required String visiteurTelephone,
  }) {
    final id = '${annonceId}_$visiteurId';
    for (final c in state) {
      if (c.id == id) return id;
    }

    final nouvelle = Conversation(
      id: id,
      annonceId: annonceId,
      annonceTitre: annonceTitre,
      // Une photo prise au téléphone est lourde : on ne la recopie pas ici
      annoncePhoto:
          (annoncePhoto ?? '').startsWith('assets/') ? annoncePhoto : null,
      proprietaireId: proprietaireId,
      proprietaireNom: proprietaireNom,
      proprietaireTelephone: proprietaireTelephone,
      visiteurId: visiteurId,
      visiteurNom: visiteurNom,
      visiteurTelephone: visiteurTelephone,
    );
    // Ajout immédiat dans l'état : l'écran s'ouvre sans attendre le réseau
    state = [...state, nouvelle];
    _repo.creer(nouvelle).catchError(_journal);
    return id;
  }

  /// Ajoute un message à la fin de la conversation.
  void envoyer(String conversationId, String auteurId, String texte) {
    final heure = DateTime.now();
    final message = Message(
      id: '${heure.millisecondsSinceEpoch}_$auteurId',
      auteurId: auteurId,
      texte: texte,
      heure: heure,
    );
    _repo.envoyer(conversationId, message).catchError(_journal);
  }

  /// Marque comme lus les messages reçus par [moiId] dans la conversation.
  void marquerLus(String conversationId, String moiId) {
    Conversation? conversation;
    for (final c in state) {
      if (c.id == conversationId) conversation = c;
    }
    // Rien à faire s'il n'y a aucun message non lu (évite une écriture)
    if (conversation == null || conversation.nonLus(moiId) == 0) return;

    final lus = [
      for (final m in conversation.messages)
        m.auteurId != moiId ? m.copieLue() : m
    ];
    _repo.remplacerMessages(conversationId, lus).catchError(_journal);
  }

  /// Bloque la conversation : plus personne ne peut y écrire.
  void bloquer(String conversationId, String moiId) =>
      _repo.changerBlocage(conversationId, moiId).catchError(_journal);

  void debloquer(String conversationId) =>
      _repo.changerBlocage(conversationId, null).catchError(_journal);

  static void _journal(Object e) => debugPrint('CampusLost / messages : $e');
}

/// Mes conversations, la plus récente en haut.
final mesConversationsProvider = Provider<List<Conversation>>((ref) {
  final moi = ref.watch(authProvider);
  if (moi == null) return [];
  final liste = ref
      .watch(conversationsProvider)
      // On n'affiche pas une conversation vide que l'autre a ouverte
      .where((c) => c.concerne(moi.id))
      .where((c) => c.messages.isNotEmpty || c.visiteurId == moi.id)
      .toList();
  liste.sort((a, b) {
    final ha = a.dernier?.heure ?? DateTime(2000);
    final hb = b.dernier?.heure ?? DateTime(2000);
    return hb.compareTo(ha);
  });
  return liste;
});

/// Nombre total de messages non lus (badge de l'icône Messages).
final nbMessagesNonLusProvider = Provider<int>((ref) {
  final moi = ref.watch(authProvider);
  if (moi == null) return 0;
  var total = 0;
  for (final c in ref.watch(mesConversationsProvider)) {
    total += c.nonLus(moi.id);
  }
  return total;
});

/// Une conversation à partir de son id.
final conversationParIdProvider =
    Provider.family<Conversation?, String>((ref, id) {
  for (final c in ref.watch(conversationsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

// =====================================================================
//  Signalements
// =====================================================================

/// Envoi des signalements vers Firestore (collection « signalements »).
/// L'état garde ceux envoyés depuis ce téléphone pendant la session.
final signalementsProvider =
    NotifierProvider<SignalementsNotifier, List<Signalement>>(
        SignalementsNotifier.new);

class SignalementsNotifier extends Notifier<List<Signalement>> {
  @override
  List<Signalement> build() => [];

  void signaler({
    required String cible,
    required String cibleId,
    required String motif,
    required String auteurId,
  }) {
    final signalement = Signalement(
      cible: cible,
      cibleId: cibleId,
      motif: motif,
      auteurId: auteurId,
      date: DateTime.now(),
    );
    state = [...state, signalement];
    ref
        .read(messageRepositoryProvider)
        .signaler(signalement)
        .catchError((Object e) => debugPrint('CampusLost / signalement : $e'));
  }
}
