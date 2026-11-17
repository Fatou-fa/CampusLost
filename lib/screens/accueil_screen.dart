import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../theme/couleurs.dart';
import '../widgets/annonce_card.dart';

/// Écran d'accueil : recherche, bannière, catégories et annonces récentes.
class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  // Texte tapé dans la barre de recherche
  String recherche = '';

  // Catégories affichées en haut : [libellé, image]
  final List<List<String>> categories = [
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
  final List<Annonce> annonces = [
    Annonce(
      id: 1,
      titre: "Carte d'étudiant",
      description: '',
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
      description: '',
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
      description: '',
      type: 'perdu',
      statut: 'active',
      photoUrl: 'assets/images/objets/telephone.png',
      date: 'Lundi',
      categorie: 'Électronique',
      lieu: 'Amphithéâtre A',
      auteurId: 3,
      auteurNom: 'Ibrahima S.',
    ),
    Annonce(
      id: 4,
      titre: 'Lunettes de vue',
      description: '',
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
      description: '',
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

  @override
  Widget build(BuildContext context) {
    // On garde les annonces dont le titre contient le texte recherché
    final resultats = annonces
        .where((a) => a.titre.toLowerCase().contains(recherche.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Couleurs.fond,
      // ListView : toute la page défile, en-tête compris
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _enTete(),
          const SizedBox(height: 20),
          _titreSection('Catégories'),
          const SizedBox(height: 12),
          _listeCategories(),
          const SizedBox(height: 24),
          _titreSection('Annonces récentes', detail: '${resultats.length} annonces'),
          const SizedBox(height: 12),

          // ---------- Liste des annonces ----------
          if (resultats.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Aucune annonce ne correspond à votre recherche.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Couleurs.texteDiscret),
              ),
            )
          else
            for (final annonce in resultats)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: AnnonceCard(annonce: annonce),
              ),
          const SizedBox(height: 24),
        ],
      ),

    );
  }

  /// En-tête marron arrondi : logo, salutation et barre de recherche.
  Widget _enTete() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        color: Couleurs.marronFonce,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/icone_app.png',
                      width: 44, height: 44),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour Fatou',
                        style: TextStyle(color: Color(0xFFEADCC4), fontSize: 14),
                      ),
                      Text(
                        'CampusLost',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              "Qu'avez-vous perdu\naujourd'hui ?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                height: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            // Barre de recherche
            TextField(
              onChanged: (texte) => setState(() => recherche = texte),
              decoration: InputDecoration(
                hintText: 'Rechercher un objet…',
                prefixIcon: const Icon(Icons.search, color: Couleurs.marron),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Titre de section, avec un petit texte à droite si besoin.
  Widget _titreSection(String titre, {String? detail}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Couleurs.marronFonce,
            ),
          ),
          if (detail != null)
            Text(detail,
                style: const TextStyle(fontSize: 13, color: Couleurs.texteDiscret)),
        ],
      ),
    );
  }

  /// Catégories affichées en grille : si elles ne tiennent pas sur une ligne,
  /// elles passent à la ligne suivante (Wrap), sans défilement horizontal.
  Widget _listeCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12, // espace horizontal entre deux catégories
        runSpacing: 16, // espace vertical entre deux lignes
        children: [
          for (final categorie in categories)
            SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Couleurs.marronFonce.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(categorie[1], fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categorie[0],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Couleurs.texte),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
