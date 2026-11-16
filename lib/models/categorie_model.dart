/// Une catégorie d'objet (Clés, Électronique, Papiers d'identité…).
class Categorie {
  final int id;
  final String libelle;

  Categorie({required this.id, required this.libelle});

  /// Crée une catégorie à partir du JSON renvoyé par l'API.
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: int.parse(json['id'].toString()),
      libelle: json['libelle'],
    );
  }
}
