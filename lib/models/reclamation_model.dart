/// Une réclamation : une personne affirme qu'un objet trouvé lui appartient.
class Reclamation {
  final int id;
  final String message;       // message libre du demandeur
  final String detail;        // détail que seul le propriétaire peut connaître
  final String date;
  final String statut;        // "en_attente", "acceptee" ou "refusee"
  final int annonceId;
  final String annonceTitre;
  final int demandeurId;      // la personne qui réclame
  final String demandeurNom;
  final String demandeurTelephone;

  Reclamation({
    required this.id,
    required this.message,
    this.detail = '',
    required this.date,
    required this.statut,
    required this.annonceId,
    required this.annonceTitre,
    required this.demandeurId,
    required this.demandeurNom,
    this.demandeurTelephone = '',
  });

  /// Vrai si le trouveur n'a pas encore répondu.
  bool get estEnAttente => statut == 'en_attente';
  bool get estAcceptee => statut == 'acceptee';
  bool get estRefusee => statut == 'refusee';

  /// Copie de la réclamation avec un autre statut.
  Reclamation copieAvecStatut(String nouveauStatut) {
    return Reclamation(
      id: id,
      message: message,
      detail: detail,
      date: date,
      statut: nouveauStatut,
      annonceId: annonceId,
      annonceTitre: annonceTitre,
      demandeurId: demandeurId,
      demandeurNom: demandeurNom,
      demandeurTelephone: demandeurTelephone,
    );
  }
}
