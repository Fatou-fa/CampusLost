import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annonce_model.dart';

/// Rôle : lire et écrire les annonces dans Firestore (collection « annonces »).
///
/// Photos : pour rester sur l'offre gratuite de Firebase (Firebase Storage
/// demande maintenant une carte bancaire), la photo, déjà réduite par
/// image_picker, est rangée dans l'annonce sous forme de texte base64
/// (« data:image/jpeg;base64,… »). Un document Firestore peut faire 1 Mo.
class AnnonceRepository {
  AnnonceRepository(this._db);

  final FirebaseFirestore _db;

  /// Taille maximale de la photo une fois en base64 (environ 700 Ko).
  static const _photoMax = 700000;

  CollectionReference<Map<String, dynamic>> get _annonces =>
      _db.collection('annonces');

  /// Toutes les annonces, en temps réel, les plus récentes d'abord.
  /// Le flux renvoie une nouvelle liste à chaque changement dans Firestore.
  Stream<List<Annonce>> ecouter() {
    return _annonces.snapshots().map((resultat) {
      final liste = [
        for (final doc in resultat.docs) Annonce.depuisMap(doc.id, doc.data())
      ];
      liste.sort((a, b) => b.creeLe.compareTo(a.creeLe));
      return liste;
    });
  }

  /// Nouvel identifiant, calculé sur le téléphone (sans attendre le réseau).
  String nouvelId() => _annonces.doc().id;

  /// Publie une nouvelle annonce.
  Future<void> ajouter(Annonce annonce) async {
    final donnees = (await _avecPhotoEnvoyable(annonce)).versMap();
    donnees['creeLe'] = DateTime.now().millisecondsSinceEpoch;
    await _annonces.doc(annonce.id).set(donnees);
  }

  /// Enregistre les modifications d'une annonce (sans changer sa date de
  /// publication).
  Future<void> modifier(Annonce annonce) async {
    final donnees = (await _avecPhotoEnvoyable(annonce)).versMap();
    donnees.remove('creeLe');
    await _annonces.doc(annonce.id).update(donnees);
  }

  Future<void> changerStatut(String id, String statut) =>
      _annonces.doc(id).update({'statut': statut});

  Future<void> supprimer(String id) => _annonces.doc(id).delete();

  /// Base vide (premier lancement) : on ajoute quelques annonces d'exemple
  /// pour que l'accueil ne soit pas vide pendant la démonstration.
  Future<void> ajouterExemplesSiVide() async {
    final premier = await _annonces.limit(1).get();
    if (premier.docs.isNotEmpty) return;

    final lot = _db.batch(); // plusieurs écritures envoyées en une fois
    var ordre = DateTime.now().millisecondsSinceEpoch;
    for (final a in _exemples) {
      final donnees = a.versMap();
      donnees['creeLe'] = ordre--;
      lot.set(_annonces.doc(), donnees);
    }
    await lot.commit();
  }

  /// Photo prise avec le téléphone (chemin d'un fichier) : on la transforme
  /// en texte base64. Les images de l'app (assets/…) restent telles quelles.
  Future<Annonce> _avecPhotoEnvoyable(Annonce annonce) async {
    final chemin = annonce.photoUrl;
    if (chemin == null ||
        chemin.isEmpty ||
        chemin.startsWith('assets/') ||
        chemin.startsWith('data:')) {
      return annonce;
    }
    final octets = await File(chemin).readAsBytes();
    final texte = 'data:image/jpeg;base64,${base64Encode(octets)}';
    if (texte.length > _photoMax) {
      throw Exception('Photo trop lourde : choisissez-en une autre');
    }
    return annonce.copieAvecPhoto(texte);
  }

  /// Annonces d'exemple (auteurs fictifs, id commençant par « exemple- »).
  static final _exemples = [
    Annonce(
      id: '',
      titre: "Carte d'étudiant",
      description:
          "Carte d'étudiant UGB au nom d'Awa Ndiaye, oubliée sur une table du 1er étage.",
      type: 'perdu',
      statut: 'active',
      photoUrl: 'assets/images/objets/carte.png',
      date: 'Il y a 2 h',
      categorie: 'Papiers',
      lieu: 'Bibliothèque universitaire',
      auteurId: 'exemple-201',
      auteurNom: 'Awa N.',
      auteurTelephone: '771234567',
    ),
    Annonce(
      id: '',
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
      auteurId: 'exemple-202',
      auteurNom: 'Moussa D.',
      auteurTelephone: '781234567',
    ),
    Annonce(
      id: '',
      titre: 'Smartphone bleu',
      description: 'Smartphone à coque bleue, écran légèrement fissuré en bas à droite.',
      type: 'perdu',
      statut: 'active',
      photoUrl: 'assets/images/objets/telephone.png',
      date: 'Lundi',
      categorie: 'Téléphones',
      lieu: 'Amphithéâtre A',
      auteurId: 'exemple-203',
      auteurNom: 'Ibrahima S.',
      auteurTelephone: '761234567',
    ),
    Annonce(
      id: '',
      titre: 'Lunettes de vue',
      description: 'Lunettes à monture noire dans un étui gris, laissées près du poste 12.',
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/lunettes.png',
      date: 'Lundi',
      categorie: 'Lunettes',
      lieu: 'Salle informatique',
      auteurId: 'exemple-202',
      auteurNom: 'Moussa D.',
      auteurTelephone: '781234567',
    ),
    Annonce(
      id: '',
      titre: 'Portefeuille marron',
      description:
          'Portefeuille en cuir marron, trouvé sur les gradins. Contenu à décrire pour le récupérer.',
      type: 'trouve',
      statut: 'active',
      photoUrl: 'assets/images/objets/portefeuille.png',
      date: 'Dimanche',
      categorie: 'Portefeuilles',
      lieu: 'Terrain de sport',
      auteurId: 'exemple-204',
      auteurNom: 'Khady F.',
      auteurTelephone: '701234567',
    ),
  ];
}

final annonceRepositoryProvider = Provider<AnnonceRepository>(
  (ref) => AnnonceRepository(FirebaseFirestore.instance),
);
