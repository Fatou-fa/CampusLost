/// Un message écrit dans une conversation.
class Message {
  final String id;
  final String auteurId;
  final String texte;
  final DateTime heure;
  final bool lu; // vrai quand le destinataire a ouvert la conversation

  Message({
    required this.id,
    required this.auteurId,
    required this.texte,
    required this.heure,
    this.lu = false,
  });

  Message copieLue() =>
      Message(id: id, auteurId: auteurId, texte: texte, heure: heure, lu: true);

  factory Message.depuisMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as String? ?? '',
      auteurId: data['auteurId'] as String? ?? '',
      texte: data['texte'] as String? ?? '',
      heure: DateTime.fromMillisecondsSinceEpoch(
          (data['heure'] as num?)?.toInt() ?? 0),
      lu: data['lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> versMap() => {
        'id': id,
        'auteurId': auteurId,
        'texte': texte,
        'heure': heure.millisecondsSinceEpoch,
        'lu': lu,
      };
}

/// Une conversation entre deux étudiants, toujours au sujet d'une annonce.
/// Collection Firestore « conversations » ; les messages sont rangés dans
/// une liste à l'intérieur du document.
///
/// Le « propriétaire » est la personne qui a publié l'annonce, le
/// « visiteur » celle qui lui écrit. Les numéros de téléphone restent
/// cachés : on peut appeler depuis l'app sans voir le numéro.
class Conversation {
  final String id;
  final String annonceId;
  final String annonceTitre;
  final String? annoncePhoto;

  final String proprietaireId;
  final String proprietaireNom;
  final String proprietaireTelephone;

  final String visiteurId;
  final String visiteurNom;
  final String visiteurTelephone;

  final List<Message> messages; // du plus ancien au plus récent
  final String? bloqueePar;     // id de celui qui a bloqué, ou null

  Conversation({
    required this.id,
    required this.annonceId,
    required this.annonceTitre,
    this.annoncePhoto,
    required this.proprietaireId,
    required this.proprietaireNom,
    this.proprietaireTelephone = '',
    required this.visiteurId,
    required this.visiteurNom,
    this.visiteurTelephone = '',
    this.messages = const [],
    this.bloqueePar,
  });

  /// Vrai si cet utilisateur participe à la conversation.
  bool concerne(String utilisateurId) =>
      utilisateurId == proprietaireId || utilisateurId == visiteurId;

  // ---------- Vu par « moi » : l'autre personne ----------

  String autreNom(String moiId) =>
      moiId == proprietaireId ? visiteurNom : proprietaireNom;

  String autreTelephone(String moiId) =>
      moiId == proprietaireId ? visiteurTelephone : proprietaireTelephone;

  /// Nombre de messages de l'autre que je n'ai pas encore lus.
  int nonLus(String moiId) =>
      messages.where((m) => m.auteurId != moiId && !m.lu).length;

  bool get estBloquee => bloqueePar != null;

  Message? get dernier => messages.isEmpty ? null : messages.last;

  /// Copie avec d'autres messages ou un autre blocage.
  /// [debloquer] remet bloqueePar à null.
  Conversation copie({
    List<Message>? messages,
    String? bloqueePar,
    bool debloquer = false,
  }) {
    return Conversation(
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
      messages: messages ?? this.messages,
      bloqueePar: debloquer ? null : (bloqueePar ?? this.bloqueePar),
    );
  }

  factory Conversation.depuisMap(String id, Map<String, dynamic> data) {
    final bruts = (data['messages'] as List<dynamic>?) ?? const [];
    return Conversation(
      id: id,
      annonceId: data['annonceId'] as String? ?? '',
      annonceTitre: data['annonceTitre'] as String? ?? '',
      annoncePhoto: data['annoncePhoto'] as String?,
      proprietaireId: data['proprietaireId'] as String? ?? '',
      proprietaireNom: data['proprietaireNom'] as String? ?? '',
      proprietaireTelephone: data['proprietaireTelephone'] as String? ?? '',
      visiteurId: data['visiteurId'] as String? ?? '',
      visiteurNom: data['visiteurNom'] as String? ?? '',
      visiteurTelephone: data['visiteurTelephone'] as String? ?? '',
      messages: [
        for (final m in bruts) Message.depuisMap(Map<String, dynamic>.from(m as Map)),
      ],
      bloqueePar: data['bloqueePar'] as String?,
    );
  }

  /// En-tête de la conversation (sans les messages).
  /// « participants » sert à la requête « mes conversations » et aux
  /// règles de sécurité.
  Map<String, dynamic> enteteVersMap() => {
        'annonceId': annonceId,
        'annonceTitre': annonceTitre,
        'annoncePhoto': annoncePhoto,
        'proprietaireId': proprietaireId,
        'proprietaireNom': proprietaireNom,
        'proprietaireTelephone': proprietaireTelephone,
        'visiteurId': visiteurId,
        'visiteurNom': visiteurNom,
        'visiteurTelephone': visiteurTelephone,
        'participants': [proprietaireId, visiteurId],
      };
}
