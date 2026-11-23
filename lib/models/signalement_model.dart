/// Un signalement : une annonce ou une personne jugée abusive.
/// Les signalements seront vérifiés par la communauté / l'équipe CampusLost.
class Signalement {
  final String cible;   // "annonce" ou "personne"
  final int cibleId;
  final String motif;   // ex. : "Tentative d'arnaque"
  final int auteurId;   // qui a signalé
  final DateTime date;

  Signalement({
    required this.cible,
    required this.cibleId,
    required this.motif,
    required this.auteurId,
    required this.date,
  });
}
