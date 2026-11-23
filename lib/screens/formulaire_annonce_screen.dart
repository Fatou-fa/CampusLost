import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../config/categories.dart';
import '../models/annonce_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/champs_formulaire.dart';
import '../widgets/photo_annonce.dart';

/// Écran 6 : publication ou modification d'une annonce.
///
/// - Publication : on reçoit le [type] ('perdu' ou 'trouve').
/// - Modification : on reçoit l'[annonceId] (adresse /modifier-annonce/3) ;
///   les champs sont pré-remplis et le bouton devient « Enregistrer ».
class FormulaireAnnonceScreen extends ConsumerStatefulWidget {
  final String type;
  final int? annonceId;

  const FormulaireAnnonceScreen({
    super.key,
    this.type = 'trouve',
    this.annonceId,
  });

  @override
  ConsumerState<FormulaireAnnonceScreen> createState() =>
      _FormulaireAnnonceScreenState();
}

class _FormulaireAnnonceScreenState
    extends ConsumerState<FormulaireAnnonceScreen> {
  // Mêmes catégories que l'accueil (sinon le filtre ne les trouverait pas)
  static final categories = Categories.libelles;
  // Lieux fréquents du campus, proposés sous le champ « Lieu » :
  // un appui les écrit dans le champ, mais on peut écrire n'importe quel lieu.
  static const lieuxFrequents = [
    'Bibliothèque universitaire',
    'Resto U',
    'Amphithéâtre A',
    'Pavillons',
    'Salle informatique',
    'Terrain de sport',
    'Scolarité',
  ];
  static const emplacements = ['Avec moi', 'Déposé à la scolarité'];
  static const _marqueEmplacement = "\n\nL'objet est : ";

  final _formKey = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _date = TextEditingController(text: "Aujourd'hui");
  final _description = TextEditingController();

  String _categorie = categories.first;
  final _lieu = TextEditingController(); // lieu écrit librement
  String _emplacement = emplacements.first;
  String? _photo; // chemin de la photo choisie (null = image de la catégorie)

  Annonce? _ancienne; // l'annonce à modifier (null = nouvelle annonce)

  bool get _modification => _ancienne != null;
  String get _type => _ancienne?.type ?? widget.type;
  bool get _estTrouve => _type == 'trouve';

  @override
  void initState() {
    super.initState();
    // ref.read est autorisé dans initState (lecture unique)
    if (widget.annonceId != null) {
      _ancienne = ref.read(annonceParIdProvider(widget.annonceId!));
    }
    final a = _ancienne;
    if (a == null) return;

    // Pré-remplissage pour une modification
    _titre.text = a.titre;
    _date.text = a.date;
    if (categories.contains(a.categorie)) _categorie = a.categorie;
    _lieu.text = a.lieu;
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
    _lieu.dispose();
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

    final annonces = ref.read(annoncesProvider.notifier);
    final auteur = ref.read(authProvider);
    final messager = ScaffoldMessenger.of(context);

    var description = _description.text.trim();
    if (_estTrouve) description += '$_marqueEmplacement$_emplacement.';

    final ancienne = _ancienne;
    final annonce = Annonce(
      id: ancienne?.id ?? annonces.prochainId,
      titre: _titre.text.trim(),
      description: description,
      type: _type,
      statut: ancienne?.statut ?? 'active',
      // Pas de photo : on montre l'image de la catégorie
      photoUrl: _photo ?? Categories.imageDe(_categorie),
      date: _date.text.trim(),
      categorie: _categorie,
      lieu: _lieu.text.trim(),
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

    context.pop(); // retour à l'écran précédent
    messager.showSnackBar(SnackBar(
      content: Text(_modification ? 'Annonce modifiée' : 'Annonce publiée'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs de l'en-tête : corail pour « perdu », vert pour « trouvé »
    // (les mêmes que sur l'écran « Publier une annonce »), marron en modification
    final couleurs = _modification
        ? const [Couleurs.marron, Couleurs.marronFonce]
        : _estTrouve
            ? const [Color(0xFF4E9A72), Color(0xFF2F6A4C)]
            : const [Color(0xFFE07A5F), Color(0xFFC8553D)];

    return Scaffold(
      backgroundColor: Couleurs.fond,
      // SingleChildScrollView + Column (et non ListView) : tous les champs
      // restent construits, donc tous sont vérifiés par validate()
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          children: [
            _enTete(couleurs),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- 1. Photo ----------
                  SectionFormulaire(
                    titre: 'Photo',
                    icone: Icons.photo_camera_outlined,
                    children: [_zonePhoto()],
                  ),
                  const SizedBox(height: 16),

                  // ---------- 2. L'objet ----------
                  SectionFormulaire(
                    titre: "L'objet",
                    icone: Icons.inventory_2_outlined,
                    children: [
                      ChampFormulaire(
                        controleur: _titre,
                        libelle: 'Nom de l\'objet',
                        exemple: _estTrouve
                            ? 'Ex. : Trousseau de clés'
                            : "Ex. : Carte d'étudiant",
                        icone: Icons.edit_outlined,
                      ),
                      const SizedBox(height: 16),
                      const TitreChamp('Catégorie'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in Categories.liste)
                            PuceChoix(
                              libelle: c[0],
                              image: Image.asset(c[1]),
                              choisie: _categorie == c[0],
                              onTap: () => setState(() => _categorie = c[0]),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---------- 3. Où et quand ----------
                  SectionFormulaire(
                    titre: 'Où et quand ?',
                    icone: Icons.place_outlined,
                    children: [
                      // Lieu : saisie libre + suggestions à toucher
                      ChampFormulaire(
                        controleur: _lieu,
                        libelle: _estTrouve ? 'Lieu de découverte' : 'Lieu de la perte',
                        exemple: 'Ex. : Pavillon G, 2e étage',
                        icone: Icons.place_outlined,
                        surChangement: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final lieu in lieuxFrequents)
                            PuceChoix(
                              libelle: lieu,
                              choisie: _lieu.text == lieu,
                              onTap: () => setState(() => _lieu.text = lieu),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date : appui = calendrier (pas de saisie au clavier)
                      ChampFormulaire(
                        controleur: _date,
                        libelle: _estTrouve ? 'Trouvé le' : 'Perdu le',
                        icone: Icons.calendar_today_outlined,
                        lectureSeule: true,
                        surAppui: _choisirDate,
                        suffixe: const Icon(Icons.expand_more, color: Couleurs.texteDiscret),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---------- 4. Détails ----------
                  SectionFormulaire(
                    titre: 'Détails',
                    icone: Icons.notes_outlined,
                    children: [
                      // Uniquement pour un objet trouvé : où est-il maintenant ?
                      if (_estTrouve) ...[
                        const TitreChamp("Où est l'objet maintenant ?"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in emplacements)
                              PuceChoix(
                                libelle: e,
                                choisie: _emplacement == e,
                                onTap: () => setState(() => _emplacement = e),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      ChampFormulaire(
                        controleur: _description,
                        libelle: 'Description',
                        exemple: 'Couleur, marque, signe particulier…',
                        lignes: 3,
                        obligatoire: false,
                      ),
                      // Conseil (objet trouvé seulement)
                      if (_estTrouve) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Couleurs.beigeClair,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Couleurs.marron, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Ne dites pas tout : gardez un détail pour vous. "
                                  "Il servira à vérifier le vrai propriétaire.",
                                  style: TextStyle(
                                      color: Couleurs.marron, fontSize: 13, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
      // Bouton toujours visible en bas de l'écran
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Couleurs.bordure)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: BoutonPrincipal(
              texte: _modification ? 'Enregistrer' : "Publier l'annonce",
              icone: _modification ? Icons.check : Icons.send_outlined,
              onPressed: _publier,
            ),
          ),
        ),
      ),
    );
  }

  /// En-tête coloré : retour, titre et phrase d'encouragement.
  Widget _enTete(List<Color> couleurs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: couleurs,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Retour',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _modification
                          ? "Modifier l'annonce"
                          : (_estTrouve ? "J'ai trouvé un objet" : "J'ai perdu un objet"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _estTrouve
                          ? 'Merci ! Quelques infos et son propriétaire pourra le retrouver.'
                          : 'Plus votre annonce est précise, plus vite on vous le rapporte.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
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
          height: _photo == null ? 130 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Couleurs.beige, width: 1.5),
          ),
          child: _photo == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.add_a_photo_outlined,
                          color: Couleurs.marron, size: 26),
                    ),
                    SizedBox(height: 10),
                    Text('Ajouter une photo',
                        style: TextStyle(
                            color: Couleurs.marron, fontWeight: FontWeight.w600)),
                    Text("Facultatif : sans photo, l'image de la catégorie s'affiche",
                        style: TextStyle(color: Couleurs.texteDiscret, fontSize: 12)),
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
}
