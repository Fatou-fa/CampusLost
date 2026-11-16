/// Une annonce d'objet perdu ou trouvé.
class Annonce {
  final int id;
  final String titre;
  final String description;
  final String type;       // "perdu" ou "trouve"
  final String statut;     // "active" ou "restitue"
  final String? photoUrl;  // null si pas de photo
  final String date;       // ex. : "2026-11-15"
  final String categorie;  // ex. : "Clés"
  final String lieu;       // ex. : "Resto U"
  final int auteurId;
  final String auteurNom;

  Annonce({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    required this.statut,
    this.photoUrl,
    required this.date,
    required this.categorie,
    required this.lieu,
    required this.auteurId,
    required this.auteurNom,
  });

  /// Vrai si l'objet a été perdu.
  bool get estPerdue => type == 'perdu';

  /// Vrai si l'objet a déjà été rendu à son propriétaire.
  bool get estRestituee => statut == 'restitue';
}
