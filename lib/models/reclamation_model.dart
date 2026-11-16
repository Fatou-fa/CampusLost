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

  /// Vrai si le trouveur n'a pas encore répondu.
  bool get estEnAttente => statut == 'en_attente';
}
