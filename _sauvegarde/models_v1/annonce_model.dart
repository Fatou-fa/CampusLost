import 'categorie_model.dart';
import 'lieu_model.dart';

/// Type d'une annonce : objet perdu ou objet trouvé.
/// La valeur entre parenthèses est celle stockée en base et échangée avec l'API.
enum TypeAnnonce {
  perdu('perdu', 'Perdu'),
  trouve('trouve', 'Trouvé');

  final String valeurApi; // valeur en base : 'perdu' / 'trouve'
  final String libelle;   // texte affiché dans l'app
  const TypeAnnonce(this.valeurApi, this.libelle);

  /// 'trouve' → TypeAnnonce.trouve
  static TypeAnnonce fromApi(String valeur) =>
      TypeAnnonce.values.firstWhere((t) => t.valeurApi == valeur,
          orElse: () => throw FormatException('Type inconnu : $valeur'));
}

/// Statut d'une annonce.
enum StatutAnnonce {
  active('active', 'En cours'),
  restitue('restitue', 'Restituée');

  final String valeurApi;
  final String libelle;
  const StatutAnnonce(this.valeurApi, this.libelle);

  static StatutAnnonce fromApi(String valeur) =>
      StatutAnnonce.values.firstWhere((s) => s.valeurApi == valeur,
          orElse: () => throw FormatException('Statut inconnu : $valeur'));
}

/// Une annonce d'objet perdu ou trouvé.
///
/// JSON attendu (renvoyé par annonces/liste.php et annonces/detail.php) :
/// {
///   "id": 12, "titre": "Trousseau de clés", "description": "Trois clés…",
///   "type": "trouve", "statut": "active",
///   "photo_url": "uploads/abc123.jpg",          // ou null
///   "date_annonce": "2026-11-15T12:30:00",
///   "lieu_depot": "Scolarité",                   // ou null (objets trouvés seulement)
///   "categorie": { "id": 3, "libelle": "Clés" },
///   "lieu": { "id": 2, "nom": "Resto U" },
///   "auteur_id": 7, "auteur_nom": "Moussa D.", "auteur_telephone": "770000000"
/// }
class Annonce {
  final int idAnnonce;
  final String titre;
  final String description;
  final TypeAnnonce type;
  final StatutAnnonce statut;
  final String? photoUrl;      // facultative
  final DateTime dateAnnonce;
  final String? lieuDepot;     // où l'objet trouvé est déposé (null si perdu)
  final Categorie categorie;
  final Lieu lieu;

  // Infos sur l'auteur, utiles pour « Contacter » sans recharger tout l'utilisateur
  final int auteurId;
  final String auteurNom;
  final String? auteurTelephone; // visible seulement par les utilisateurs connectés

  const Annonce({
    required this.idAnnonce,
    required this.titre,
    required this.description,
    required this.type,
    required this.statut,
    this.photoUrl,
    required this.dateAnnonce,
    this.lieuDepot,
    required this.categorie,
    required this.lieu,
    required this.auteurId,
    required this.auteurNom,
    this.auteurTelephone,
  });

  // ---------- Raccourcis utiles dans les écrans ----------
  bool get estPerdue => type == TypeAnnonce.perdu;
  bool get estTrouvee => type == TypeAnnonce.trouve;
  bool get estRestituee => statut == StatutAnnonce.restitue;
  bool get aUnePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Seul l'auteur peut modifier, supprimer ou restituer (RG5)
  bool estDe(int idUtilisateur) => auteurId == idUtilisateur;

  /// On ne peut réclamer qu'un objet TROUVÉ, encore actif, et pas sa propre annonce
  bool peutEtreReclameePar(int idUtilisateur) =>
      estTrouvee && !estRestituee && !estDe(idUtilisateur);

  // ---------- Conversion JSON ----------
  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      idAnnonce: int.parse(json['id'].toString()),
      titre: json['titre'] as String,
      description: (json['description'] ?? '') as String,
      type: TypeAnnonce.fromApi(json['type'] as String),
      statut: StatutAnnonce.fromApi(json['statut'] as String),
      photoUrl: json['photo_url'] as String?,
      dateAnnonce: DateTime.parse(json['date_annonce'] as String),
      lieuDepot: json['lieu_depot'] as String?,
      categorie: Categorie.fromJson(json['categorie'] as Map<String, dynamic>),
      lieu: Lieu.fromJson(json['lieu'] as Map<String, dynamic>),
      auteurId: int.parse(json['auteur_id'].toString()),
      auteurNom: json['auteur_nom'] as String,
      auteurTelephone: json['auteur_telephone']?.toString(),
    );
  }

  /// Données envoyées à annonces/creer.php ou modifier.php.
  /// On n'envoie que des id pour la catégorie et le lieu,
  /// et pas l'auteur : l'API le déduit du jeton (sécurité).
  Map<String, dynamic> toJson() => {
        'id': idAnnonce,
        'titre': titre,
        'description': description,
        'type': type.valeurApi,
        'date_annonce': dateAnnonce.toIso8601String(),
        'lieu_depot': lieuDepot,
        'categorie_id': categorie.idCategorie,
        'lieu_id': lieu.idLieu,
      };

  /// Copie avec quelques champs modifiés (ex. : après « Marquer restituée »)
  Annonce copyWith({
    String? titre,
    String? description,
    StatutAnnonce? statut,
    String? photoUrl,
    String? lieuDepot,
    Categorie? categorie,
    Lieu? lieu,
  }) {
    return Annonce(
      idAnnonce: idAnnonce,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      type: type,
      statut: statut ?? this.statut,
      photoUrl: photoUrl ?? this.photoUrl,
      dateAnnonce: dateAnnonce,
      lieuDepot: lieuDepot ?? this.lieuDepot,
      categorie: categorie ?? this.categorie,
      lieu: lieu ?? this.lieu,
      auteurId: auteurId,
      auteurNom: auteurNom,
      auteurTelephone: auteurTelephone,
    );
  }
}
