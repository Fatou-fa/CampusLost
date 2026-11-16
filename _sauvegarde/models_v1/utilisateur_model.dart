class Utilisateur {
  final int idUtilisateur;
  final String nom;
  final String prenom;
  final String? email;
  final int telephone;
  final String motDePasse;

  const Utilisateur({
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    this.email,
    required this.telephone,
    required this.motDePasse,
  });

  public bool sInscrire(){
    
  }
}
