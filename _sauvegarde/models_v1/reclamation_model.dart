/// Statut d'une réclamation.
enum StatutReclamation {
  enAttente('en_attente', 'En attente'),
  acceptee('acceptee', 'Acceptée'),
  refusee('refusee', 'Refusée');

  final String valeurApi; // valeur en base
  final String libelle;   // texte affiché
  const StatutReclamation(this.valeurApi, this.libelle);

  static StatutReclamation fromApi(String valeur) =>
      StatutReclamation.values.firstWhere((s) => s.valeurApi == valeur,
          orElse: () => throw FormatException('Statut inconnu : $valeur'));
}

/// Une réclamation : un propriétaire affirme qu'un objet trouvé lui appartient.
/// - le PROPRIÉTAIRE la soumet (demandeur)
/// - le TROUVEUR (auteur de l'annonce) l'accepte ou la refuse
///
/// JSON attendu (renvoyé par reclamations/recues.php) :
/// {
///   "id": 5, "message": "Bonjour, je pense que c'est ma clé USB…",
///   "detail_verification": "une étiquette « AN » au dos",   // ou null
///   "date_reclamation": "2026-11-16T10:05:00", "statut": "en_attente",
///   "annonce_id": 12, "annonce_titre": "Clé USB",
///   "demandeur_id": 3, "demandeur_nom": "Awa N.", "demandeur_telephone": "770000000"
/// }
class Reclamation {
  final int idReclamation;
  final String message;
  final String? detailVerification; // détail que seul le propriétaire connaît
  final DateTime dateReclamation;
  final StatutReclamation statut;

  // Annonce concernée (« concerne » dans le diagramme)
  final int annonceId;
  final String annonceTitre;

  // Propriétaire qui réclame (« soumet » dans le diagramme)
  final int demandeurId;
  final String demandeurNom;
  final String? demandeurTelephone;

  const Reclamation({
    required this.idReclamation,
    required this.message,
    this.detailVerification,
    required this.dateReclamation,
    required this.statut,
    required this.annonceId,
    required this.annonceTitre,
    required this.demandeurId,
    required this.demandeurNom,
    this.demandeurTelephone,
  });

  bool get estEnAttente => statut == StatutReclamation.enAttente;
  bool get estAcceptee => statut == StatutReclamation.acceptee;

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      idReclamation: int.parse(json['id'].toString()),
      message: json['message'] as String,
      detailVerification: json['detail_verification'] as String?,
      dateReclamation: DateTime.parse(json['date_reclamation'] as String),
      statut: StatutReclamation.fromApi(json['statut'] as String),
      annonceId: int.parse(json['annonce_id'].toString()),
      annonceTitre: json['annonce_titre'] as String,
      demandeurId: int.parse(json['demandeur_id'].toString()),
      demandeurNom: json['demandeur_nom'] as String,
      demandeurTelephone: json['demandeur_telephone']?.toString(),
    );
  }

  /// Données envoyées à reclamations/soumettre.php.
  /// Le demandeur n'est pas envoyé : l'API le déduit du jeton.
  Map<String, dynamic> toJsonSoumission() => {
        'annonce_id': annonceId,
        'message': message,
        'detail_verification': detailVerification,
      };

  Reclamation copyWith({StatutReclamation? statut}) {
    return Reclamation(
      idReclamation: idReclamation,
      message: message,
      detailVerification: detailVerification,
      dateReclamation: dateReclamation,
      statut: statut ?? this.statut,
      annonceId: annonceId,
      annonceTitre: annonceTitre,
      demandeurId: demandeurId,
      demandeurNom: demandeurNom,
      demandeurTelephone: demandeurTelephone,
    );
  }
}
