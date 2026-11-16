/// Une réclamation : un propriétaire dit qu'un objet trouvé lui appartient.
class Reclamation {
  final int id;
  final String message;
  final String date;
  final String statut;        // "en_attente", "acceptee" ou "refusee"
  final int annonceId;
  final String annonceTitre;
  final int demandeurId;      // le propriétaire qui réclame
  final String demandeurNom;

  Reclamation({
    required this.id,
    required this.message,
    required this.date,
    required this.statut,
    required this.annonceId,
    required this.annonceTitre,
    required this.demandeurId,
    required this.demandeurNom,
  });

  /// Crée une réclamation à partir du JSON renvoyé par l'API.
  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: int.parse(json['id'].toString()),
      message: json['message'],
      date: json['date_reclamation'],
      statut: json['statut'],
      annonceId: int.parse(json['annonce_id'].toString()),
      annonceTitre: json['annonce_titre'],
      demandeurId: int.parse(json['demandeur_id'].toString()),
      demandeurNom: json['demandeur_nom'],
    );
  }

  /// Vrai si le trouveur n'a pas encore répondu.
  bool get estEnAttente => statut == 'en_attente';
}
