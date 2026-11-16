/// Lieu du campus (Bibliothèque, Resto U, Amphithéâtres…).
/// Liste fixe, insérée une seule fois dans la base.
///
/// JSON attendu : { "id": 1, "nom": "Bibliothèque" }
class Lieu {
  final int idLieu;
  final String nom;

  const Lieu({required this.idLieu, required this.nom});

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      idLieu: int.parse(json['id'].toString()),
      nom: json['nom'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': idLieu, 'nom': nom};

  // Égalité par id : nécessaire pour les listes déroulantes
  @override
  bool operator ==(Object other) => other is Lieu && other.idLieu == idLieu;

  @override
  int get hashCode => idLieu.hashCode;

  @override
  String toString() => nom;
}
