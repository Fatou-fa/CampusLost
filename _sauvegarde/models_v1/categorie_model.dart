/// Catégorie d'objet (Papiers d'identité, Électronique, Clés…).
/// Liste fixe, insérée une seule fois dans la base.
///
/// JSON attendu : { "id": 2, "libelle": "Électronique" }
class Categorie {
  final int idCategorie;
  final String libelle;

  const Categorie({required this.idCategorie, required this.libelle});

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      idCategorie: int.parse(json['id'].toString()),
      libelle: json['libelle'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': idCategorie, 'libelle': libelle};

  // Deux catégories sont égales si elles ont le même id.
  // Indispensable pour les DropdownButton (sélection d'une valeur).
  @override
  bool operator ==(Object other) => other is Categorie && other.idCategorie == idCategorie;

  @override
  int get hashCode => idCategorie.hashCode;

  @override
  String toString() => libelle;
}
