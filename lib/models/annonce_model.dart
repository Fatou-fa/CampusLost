/// Une annonce d'objet perdu ou trouvé (collection Firestore « annonces »).
class Annonce {
  final String id;         // id du document Firestore
  final String titre;
  final String description;
  final String type;       // "perdu" ou "trouve"
  final String statut;     // "active" ou "restitue"
  final String? photoUrl;  // image de l'app (assets/…), photo (data:image…) ou fichier local
  final String date;       // ex. : "17/11/2026"
  final String categorie;  // ex. : "Clés"
  final String lieu;       // ex. : "Resto U"
  final String auteurId;   // uid de la personne qui a publié
  final String auteurNom;
  final String auteurTelephone; // pour appeler ou envoyer un SMS
  final int creeLe;        // moment de publication (millisecondes), pour trier

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
    this.creeLe = 0,
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
      creeLe: creeLe,
    );
  }

  /// Copie de l'annonce avec une autre photo (utilisée avant l'envoi).
  Annonce copieAvecPhoto(String? nouvellePhoto) {
    return Annonce(
      id: id,
      titre: titre,
      description: description,
      type: type,
      statut: statut,
      photoUrl: nouvellePhoto,
      date: date,
      categorie: categorie,
      lieu: lieu,
      auteurId: auteurId,
      auteurNom: auteurNom,
      auteurTelephone: auteurTelephone,
      creeLe: creeLe,
    );
  }

  /// Lit une annonce depuis un document Firestore.
  factory Annonce.depuisMap(String id, Map<String, dynamic> data) {
    return Annonce(
      id: id,
      titre: data['titre'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: data['type'] as String? ?? 'trouve',
      statut: data['statut'] as String? ?? 'active',
      photoUrl: data['photoUrl'] as String?,
      date: data['date'] as String? ?? '',
      categorie: data['categorie'] as String? ?? '',
      lieu: data['lieu'] as String? ?? '',
      auteurId: data['auteurId'] as String? ?? '',
      auteurNom: data['auteurNom'] as String? ?? '',
      auteurTelephone: data['auteurTelephone'] as String? ?? '',
      creeLe: (data['creeLe'] as num?)?.toInt() ?? 0,
    );
  }

  /// Transforme l'annonce en données Firestore (l'id est le nom du document).
  Map<String, dynamic> versMap() => {
        'titre': titre,
        'description': description,
        'type': type,
        'statut': statut,
        'photoUrl': photoUrl,
        'date': date,
        'categorie': categorie,
        'lieu': lieu,
        'auteurId': auteurId,
        'auteurNom': auteurNom,
        'auteurTelephone': auteurTelephone,
        'creeLe': creeLe,
      };
}
