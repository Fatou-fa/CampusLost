import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../models/annonce_model.dart';
import '../models/reclamation_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reclamation_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/champs_formulaire.dart';
import '../widgets/photo_annonce.dart';

/// Détail d'une annonce : grande photo, informations, description, personne
/// qui l'a publiée, et en bas l'action qui correspond à la situation :
///  - mon annonce       → Modifier / Marquer restitué ;
///  - objet trouvé      → « C'est à moi » (réclamation) ;
///  - objet perdu       → « Je l'ai trouvé » (message au propriétaire) ;
///  - objet restitué    → simple information.
class DetailAnnonceScreen extends ConsumerWidget {
  /// Id de l'annonce, lu dans l'adresse (/annonce/3) par go_router.
  final int annonceId;

  const DetailAnnonceScreen({super.key, required this.annonceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Version à jour de l'annonce (elle a pu être modifiée ou restituée)
    final a = ref.watch(annonceParIdProvider(annonceId));
    if (a == null) return _introuvable(context);

    final moi = ref.watch(authProvider);
    final estAMoi = moi != null && moi.id == a.auteurId;
    final maReclamation = ref.watch(maReclamationSurProvider(a.id));

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _photo(context, a),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Titre et lieu ----------
                Text(
                  a.titre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.marronFonce,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: Couleurs.texteDiscret),
                    const SizedBox(width: 4),
                    Text(
                      a.lieu,
                      style: const TextStyle(
                          fontSize: 15, color: Couleurs.texteDiscret),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------- Catégorie et date, côte à côte ----------
                Row(
                  children: [
                    Expanded(
                      child: _info(Icons.sell_outlined, 'Catégorie',
                          a.categorie),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _info(Icons.calendar_today_outlined,
                          a.estPerdue ? 'Perdu le' : 'Trouvé le',
                          a.date),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Description ----------
                _carte(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Couleurs.marronFonce,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.description.isEmpty
                            ? 'Aucune description.'
                            : a.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: Couleurs.texte,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Personne qui a publié ----------
                _carte(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Couleurs.beige,
                        child: Text(
                          initiales(a.auteurNom),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Couleurs.marronFonce,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estAMoi ? 'Vous' : a.auteurNom,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Couleurs.texte,
                              ),
                            ),
                            Text(
                              a.estPerdue ? "A perdu l'objet" : "A trouvé l'objet",
                              style: const TextStyle(
                                  fontSize: 13, color: Couleurs.texteDiscret),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- Contacter l'auteur : écrire OU appeler ----------
                // (au choix ; le numéro n'est jamais affiché)
                if (!estAMoi) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _boutonContact(
                          Icons.chat_bubble_outline,
                          'Écrire',
                          () => ecrireA(context, ref, annonce: a),
                        ),
                      ),
                      if (a.auteurTelephone.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _boutonContact(
                            Icons.phone_outlined,
                            'Appeler',
                            () => appeler(context, a.auteurTelephone),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // ---------- Conseil (objet trouvé, pas à moi) ----------
                if (!a.estPerdue && !estAMoi && !a.estRestituee) ...[
                  const SizedBox(height: 16),
                  _conseil(
                    Icons.verified_user_outlined,
                    "C'est à vous ? Touchez « C'est à moi » et donnez un détail "
                    "que seul le propriétaire connaît : la personne qui l'a trouvé pourra "
                    "vérifier que l'objet vous appartient.",
                  ),
                ],

                // ---------- Signaler une annonce abusive ----------
                if (!estAMoi) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          signaler(context, ref, cible: 'annonce', cibleId: a.id),
                      style: TextButton.styleFrom(
                          foregroundColor: Couleurs.texteDiscret),
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Signaler cette annonce'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      // Action principale, toujours visible en bas de l'écran
      bottomNavigationBar: _barreAction(context, ref, a, estAMoi, maReclamation),
    );
  }

  // =====================================================================
  //  Barre d'action du bas
  // =====================================================================

  Widget _barreAction(BuildContext context, WidgetRef ref, Annonce a,
      bool estAMoi, Reclamation? maReclamation) {
    Widget contenu;

    if (a.estRestituee) {
      contenu = _conseil(
        Icons.task_alt,
        a.estPerdue
            ? 'Bonne nouvelle : son propriétaire l\'a retrouvé.'
            : 'Cet objet a été rendu à son propriétaire.',
      );
    } else if (estAMoi) {
      contenu = Row(
        children: [
          Expanded(
            child: _boutonSecondaire(
              Icons.edit_outlined,
              'Modifier',
              () => context.push(Routes.modifierAnnonce(a.id)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _boutonPrincipal(
              Icons.check,
              a.estPerdue ? "Je l'ai retrouvé" : 'Objet rendu',
              () => _marquerRestituee(context, ref, a),
            ),
          ),
        ],
      );
    } else if (!a.estPerdue) {
      // Objet trouvé par quelqu'un d'autre
      if (maReclamation == null) {
        contenu = _boutonPrincipal(
          Icons.back_hand_outlined,
          "C'est à moi",
          () => _ouvrirReclamation(context, a),
        );
      } else {
        final texte = maReclamation.estAcceptee
            ? "Demande acceptée ! Appelez la personne qui l'a trouvé pour "
                'récupérer votre objet.'
            : maReclamation.estRefusee
                ? "Votre demande n'a pas été acceptée."
                : "Demande envoyée. La personne qui l'a trouvé va vous répondre "
                    '(voir l\'onglet « Demandes »).';
        contenu = _conseil(Icons.inbox_outlined, texte);
      }
    } else {
      // Objet perdu par quelqu'un d'autre : je l'ai peut-être trouvé
      contenu = _boutonPrincipal(
        Icons.volunteer_activism_outlined,
        "Je l'ai trouvé",
        // Ouvre la conversation avec un premier message déjà écrit
        () => ecrireA(
              context,
              ref,
              annonce: a,
              texte: 'Bonjour, je crois avoir trouvé votre « ${a.titre} ». '
                  'Où peut-on se retrouver sur le campus ?',
            ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Couleurs.bordure)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: contenu,
        ),
      ),
    );
  }

  Widget _boutonPrincipal(IconData icone, String texte, VoidCallback? action) {
    return ElevatedButton.icon(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: Couleurs.marron,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icone),
      label: Text(texte,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _boutonSecondaire(IconData icone, String texte, VoidCallback action) {
    return OutlinedButton.icon(
      onPressed: action,
      style: OutlinedButton.styleFrom(
        foregroundColor: Couleurs.marron,
        side: const BorderSide(color: Couleurs.marron, width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icone),
      label: Text(texte,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _marquerRestituee(
      BuildContext context, WidgetRef ref, Annonce a) async {
    final annonces = ref.read(annoncesProvider.notifier);
    final messager = ScaffoldMessenger.of(context);
    final ok = await confirmer(
      context,
      titre: a.estPerdue
          ? 'Vous avez retrouvé votre objet ?'
          : 'Objet rendu à son propriétaire ?',
      message: "L'annonce sera retirée de l'accueil et rangée dans "
          '« Mes annonces › Terminées ».',
      action: 'Confirmer',
    );
    if (!ok) return;
    annonces.marquerRestituee(a.id);
    messager.showSnackBar(
        const SnackBar(content: Text('Bravo ! Annonce rangée dans « Terminées »')));
  }

  /// Ouvre la feuille « C'est à moi » (message + détail de preuve).
  void _ouvrirReclamation(BuildContext context, Annonce a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // la feuille remonte au-dessus du clavier
      backgroundColor: Couleurs.fond,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FeuilleReclamation(annonce: a),
    );
  }

  // =====================================================================
  //  Blocs d'affichage
  // =====================================================================

  /// Grande photo de l'objet sur fond beige, avec le bouton retour
  /// et le badge Perdu / Trouvé / Restitué.
  Widget _photo(BuildContext context, Annonce a) {
    final badge = a.estRestituee
        ? (a.estPerdue ? 'Retrouvé' : 'Rendu')
        : (a.estPerdue ? 'Perdu' : 'Trouvé');
    final fondBadge = a.estPerdue ? Colors.white : Couleurs.marron;
    final texteBadge = a.estPerdue ? Couleurs.marron : Colors.white;

    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Couleurs.beigeTrouve,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Photo centrée, en grand
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PhotoAnnonce(
                      chemin: a.photoUrl, hauteur: 240, tailleIcone: 120),
                ),
              ),
            ),
            // Bouton retour (seulement s'il y a un écran précédent)
            if (context.canPop())
              Positioned(
                left: 12,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Couleurs.marron),
                    tooltip: 'Retour',
                  ),
                ),
              ),
            // Badge en haut à droite
            Positioned(
              right: 20,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: fondBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontWeight: FontWeight.bold, color: texteBadge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Affiché si l'annonce n'existe plus (supprimée entre-temps).
  Widget _introuvable(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(backgroundColor: Couleurs.fond),
      body: const Center(
        child: Text("Cette annonce n'existe plus.",
            style: TextStyle(color: Couleurs.texteDiscret)),
      ),
    );
  }

  /// Encadré beige avec une icône et un texte.
  Widget _conseil(IconData icone, String texte) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Couleurs.beigeClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: Couleurs.marron, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(fontSize: 13, color: Couleurs.marron, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  /// Petite carte blanche : icône, libellé et valeur.
  Widget _info(IconData icone, String libelle, String valeur) {
    return _carte(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Couleurs.beigeTrouve,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 20, color: Couleurs.marron),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(libelle,
                    style: const TextStyle(
                        fontSize: 12, color: Couleurs.texteDiscret)),
                Text(
                  valeur,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Couleurs.texte,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fond blanc arrondi avec une ombre douce, réutilisé par plusieurs blocs.
  Widget _carte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Couleurs.marronFonce.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Bouton de contact (Écrire / Appeler) avec une icône et un libellé.
  Widget _boutonContact(IconData icone, String texte, VoidCallback action) {
    return OutlinedButton.icon(
      onPressed: action,
      style: OutlinedButton.styleFrom(
        foregroundColor: Couleurs.marron,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Couleurs.bordure),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icone, size: 20),
      label: Text(texte, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Feuille « C'est à moi » : message et détail de preuve.
class _FeuilleReclamation extends ConsumerStatefulWidget {
  final Annonce annonce;
  const _FeuilleReclamation({required this.annonce});

  @override
  ConsumerState<_FeuilleReclamation> createState() => _FeuilleReclamationState();
}

class _FeuilleReclamationState extends ConsumerState<_FeuilleReclamation> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  final _detail = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _envoyer() {
    if (!_formKey.currentState!.validate()) return;
    final moi = ref.read(authProvider);
    if (moi == null) return;

    ref.read(reclamationsProvider.notifier).reclamer(
          annonceId: widget.annonce.id,
          annonceTitre: widget.annonce.titre,
          demandeurId: moi.id,
          demandeurNom: '${majuscule(moi.prenom)} ${moi.nom.isEmpty ? '' : '${moi.nom[0].toUpperCase()}.'}'.trim(),
          demandeurTelephone: moi.telephone,
          message: _message.text.trim(),
          detail: _detail.text.trim(),
        );

    final messager = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messager.showSnackBar(const SnackBar(
      content: Text('Demande envoyée ! La réponse arrivera dans « Demandes ».'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom = hauteur du clavier : la feuille remonte au-dessus
    final clavier = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + clavier),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "« ${widget.annonce.titre} » est à vous ?",
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Couleurs.marronFonce,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "La personne qui l'a trouvé vérifiera votre détail avant de vous répondre.",
              style: TextStyle(color: Couleurs.texteDiscret),
            ),
            const SizedBox(height: 18),
            ChampFormulaire(
              controleur: _detail,
              libelle: 'Un détail que seul le propriétaire connaît',
              exemple: 'Ex. : porte-clés rouge, initiales gravées…',
              icone: Icons.key_outlined,
              validation: (v) => (v == null || v.trim().length < 4)
                  ? 'Donnez un détail précis'
                  : null,
            ),
            const SizedBox(height: 14),
            ChampFormulaire(
              controleur: _message,
              libelle: 'Message',
              exemple: "Ex. : je l'ai perdu mardi en sortant du cours…",
              lignes: 3,
              obligatoire: false,
            ),
            const SizedBox(height: 20),
            BoutonPrincipal(
              texte: 'Envoyer ma demande',
              icone: Icons.send_outlined,
              onPressed: _envoyer,
            ),
          ],
        ),
      ),
    );
  }
}
