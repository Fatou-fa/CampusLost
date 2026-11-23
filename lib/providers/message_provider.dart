import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import '../models/signalement_model.dart';
import 'auth_provider.dart';

/// Toutes les conversations.
///
/// TEMPORAIRE : en mémoire, sur ce téléphone. Avec l'API PHP, chaque
/// message sera envoyé au serveur (table « message ») et l'application
/// récupérera les nouveaux messages régulièrement.
final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
        ConversationsNotifier.new);

class ConversationsNotifier extends Notifier<List<Conversation>> {
  /// Exemple : Awa écrit au compte de démonstration au sujet des écouteurs.
  @override
  List<Conversation> build() {
    final maintenant = DateTime.now();
    return [
      Conversation(
        id: 1,
        annonceId: 6,
        annonceTitre: 'Écouteurs sans fil',
        annoncePhoto: 'assets/images/objets/ecouteurs.png',
        proprietaireId: 99,
        proprietaireNom: 'Étudiant D.',
        proprietaireTelephone: '770000000',
        visiteurId: 201,
        visiteurNom: 'Awa N.',
        visiteurTelephone: '771234567',
        messages: [
          Message(
            id: 1,
            auteurId: 201,
            texte: 'Bonjour ! Je crois que ce sont mes écouteurs, '
                'je vous ai envoyé une demande.',
            heure: maintenant.subtract(const Duration(minutes: 25)),
          ),
          Message(
            id: 2,
            auteurId: 201,
            texte: 'Je suis à la bibliothèque cet après-midi si ça vous arrange.',
            heure: maintenant.subtract(const Duration(minutes: 20)),
          ),
        ],
      ),
    ];
  }

  /// Retourne l'id de la conversation sur cette annonce entre ces deux
  /// personnes ; la crée si elle n'existe pas encore.
  int ouvrir({
    required int annonceId,
    required String annonceTitre,
    String? annoncePhoto,
    required int proprietaireId,
    required String proprietaireNom,
    required String proprietaireTelephone,
    required int visiteurId,
    required String visiteurNom,
    required String visiteurTelephone,
  }) {
    for (final c in state) {
      if (c.annonceId == annonceId &&
          c.proprietaireId == proprietaireId &&
          c.visiteurId == visiteurId) {
        return c.id;
      }
    }
    var id = 1;
    for (final c in state) {
      if (c.id >= id) id = c.id + 1;
    }
    state = [
      ...state,
      Conversation(
        id: id,
        annonceId: annonceId,
        annonceTitre: annonceTitre,
        annoncePhoto: annoncePhoto,
        proprietaireId: proprietaireId,
        proprietaireNom: proprietaireNom,
        proprietaireTelephone: proprietaireTelephone,
        visiteurId: visiteurId,
        visiteurNom: visiteurNom,
        visiteurTelephone: visiteurTelephone,
      ),
    ];
    return id;
  }

  /// Ajoute un message à la fin de la conversation.
  void envoyer(int conversationId, int auteurId, String texte) {
    state = [
      for (final c in state)
        if (c.id == conversationId)
          c.copie(messages: [
            ...c.messages,
            Message(
              id: c.messages.length + 1,
              auteurId: auteurId,
              texte: texte,
              heure: DateTime.now(),
            ),
          ])
        else
          c
    ];
  }

  /// Marque comme lus les messages reçus par [moiId] dans la conversation.
  void marquerLus(int conversationId, int moiId) {
    // Rien à faire s'il n'y a aucun message non lu (évite de redessiner)
    final aLire = state.any((c) => c.id == conversationId && c.nonLus(moiId) > 0);
    if (!aLire) return;
    state = [
      for (final c in state)
        if (c.id == conversationId)
          c.copie(messages: [
            for (final m in c.messages) m.auteurId != moiId ? m.copieLue() : m
          ])
        else
          c
    ];
  }

  /// Bloque la conversation : plus personne ne peut y écrire.
  void bloquer(int conversationId, int moiId) => state = [
        for (final c in state)
          c.id == conversationId ? c.copie(bloqueePar: moiId) : c
      ];

  void debloquer(int conversationId) => state = [
        for (final c in state)
          c.id == conversationId ? c.copie(debloquer: true) : c
      ];
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
    Provider.family<Conversation?, int>((ref, id) {
  for (final c in ref.watch(conversationsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

// =====================================================================
//  Signalements
// =====================================================================

/// Signalements envoyés (TEMPORAIRE : en mémoire, en attendant l'API).
final signalementsProvider =
    NotifierProvider<SignalementsNotifier, List<Signalement>>(
        SignalementsNotifier.new);

class SignalementsNotifier extends Notifier<List<Signalement>> {
  @override
  List<Signalement> build() => [];

  void signaler({
    required String cible,
    required int cibleId,
    required String motif,
    required int auteurId,
  }) {
    state = [
      ...state,
      Signalement(
        cible: cible,
        cibleId: cibleId,
        motif: motif,
        auteurId: auteurId,
        date: DateTime.now(),
      ),
    ];
  }
}
