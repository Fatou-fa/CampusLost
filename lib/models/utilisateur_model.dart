/// Un utilisateur de CampusLost.
///
/// Le mot de passe n'est pas stocké ici : l'API ne le renvoie jamais.
class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone; // texte, pour garder le 0 et le +221

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
  });

  /// Crée un utilisateur à partir du JSON renvoyé par l'API.
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: int.parse(json['id'].toString()),
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'].toString(),
    );
  }

  /// Transforme l'utilisateur en JSON pour l'envoyer à l'API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
    };
  }
}
