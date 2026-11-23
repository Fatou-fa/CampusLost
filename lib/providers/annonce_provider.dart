import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annonce_model.dart';
import 'auth_provider.dart';

/// Toutes les annonces.
///
/// Lecture :  ref.watch(annoncesProvider)   → la liste des annonces
/// Action :   ref.read(annoncesProvider.notifier).ajouter(annonce)
///
/// TEMPORAIRE : les annonces sont en mémoire (elles reviennent aux exemples
/// au redémarrage). Quand l'API PHP sera prête, chaque méthode enverra la
/// modification au serveur ; les écrans ne changeront pas.
final annoncesProvider =
    NotifierProvider<AnnoncesNotifier, List<Annonce>>(AnnoncesNotifier.new);

class AnnoncesNotifier extends Notifier<List<Annonce>> {
  /// Données d'exemple, en attendant l'API PHP.
  /// Les annonces 6 et 7 appartiennent au compte de démonstration (id 99).
  @override
  List<Annonce> build() {
    return [
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
  }

  /// Numéro pour la prochaine annonce (en attendant l'id donné par MySQL).
  int get prochainId {
    var max = 0;
    for (final a in state) {
      if (a.id > max) max = a.id;
    }
    return max + 1;
  }

  // Riverpod : on ne modifie jamais la liste, on la remplace par une nouvelle
  // (state = …). C'est ce remplacement qui prévient les écrans.

  /// Ajoute une annonce publiée en tête de liste.
  void ajouter(Annonce annonce) => state = [annonce, ...state];

  /// Remplace une annonce existante (même id) par sa version modifiée.
  void modifier(Annonce annonce) =>
      state = [for (final a in state) a.id == annonce.id ? annonce : a];

  /// L'objet a été rendu : l'annonce passe dans « Restituées ».
  void marquerRestituee(int id) => state = [
        for (final a in state) a.id == id ? a.copieAvecStatut('restitue') : a
      ];

  void supprimer(int id) => state = state.where((a) => a.id != id).toList();
}

/// Texte tapé dans la barre de recherche de l'accueil.
final rechercheProvider = StateProvider<String>((ref) => '');

/// Catégorie choisie sur l'accueil (null = toutes les catégories).
final categorieProvider = StateProvider<String?>((ref) => null);

/// Annonces de l'accueil : calculées à partir des trois providers ci-dessus.
/// Actives (pas restituées), qui correspondent à la recherche (titre, lieu ou
/// catégorie) et à la catégorie choisie. Recalculées automatiquement dès
/// que l'un des trois change.
final resultatsProvider = Provider<List<Annonce>>((ref) {
  final annonces = ref.watch(annoncesProvider);
  final texte = ref.watch(rechercheProvider).toLowerCase();
  final categorie = ref.watch(categorieProvider);

  return annonces
      .where((a) => !a.estRestituee)
      .where((a) =>
          a.titre.toLowerCase().contains(texte) ||
          a.lieu.toLowerCase().contains(texte) ||
          a.categorie.toLowerCase().contains(texte))
      .where((a) => categorie == null || a.categorie == categorie)
      .toList();
});

/// Annonces publiées par l'utilisateur connecté (onglet « Mes annonces »).
final mesAnnoncesProvider = Provider<List<Annonce>>((ref) {
  final moi = ref.watch(authProvider);
  if (moi == null) return [];
  return ref.watch(annoncesProvider).where((a) => a.auteurId == moi.id).toList();
});

/// Une annonce à partir de son id (null si elle a été supprimée).
/// « family » : un provider qui prend un paramètre → annonceParIdProvider(3).
final annonceParIdProvider = Provider.family<Annonce?, int>((ref, id) {
  for (final a in ref.watch(annoncesProvider)) {
    if (a.id == id) return a;
  }
  return null;
});
