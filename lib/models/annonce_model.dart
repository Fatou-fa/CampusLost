/// Une annonce d'objet perdu ou trouvé.
class Annonce {
  final int id;
  final String titre;
  final String description;
  final String type;       // "perdu" ou "trouve"
  final String statut;     // "active" ou "restitue"
  final String? photoUrl;  // image de l'app (assets/…) ou photo du téléphone
  final String date;       // ex. : "17/11/2026"
  final String categorie;  // ex. : "Clés"
  final String lieu;       // ex. : "Resto U"
  final int auteurId;
  final String auteurNom;
  final String auteurTelephone; // pour appeler ou envoyer un SMS

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
    this.auteurTelephone = '',
  });

  /// Vrai si l'objet a été perdu.
  bool get estPerdue => type == 'perdu';

  /// Vrai si l'objet a déjà été rendu à son propriétaire.
  bool get estRestituee => statut == 'restitue';

  /// Copie de l'annonce avec un autre statut (les champs sont « final » :
  /// on ne modifie pas l'objet, on en crée un nouveau).
  Annonce copieAvecStatut(String nouveauStatut) {
    return Annonce(
      id: id,
      titre: titre,
      description: description,
      type: type,
      statut: nouveauStatut,
      photoUrl: photoUrl,
      date: date,
      categorie: categorie,
      lieu: lieu,
      auteurId: auteurId,
      auteurNom: auteurNom,
      auteurTelephone: auteurTelephone,
    );
  }
}
