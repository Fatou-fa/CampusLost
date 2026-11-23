/// Un utilisateur de CampusLost.
///
/// Le mot de passe n'est pas stocké ici : c'est Firebase Auth qui le garde.
/// Le profil (nom, prénom, téléphone) est enregistré dans Firestore,
/// collection « utilisateurs », document nommé avec l'[id].
class Utilisateur {
  final String id; // uid donné par Firebase Auth
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

  /// Lit un profil depuis un document Firestore.
  factory Utilisateur.depuisMap(String id, Map<String, dynamic> data) {
    return Utilisateur(
      id: id,
      nom: data['nom'] as String? ?? '',
      prenom: data['prenom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telephone: data['telephone'] as String? ?? '',
    );
  }

  /// Transforme le profil en données Firestore (l'id est le nom du document).
  Map<String, dynamic> versMap() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
      };
}
