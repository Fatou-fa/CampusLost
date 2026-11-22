import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/annonce_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/photo_annonce.dart';

/// Écran 6 : publication ou modification d'une annonce.
///
/// - Publication : on reçoit le [type] ('perdu' ou 'trouve').
/// - Modification : on reçoit l'[annonceAModifier] ; les champs sont
///   pré-remplis et le bouton devient « Enregistrer ».
class FormulaireAnnonceScreen extends StatefulWidget {
  final String type;
  final Annonce? annonceAModifier;

  const FormulaireAnnonceScreen({
    super.key,
    this.type = 'trouve',
    this.annonceAModifier,
  });

  @override
  State<FormulaireAnnonceScreen> createState() =>
      _FormulaireAnnonceScreenState();
}

class _FormulaireAnnonceScreenState extends State<FormulaireAnnonceScreen> {
  // Mêmes catégories que l'accueil (sinon le filtre ne les trouverait pas)
  static final categories =
      AnnonceProvider.categories.map((c) => c[0]).toList();
  static const lieux = [
    'Bibliothèque',
    'Resto U',
    'Amphithéâtres',
    'Pavillons',
    'Salle informatique',
    'Terrain de sport',
    'Autre',
  ];
  static const emplacements = ['Avec moi', 'Déposé à la scolarité'];
  static const _marqueEmplacement = "\n\nL'objet est : ";

  final _formKey = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _date = TextEditingController(text: "Aujourd'hui");
  final _description = TextEditingController();

  String _categorie = categories.first;
  String _lieu = lieux.first;
  String _emplacement = emplacements.first;
  String? _photo; // chemin de la photo choisie (null = image de la catégorie)

  bool get _modification => widget.annonceAModifier != null;
  String get _type => widget.annonceAModifier?.type ?? widget.type;
  bool get _estTrouve => _type == 'trouve';

  @override
  void initState() {
    super.initState();
    final a = widget.annonceAModifier;
    if (a == null) return;

    // Pré-remplissage pour une modification
    _titre.text = a.titre;
    _date.text = a.date;
    if (categories.contains(a.categorie)) _categorie = a.categorie;
    if (lieux.contains(a.lieu)) _lieu = a.lieu;
    // La photo n'est gardée que si c'est une vraie photo (pas l'image de catégorie)
    if (a.photoUrl != null && !a.photoUrl!.startsWith('assets/')) {
      _photo = a.photoUrl;
    }
    // La description peut contenir « L'objet est : … » ajouté à la publication
    final morceaux = a.description.split(_marqueEmplacement);
    _description.text = morceaux.first;
    if (morceaux.length > 1) {
      final e = morceaux[1].replaceAll('.', '');
      if (emplacements.contains(e)) _emplacement = e;
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _date.dispose();
    _description.dispose();
    super.dispose();
  }

  // ---------- Photo ----------

  /// Propose l'appareil photo ou la galerie, puis garde le chemin du fichier.
  Future<void> _choisirPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Couleurs.fond,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (feuille) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Couleurs.marron),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(feuille, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Couleurs.marron),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.pop(feuille, ImageSource.gallery),
            ),
            if (_photo != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                title: const Text('Retirer la photo'),
                onTap: () {
                  Navigator.pop(feuille);
                  setState(() => _photo = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      // imageQuality et maxWidth : photo plus légère, plus rapide à afficher
      final fichier = await ImagePicker()
          .pickImage(source: source, imageQuality: 70, maxWidth: 1200);
      if (fichier != null && mounted) setState(() => _photo = fichier.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir l'appareil photo ou la galerie")),
      );
    }
  }

  // ---------- Date ----------

  /// Calendrier : la date choisie s'écrit dans le champ (jj/mm/aaaa).
  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: maintenant,
      firstDate: DateTime(maintenant.year - 1),
      lastDate: maintenant, // pas de date dans le futur
      helpText: _estTrouve ? 'Trouvé le' : 'Perdu le',
    );
    if (date == null) return;
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    setState(() => _date.text = '$jour/$mois/${date.year}');
  }

  // ---------- Enregistrement ----------

  void _publier() {
    if (!_formKey.currentState!.validate()) return;

    final annonces = context.read<AnnonceProvider>();
    final auteur = context.read<AuthProvider>().utilisateur;
    final messager = ScaffoldMessenger.of(context);

    var description = _description.text.trim();
    if (_estTrouve) description += '$_marqueEmplacement$_emplacement.';

    final ancienne = widget.annonceAModifier;
    final annonce = Annonce(
      id: ancienne?.id ?? annonces.prochainId,
      titre: _titre.text.trim(),
      description: description,
      type: _type,
      statut: ancienne?.statut ?? 'active',
      // Pas de photo : on montre l'image de la catégorie
      photoUrl: _photo ?? AnnonceProvider.imageDe(_categorie),
      date: _date.text.trim(),
      categorie: _categorie,
      lieu: _lieu,
      auteurId: ancienne?.auteurId ?? auteur?.id ?? 0,
      auteurNom: ancienne?.auteurNom ??
          (auteur == null
              ? 'Anonyme'
              : '${majuscule(auteur.prenom)} ${auteur.nom.isEmpty ? '' : '${auteur.nom[0].toUpperCase()}.'}'.trim()),
      auteurTelephone: ancienne?.auteurTelephone ?? auteur?.telephone ?? '',
    );

    if (_modification) {
      annonces.modifier(annonce);
    } else {
      annonces.ajouter(annonce);
    }

    Navigator.pop(context);
    messager.showSnackBar(SnackBar(
      content: Text(_modification ? 'Annonce modifiée' : 'Annonce publiée'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: Text(
          _modification
              ? "Modifier l'annonce"
              : (_estTrouve ? 'Objet trouvé' : 'Objet perdu'),
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
              _zonePhoto(),
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

              // Date : appui = calendrier (pas de saisie au clavier)
              TextFormField(
                controller: _date,
                readOnly: true,
                onTap: _choisirDate,
                decoration: _style('Date', "Aujourd'hui").copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      color: Couleurs.marron),
                ),
              ),
              const SizedBox(height: 14),

              // Uniquement pour un objet trouvé : où est-il maintenant ?
              if (_estTrouve) ...[
                _liste("Où est l'objet ?", emplacements, _emplacement,
                    (v) => setState(() => _emplacement = v)),
                const SizedBox(height: 14),
              ],

              _champ(_description, 'Description', 'Couleur, forme, porte-clés…',
                  lignes: 3, obligatoire: false),
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
                      Icon(Icons.info_outline, color: Couleurs.marron, size: 20),
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
                child: Text(
                  _modification ? 'Enregistrer' : "Publier l'annonce",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zone photo : bouton « Ajouter » ou aperçu de la photo choisie.
  Widget _zonePhoto() {
    return Material(
      color: Couleurs.beigeClair,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _choisirPhoto,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: _photo == null ? 110 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Couleurs.marron),
          ),
          child: _photo == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_outlined, color: Couleurs.marron, size: 30),
                    SizedBox(height: 6),
                    Text('Ajouter une photo (facultatif)',
                        style: TextStyle(color: Couleurs.marron, fontWeight: FontWeight.w600)),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: PhotoAnnonce(chemin: _photo, ajustement: BoxFit.cover),
                    ),
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, color: Couleurs.marron, size: 20),
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

  /// Champ de texte ; [lignes] > 1 pour une zone plus haute.
  Widget _champ(TextEditingController controleur, String libelle, String exemple,
      {int lignes = 1, bool obligatoire = true}) {
    return TextFormField(
      controller: controleur,
      maxLines: lignes,
      textCapitalization: TextCapitalization.sentences,
      decoration: _style(libelle, exemple),
      validator: (valeur) => obligatoire && (valeur == null || valeur.trim().isEmpty)
          ? 'Obligatoire'
          : null,
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
