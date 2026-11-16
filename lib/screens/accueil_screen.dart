import 'package:flutter/material.dart';

import '../models/annonce_model.dart';
import '../theme/couleurs.dart';
import '../widgets/annonce_card.dart';

/// Écran d'accueil : recherche, filtres et liste des annonces récentes.
class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  // Filtre sélectionné : 'tous', 'perdu' ou 'trouve'
  String filtre = 'tous';

  // Texte tapé dans la barre de recherche
  String recherche = '';

  // Données d'exemple, en attendant l'API PHP
  final List<Annonce> annonces = [
    Annonce(
      id: 1,
      titre: "Carte d'étudiant",
      description: '',
      type: 'perdu',
      statut: 'active',
      date: "aujourd'hui",
      categorie: 'Papiers',
      lieu: 'Bibliothèque',
      auteurId: 1,
      auteurNom: 'Awa N.',
    ),
    Annonce(
      id: 2,
      titre: 'Trousseau de clés',
      description: '',
      type: 'trouve',
      statut: 'active',
      date: 'hier',
      categorie: 'Clés',
      lieu: 'Resto U',
      auteurId: 2,
      auteurNom: 'Moussa D.',
    ),
    Annonce(
      id: 3,
      titre: 'Téléphone',
      description: '',
      type: 'perdu',
      statut: 'active',
      date: 'lundi',
      categorie: 'Électronique',
      lieu: 'Amphithéâtre',
      auteurId: 3,
      auteurNom: 'Ibrahima S.',
    ),
    Annonce(
      id: 4,
      titre: 'Clé USB',
      description: '',
      type: 'trouve',
      statut: 'active',
      date: 'lundi',
      categorie: 'Électronique',
      lieu: 'Salle informatique',
      auteurId: 2,
      auteurNom: 'Moussa D.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // On garde seulement les annonces qui correspondent au filtre ET à la recherche
    final resultats = annonces.where((a) {
      final bonType = filtre == 'tous' || a.type == filtre;
      final bonTexte = a.titre.toLowerCase().contains(recherche.toLowerCase());
      return bonType && bonTexte;
    }).toList();

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: Column(
        children: [
          // ---------- En-tête marron ----------
          Container(
            width: double.infinity,
            color: Couleurs.marronFonce,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour Awa',
                  style: TextStyle(color: Color(0xFFEADCC4)),
                ),
                const Text(
                  "Qu'avez-vous perdu ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Barre de recherche
                TextField(
                  onChanged: (texte) => setState(() => recherche = texte),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un objet…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Puces de filtre ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                _puce('Tous', 'tous'),
                _puce('Perdus', 'perdu'),
                _puce('Trouvés', 'trouve'),
              ],
            ),
          ),

          // ---------- Liste des annonces ----------
          Expanded(
            child: resultats.isEmpty
                ? const Center(child: Text('Aucune annonce trouvée'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: resultats.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnnonceCard(
                        annonce: resultats[index],
                        onTap: () {
                          // Plus tard : ouvrir l'écran de détail
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),

      // ---------- Bouton « + » pour publier ----------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Couleurs.beige,
        foregroundColor: Couleurs.texte,
        onPressed: () {
          // Plus tard : ouvrir l'écran « Publier une annonce »
        },
        child: const Icon(Icons.add),
      ),

      // ---------- Barre de navigation ----------
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        indicatorColor: Couleurs.beigeClair,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.list_alt), label: 'Mes annonces'),
          NavigationDestination(
              icon: Icon(Icons.inbox_outlined), label: 'Réclamations'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  /// Crée une puce de filtre. Elle est marron quand elle est sélectionnée.
  Widget _puce(String texte, String valeur) {
    final selectionnee = filtre == valeur;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texte),
        selected: selectionnee,
        selectedColor: Couleurs.marronFonce,
        showCheckmark: false,
        labelStyle:
            TextStyle(color: selectionnee ? Colors.white : Couleurs.texte),
        onSelected: (_) => setState(() => filtre = valeur),
      ),
    );
  }
}
