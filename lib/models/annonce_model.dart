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

  /// Crée une annonce à partir du JSON renvoyé par l'API.
  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: int.parse(json['id'].toString()),
      titre: json['titre'],
      description: json['description'] ?? '',
      type: json['type'],
      statut: json['statut'],
      photoUrl: json['photo_url'],
      date: json['date_annonce'],
      categorie: json['categorie'],
      lieu: json['lieu'],
      auteurId: int.parse(json['auteur_id'].toString()),
      auteurNom: json['auteur_nom'],
    );
  }

  /// Transforme l'annonce en JSON pour l'envoyer à l'API.
  ///
  /// On n'envoie pas l'auteur : l'API le retrouve grâce au jeton de connexion.
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'type': type,
      'date_annonce': date,
      'categorie': categorie,
      'lieu': lieu,
    };
  }

  /// Vrai si l'objet a été perdu.
  bool get estPerdue => type == 'perdu';

  /// Vrai si l'objet a déjà été rendu à son propriétaire.
  bool get estRestituee => statut == 'restitue';
}
