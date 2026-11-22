import 'package:flutter/foundation.dart';

import '../models/annonce_model.dart';

/// Liste des annonces partagée par tous les écrans.
///
/// TEMPORAIRE : les annonces sont en mémoire (elles reviennent aux exemples
/// au redémarrage). Quand l'API PHP sera prête, chaque méthode enverra la
/// modification au serveur ; les écrans ne changeront pas.
class AnnonceProvider extends ChangeNotifier {
  /// Catégories de l'application : [libellé, image].
  /// Liste unique, utilisée par l'accueil ET par le formulaire.
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

  /// Image par défaut d'une catégorie (utilisée quand il n'y a pas de photo).
  static String imageDe(String categorie) {
    for (final c in categories) {
      if (c[0] == categorie) return c[1];
    }
    return 'assets/images/objets/autres.png';
  }

  // Données d'exemple, en attendant l'API PHP.
  // Les annonces 6 et 7 appartiennent au compte de démonstration (id 99).
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
      auteurId: 201,
      auteurNom: 'Awa N.',
      auteurTelephone: '771234567',
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
      auteurId: 202,
      auteurNom: 'Moussa D.',
      auteurTelephone: '781234567',
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
      auteurId: 203,
      auteurNom: 'Ibrahima S.',
      auteurTelephone: '761234567',
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
      auteurId: 202,
      auteurNom: 'Moussa D.',
      auteurTelephone: '781234567',
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
      auteurId: 204,
      auteurNom: 'Khady F.',
      auteurTelephone: '701234567',
    ),
    Annonce(
      id: 6,
      titre: 'Écouteurs sans fil',
      description: 'Écouteurs blancs dans leur boîtier, trouvés sur un banc devant le pavillon G.',
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/ecouteurs.png',
      date: 'Mardi',
      categorie: 'Audio',
      lieu: 'Pavillons',
      auteurId: 99,
      auteurNom: 'Étudiant D.',
      auteurTelephone: '770000000',
    ),
    Annonce(
      id: 7,
      titre: 'Calculatrice',
      description: 'Calculatrice scientifique oubliée après un examen.',
      type: 'trouve',
      statut: 'restitue',
      photoUrl: 'assets/images/objets/calculatrice.png',
      date: 'La semaine dernière',
      categorie: 'Fournitures',
      lieu: 'Amphithéâtre B',
      auteurId: 99,
      auteurNom: 'Étudiant D.',
      auteurTelephone: '770000000',
    ),
  ];

  // Texte tapé dans la barre de recherche de l'accueil
  String _recherche = '';

  // Catégorie choisie sur l'accueil (null = toutes les catégories)
  String? _categorie;

  String get recherche => _recherche;
  String? get categorie => _categorie;

  /// Toutes les annonces, la plus récente en premier.
  List<Annonce> get annonces => List.unmodifiable(_annonces);

  /// Annonces de l'accueil : actives (pas encore restituées) et qui
  /// correspondent à la recherche (titre, lieu ou catégorie) ET à la catégorie.
  List<Annonce> get resultats {
    final texte = _recherche.toLowerCase();
    return _annonces
        .where((a) => !a.estRestituee)
        .where((a) =>
            a.titre.toLowerCase().contains(texte) ||
            a.lieu.toLowerCase().contains(texte) ||
            a.categorie.toLowerCase().contains(texte))
        .where((a) => _categorie == null || a.categorie == _categorie)
        .toList();
  }

  /// Annonces publiées par un utilisateur (écran « Mes annonces »).
  List<Annonce> deAuteur(int auteurId) =>
      _annonces.where((a) => a.auteurId == auteurId).toList();

  /// Retrouve une annonce par son id (null si elle a été supprimée).
  Annonce? parId(int id) {
    for (final a in _annonces) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Numéro pour la prochaine annonce (en attendant l'id donné par MySQL).
  int get prochainId {
    var max = 0;
    for (final a in _annonces) {
      if (a.id > max) max = a.id;
    }
    return max + 1;
  }

  // ---------- Recherche et filtre ----------

  void rechercher(String texte) {
    _recherche = texte;
    notifyListeners(); // l'accueil se redessine avec les nouveaux résultats
  }

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

  // ---------- Modifications ----------

  /// Ajoute une annonce publiée en tête de liste.
  void ajouter(Annonce annonce) {
    _annonces.insert(0, annonce);
    notifyListeners();
  }

  /// Remplace une annonce existante (même id) par sa version modifiée.
  void modifier(Annonce annonce) {
    final index = _annonces.indexWhere((a) => a.id == annonce.id);
    if (index == -1) return;
    _annonces[index] = annonce;
    notifyListeners();
  }

  /// L'objet a été rendu : l'annonce passe dans « Restituées ».
  void marquerRestituee(int id) {
    final annonce = parId(id);
    if (annonce == null) return;
    modifier(annonce.copieAvecStatut('restitue'));
  }

  void supprimer(int id) {
    _annonces.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
