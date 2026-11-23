/// Un message écrit dans une conversation.
class Message {
  final int id;
  final int auteurId;
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
}

/// Une conversation entre deux étudiants, toujours au sujet d'une annonce.
///
/// Le « propriétaire » est la personne qui a publié l'annonce, le
/// « visiteur » celle qui lui écrit. Les numéros de téléphone restent
/// cachés : on peut appeler depuis l'app sans voir le numéro.
class Conversation {
  final int id;
  final int annonceId;
  final String annonceTitre;
  final String? annoncePhoto;

  final int proprietaireId;
  final String proprietaireNom;
  final String proprietaireTelephone;

  final int visiteurId;
  final String visiteurNom;
  final String visiteurTelephone;

  final List<Message> messages; // du plus ancien au plus récent
  final int? bloqueePar;        // id de celui qui a bloqué, ou null

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
  bool concerne(int utilisateurId) =>
      utilisateurId == proprietaireId || utilisateurId == visiteurId;

  // ---------- Vu par « moi » : l'autre personne ----------

  String autreNom(int moiId) =>
      moiId == proprietaireId ? visiteurNom : proprietaireNom;

  String autreTelephone(int moiId) =>
      moiId == proprietaireId ? visiteurTelephone : proprietaireTelephone;

  /// Nombre de messages de l'autre que je n'ai pas encore lus.
  int nonLus(int moiId) =>
      messages.where((m) => m.auteurId != moiId && !m.lu).length;

  bool get estBloquee => bloqueePar != null;

  Message? get dernier => messages.isEmpty ? null : messages.last;

  /// Copie avec d'autres messages ou un autre blocage.
  /// [debloquer] remet bloqueePar à null.
  Conversation copie({
    List<Message>? messages,
    int? bloqueePar,
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
}
