import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annonce_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';

/// Écran 6 : formulaire de publication d'une annonce.
///
/// Le même écran sert pour un objet perdu et pour un objet trouvé :
/// seuls le titre et quelques champs changent selon [type].
/// À la publication, l'annonce est ajoutée à [AnnonceProvider] et
/// l'utilisateur revient à l'accueil, où elle apparaît en tête de liste.
class FormulaireAnnonceScreen extends StatefulWidget {
  /// 'perdu' ou 'trouve'
  final String type;

  const FormulaireAnnonceScreen({super.key, this.type = 'trouve'});

  @override
  State<FormulaireAnnonceScreen> createState() =>
      _FormulaireAnnonceScreenState();
}

class _FormulaireAnnonceScreenState extends State<FormulaireAnnonceScreen> {
  // Listes fixes, en attendant de les charger depuis la base de données
  // Mêmes catégories que l'accueil (sinon le filtre ne les trouverait pas)
  static final categories =
      AnnonceProvider.categories.map((c) => c[0]).toList();
  static const lieux = [
    'Bibliothèque',
    'Resto U',
    'Amphithéâtres',
    'Pavillons',
    'Salle informatique',
    'Autre',
  ];
  static const emplacements = ['Avec moi', 'Déposé à la scolarité'];

  final _formKey = GlobalKey<FormState>();

  // Champs de texte
  final _titre = TextEditingController();
  final _date = TextEditingController(text: "Aujourd'hui");
  final _description = TextEditingController();

  // Valeurs choisies dans les listes déroulantes (première par défaut)
  String _categorie = categories.first;
  String _lieu = lieux.first;
  String _emplacement = emplacements.first;

  bool get _estTrouve => widget.type == 'trouve';

  @override
  void dispose() {
    _titre.dispose();
    _date.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Vérifie le formulaire, crée l'annonce puis revient à l'accueil.
  void _publier() {
    if (!_formKey.currentState!.validate()) return;

    final annonces = context.read<AnnonceProvider>();
    final auteur = context.read<AuthProvider>().utilisateur;

    // Pour un objet trouvé, on précise où il se trouve maintenant
    var description = _description.text.trim();
    if (_estTrouve) description += '\n\nL\'objet est : $_emplacement.';

    annonces.ajouter(Annonce(
      id: annonces.prochainId,
      titre: _titre.text.trim(),
      description: description,
      type: widget.type,
      statut: 'active',
      photoUrl: null, // la photo sera gérée plus tard (appareil photo)
      date: _date.text.trim(),
      categorie: _categorie,
      lieu: _lieu,
      auteurId: auteur?.id ?? 0,
      auteurNom: auteur == null
          ? 'Anonyme'
          : '${auteur.prenom} ${auteur.nom.isEmpty ? '' : '${auteur.nom[0]}.'}',
    ));

    // On récupère le messager avant de quitter l'écran
    final messager = ScaffoldMessenger.of(context);
    Navigator.pop(context); // retour à l'accueil
    messager.showSnackBar(
      const SnackBar(content: Text('Annonce publiée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: Text(
          _estTrouve ? 'Objet trouvé' : 'Objet perdu',
          style: const TextStyle(
            color: Couleurs.marronFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- Photo (facultative) ----------
              OutlinedButton.icon(
                onPressed: () {
                  // Plus tard : ouvrir l'appareil photo ou la galerie
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Ajouter une photo (facultatif)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(110),
                  foregroundColor: Couleurs.marron,
                  backgroundColor: Couleurs.beigeClair,
                  side: const BorderSide(color: Couleurs.marron),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---------- Champs ----------
              _champ(_titre, 'Titre',
                  _estTrouve ? 'Ex. : Trousseau de clés' : "Ex. : Carte d'étudiant"),
              const SizedBox(height: 14),
              _liste('Catégorie', categories, _categorie,
                  (v) => setState(() => _categorie = v)),
              const SizedBox(height: 14),
              _liste(_estTrouve ? 'Lieu de découverte' : 'Lieu de la perte',
                  lieux, _lieu, (v) => setState(() => _lieu = v)),
              const SizedBox(height: 14),
              _champ(_date, 'Date', "Aujourd'hui"),
              const SizedBox(height: 14),

              // Uniquement pour un objet trouvé : où est-il maintenant ?
              if (_estTrouve) ...[
                _liste("Où est l'objet ?", emplacements, _emplacement,
                    (v) => setState(() => _emplacement = v)),
                const SizedBox(height: 14),
              ],

              _champ(_description, 'Description', 'Couleur, forme, porte-clés…',
                  lignes: 3),
              const SizedBox(height: 14),

              // ---------- Conseil (objet trouvé seulement) ----------
              if (_estTrouve)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Couleurs.beigeClair,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Couleurs.marron, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gardez un détail pour vous : il servira à vérifier le vrai propriétaire.',
                          style: TextStyle(color: Couleurs.marron),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ---------- Bouton principal ----------
              ElevatedButton(
                onPressed: _publier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Couleurs.marron,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Publier l'annonce",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Style commun à tous les champs du formulaire.
  InputDecoration _style(String libelle, [String? exemple]) {
    return InputDecoration(
      labelText: libelle,
      hintText: exemple,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Champ de texte obligatoire ; [lignes] > 1 pour une zone plus haute.
  Widget _champ(TextEditingController controleur, String libelle,
      String exemple,
      {int lignes = 1}) {
    return TextFormField(
      controller: controleur,
      maxLines: lignes,
      decoration: _style(libelle, exemple),
      validator: (valeur) =>
          (valeur == null || valeur.trim().isEmpty) ? 'Obligatoire' : null,
    );
  }

  /// Liste déroulante : [valeur] est le choix actuel, [quandChange] le
  /// mémorise dans l'état de l'écran.
  Widget _liste(String libelle, List<String> choix, String valeur,
      void Function(String) quandChange) {
    return DropdownButtonFormField<String>(
      initialValue: valeur,
      decoration: _style(libelle),
      items: choix
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (nouvelle) {
        if (nouvelle != null) quandChange(nouvelle);
      },
    );
  }
}
