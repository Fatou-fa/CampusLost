import 'package:flutter/foundation.dart';

import '../models/annonce_model.dart';

/// Liste des annonces partagée par les écrans (accueil, publication, détail).
///
/// TEMPORAIRE : les annonces sont en mémoire. Quand l'API PHP sera prête,
/// la liste sera chargée depuis le serveur (ApiConfig.annonces) et
/// [ajouter] enverra l'annonce au serveur ; les écrans ne changeront pas.
class AnnonceProvider extends ChangeNotifier {
  /// Catégories de l'application : [libellé, image].
  /// Liste unique, utilisée par l'accueil ET par le formulaire de
  /// publication, pour que le filtre retrouve bien les annonces publiées.
  static const List<List<String>> categories = [
    ['Clés', 'assets/images/objets/cles.png'],
    ['Téléphones', 'assets/images/objets/telephone.png'],
    ['Papiers', 'assets/images/objets/carte.png'],
    ['Lunettes', 'assets/images/objets/lunettes.png'],
    ['Portefeuilles', 'assets/images/objets/portefeuille.png'],
    ['Audio', 'assets/images/objets/ecouteurs.png'],
    ['Fournitures', 'assets/images/objets/calculatrice.png'],
    ['Autres', 'assets/images/objets/autres.png'], // tout ce qui n'entre pas ailleurs
  ];

  // Données d'exemple, en attendant l'API PHP
  final List<Annonce> _annonces = [
    Annonce(
      id: 1,
      titre: "Carte d'étudiant",
      description:
          "Carte d'étudiant UGB au nom d'Awa Ndiaye, oubliée sur une table du 1er étage.",
      type: 'perdu',
      statut: 'active',
      photoUrl: 'assets/images/objets/carte.png',
      date: 'Il y a 2 h',
      categorie: 'Papiers',
      lieu: 'Bibliothèque universitaire',
      auteurId: 1,
      auteurNom: 'Awa N.',
    ),
    Annonce(
      id: 2,
      titre: 'Trousseau de clés',
      description:
          "Deux clés sur un anneau argenté, dont une dorée. Trouvées sur une "
          "table près de l'entrée du Resto U, à l'heure du déjeuner.",
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/cles.png',
      date: 'Hier, 12 h 30',
      categorie: 'Clés',
      lieu: 'Resto U',
      auteurId: 2,
      auteurNom: 'Moussa D.',
    ),
    Annonce(
      id: 3,
      titre: 'Smartphone bleu',
      description: 'Smartphone à coque bleue, écran légèrement fissuré en bas à droite.',
      type: 'perdu',
      statut: 'active',
      photoUrl: 'assets/images/objets/telephone.png',
      date: 'Lundi',
      categorie: 'Téléphones',
      lieu: 'Amphithéâtre A',
      auteurId: 3,
      auteurNom: 'Ibrahima S.',
    ),
    Annonce(
      id: 4,
      titre: 'Lunettes de vue',
      description: 'Lunettes à monture noire dans un étui gris, laissées près du poste 12.',
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/lunettes.png',
      date: 'Lundi',
      categorie: 'Lunettes',
      lieu: 'Salle informatique',
      auteurId: 2,
      auteurNom: 'Moussa D.',
    ),
    Annonce(
      id: 5,
      titre: 'Portefeuille marron',
      description: 'Portefeuille en cuir marron, trouvé sur les gradins. Contenu à décrire pour le récupérer.',
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/portefeuille.png',
      date: 'Dimanche',
      categorie: 'Portefeuilles',
      lieu: 'Terrain de sport',
      auteurId: 4,
      auteurNom: 'Khady F.',
    ),
  ];


  // Texte tapé dans la barre de recherche de l'accueil
  String _recherche = '';

  // Catégorie choisie sur l'accueil (null = toutes les catégories)
  String? _categorie;

  String get recherche => _recherche;

  /// Toutes les annonces, la plus récente en premier.
  List<Annonce> get annonces => List.unmodifiable(_annonces);

  /// Annonces dont le titre contient le texte recherché.
  String? get categorie => _categorie;

  /// Annonces qui correspondent à la recherche ET à la catégorie choisie.
  List<Annonce> get resultats => _annonces
      .where((a) => a.titre.toLowerCase().contains(_recherche.toLowerCase()))
      .where((a) => _categorie == null || a.categorie == _categorie)
      .toList();

  /// Retire le filtre : toutes les annonces sont de nouveau affichées.
  void afficherTout() {
    _categorie = null;
    notifyListeners();
  }

  /// Sélectionne une catégorie ; un second appui sur la même la désélectionne.
  void choisirCategorie(String libelle) {
    _categorie = (_categorie == libelle) ? null : libelle;
    notifyListeners();
  }

  void rechercher(String texte) {
    _recherche = texte;
    notifyListeners(); // l'accueil se redessine avec les nouveaux résultats
  }

  /// Ajoute une annonce publiée en tête de liste.
  void ajouter(Annonce annonce) {
    _annonces.insert(0, annonce);
    notifyListeners();
  }

  /// Numéro pour la prochaine annonce (en attendant l'id donné par MySQL).
  int get prochainId => _annonces.length + 1;
}
