/// Une réclamation : une personne affirme qu'un objet trouvé lui appartient.
/// Collection Firestore « reclamations ».
class Reclamation {
  final String id;
  final String message;       // message libre du demandeur
  final String detail;        // détail que seul le propriétaire peut connaître
  final String date;
  final String statut;        // "en_attente", "acceptee" ou "refusee"
  final String annonceId;
  final String annonceTitre;
  final String proprietaireId; // auteur de l'annonce (celui qui répond)
  final String demandeurId;    // la personne qui réclame
  final String demandeurNom;
  final String demandeurTelephone;
  final int creeLe;            // millisecondes, pour trier

  Reclamation({
    required this.id,
    required this.message,
    this.detail = '',
    required this.date,
    required this.statut,
    required this.annonceId,
    required this.annonceTitre,
    this.proprietaireId = '',
    required this.demandeurId,
    required this.demandeurNom,
    this.demandeurTelephone = '',
    this.creeLe = 0,
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
      proprietaireId: proprietaireId,
      demandeurId: demandeurId,
      demandeurNom: demandeurNom,
      demandeurTelephone: demandeurTelephone,
      creeLe: creeLe,
    );
  }

  factory Reclamation.depuisMap(String id, Map<String, dynamic> data) {
    return Reclamation(
      id: id,
      message: data['message'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      date: data['date'] as String? ?? '',
      statut: data['statut'] as String? ?? 'en_attente',
      annonceId: data['annonceId'] as String? ?? '',
      annonceTitre: data['annonceTitre'] as String? ?? '',
      proprietaireId: data['proprietaireId'] as String? ?? '',
      demandeurId: data['demandeurId'] as String? ?? '',
      demandeurNom: data['demandeurNom'] as String? ?? '',
      demandeurTelephone: data['demandeurTelephone'] as String? ?? '',
      creeLe: (data['creeLe'] as num?)?.toInt() ?? 0,
    );
  }

  /// « participants » sert aux règles de sécurité : seuls le demandeur et
  /// le propriétaire de l'annonce peuvent lire la réclamation.
  Map<String, dynamic> versMap() => {
        'message': message,
        'detail': detail,
        'date': date,
        'statut': statut,
        'annonceId': annonceId,
        'annonceTitre': annonceTitre,
        'proprietaireId': proprietaireId,
        'demandeurId': demandeurId,
        'demandeurNom': demandeurNom,
        'demandeurTelephone': demandeurTelephone,
        'creeLe': creeLe,
        'participants': [demandeurId, proprietaireId],
      };
}
