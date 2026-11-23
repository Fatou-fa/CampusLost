/// Catégories de l'application : [libellé, image].
/// Liste unique, utilisée par l'accueil ET par le formulaire de publication,
/// pour que le filtre retrouve bien les annonces publiées.
class Categories {
  static const List<List<String>> liste = [
    ['Clés', 'assets/images/objets/cles.png'],
    ['Téléphones', 'assets/images/objets/telephone.png'],
    ['Papiers', 'assets/images/objets/carte.png'],
    ['Lunettes', 'assets/images/objets/lunettes.png'],
    ['Portefeuilles', 'assets/images/objets/portefeuille.png'],
    ['Audio', 'assets/images/objets/ecouteurs.png'],
    ['Fournitures', 'assets/images/objets/calculatrice.png'],
    ['Autres', 'assets/images/objets/autres.png'], // tout ce qui n'entre pas ailleurs
  ];

  /// Les libellés seuls (pour la liste déroulante du formulaire).
  static List<String> get libelles => liste.map((c) => c[0]).toList();

  /// Image par défaut d'une catégorie (utilisée quand il n'y a pas de photo).
  static String imageDe(String categorie) {
    for (final c in liste) {
      if (c[0] == categorie) return c[1];
    }
    return 'assets/images/objets/autres.png';
  }
}
