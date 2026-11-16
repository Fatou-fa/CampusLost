/// Un lieu du campus (Bibliothèque, Resto U, Amphithéâtres…).
class Lieu {
  final int id;
  final String nom;

  Lieu({required this.id, required this.nom});

  /// Crée un lieu à partir du JSON renvoyé par l'API.
  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      id: int.parse(json['id'].toString()),
      nom: json['nom'],
    );
  }
}
