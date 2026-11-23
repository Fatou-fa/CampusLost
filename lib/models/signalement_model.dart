/// Un signalement : une annonce ou une personne jugée abusive.
/// Collection Firestore « signalements », lue par l'équipe CampusLost
/// depuis la console Firebase.
class Signalement {
  final String cible;   // "annonce" ou "personne"
  final String cibleId;
  final String motif;   // ex. : "Tentative d'arnaque"
  final String auteurId; // qui a signalé
  final DateTime date;

  Signalement({
    required this.cible,
    required this.cibleId,
    required this.motif,
    required this.auteurId,
    required this.date,
  });

  Map<String, dynamic> versMap() => {
        'cible': cible,
        'cibleId': cibleId,
        'motif': motif,
        'auteurId': auteurId,
        'date': date.millisecondsSinceEpoch,
      };
}
