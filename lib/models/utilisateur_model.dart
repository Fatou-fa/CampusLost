/// Un utilisateur de CampusLost.
///
/// Le mot de passe n'est pas stocké ici 
class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone; // texte, pour garder le +221

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
  });
}
