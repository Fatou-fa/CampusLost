import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import '../models/signalement_model.dart';

/// Rôle : lire et écrire les conversations (collection « conversations »)
/// et les signalements (collection « signalements »).
class MessageRepository {
  MessageRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  /// Mes conversations, en temps réel : un nouveau message de l'autre
  /// personne apparaît tout seul, sans recharger.
  Stream<List<Conversation>> ecouter(String moiId) {
    return _conversations
        .where('participants', arrayContains: moiId)
        .snapshots()
        .map((resultat) => [
              for (final doc in resultat.docs)
                Conversation.depuisMap(doc.id, doc.data())
            ]);
  }

  /// Crée l'en-tête de la conversation s'il n'existe pas.
  /// merge : si elle existe déjà, ses messages sont conservés.
  Future<void> creer(Conversation c) =>
      _conversations.doc(c.id).set(c.enteteVersMap(), SetOptions(merge: true));

  /// Ajoute un message à la fin de la liste (arrayUnion : sans relire
  /// la conversation, donc sans écraser un message arrivé entre-temps).
  Future<void> envoyer(String conversationId, Message message) {
    return _conversations.doc(conversationId).update({
      'messages': FieldValue.arrayUnion([message.versMap()]),
    });
  }

  /// Remplace toute la liste des messages (pour les marquer comme lus).
  Future<void> remplacerMessages(String conversationId, List<Message> messages) {
    return _conversations.doc(conversationId).update({
      'messages': [for (final m in messages) m.versMap()],
    });
  }

  /// [moiId] = null pour débloquer.
  Future<void> changerBlocage(String conversationId, String? moiId) =>
      _conversations.doc(conversationId).update({'bloqueePar': moiId});

  Future<void> signaler(Signalement s) async {
    await _db.collection('signalements').add(s.versMap());
  }
}

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(FirebaseFirestore.instance),
);
