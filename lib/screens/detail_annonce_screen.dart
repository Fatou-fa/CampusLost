import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../models/annonce_model.dart';
import '../models/reclamation_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reclamation_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/photo_annonce.dart';

/// Détail d'une annonce : grande photo, informations, description, personne
/// qui l'a publiée, et en bas l'action qui correspond à la situation :
///  - mon annonce       → Modifier / Marquer restitué ;
///  - objet trouvé      → « C'est à moi » (réclamation) ;
///  - objet perdu       → « Je l'ai trouvé » (message au propriétaire) ;
///  - objet restitué    → simple information.
class DetailAnnonceScreen extends StatelessWidget {
  final Annonce annonce;

  const DetailAnnonceScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    // Version à jour de l'annonce (elle a pu être modifiée ou restituée)
    final a = context.watch<AnnonceProvider>().parId(annonce.id) ?? annonce;
    final moi = context.watch<AuthProvider>().utilisateur;
    final estAMoi = moi != null && moi.id == a.auteurId;
    final maReclamation = moi == null
        ? null
        : context.watch<ReclamationProvider>().deUtilisateurSur(a.id, moi.id);

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
                      // Contacter l'auteur (pas soi-même)
                      if (!estAMoi && a.auteurTelephone.isNotEmpty) ...[
                        _pastille(
                          Icons.phone_outlined,
                          'Appeler',
                          () => appeler(context, a.auteurTelephone),
                        ),
                        const SizedBox(width: 8),
                        _pastille(
                          Icons.chat_outlined,
                          'Envoyer un message',
                          () => envoyerMessage(context, a.auteurTelephone,
                              'Bonjour, je vous contacte via CampusLost au sujet de « ${a.titre} ».'),
                        ),
                      ],
                    ],
                  ),
                ),

                // ---------- Conseil (objet trouvé, pas à moi) ----------
                if (!a.estPerdue && !estAMoi && !a.estRestituee) ...[
                  const SizedBox(height: 16),
                  _conseil(
                    Icons.verified_user_outlined,
                    "C'est à vous ? Touchez « C'est à moi » et donnez un détail "
                    "que seul le propriétaire connaît : le trouveur pourra "
                    "vérifier que l'objet vous appartient.",
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      // Action principale, toujours visible en bas de l'écran
      bottomNavigationBar: _barreAction(context, a, estAMoi, maReclamation),
    );
  }

  // =====================================================================
  //  Barre d'action du bas
  // =====================================================================

  Widget _barreAction(
      BuildContext context, Annonce a, bool estAMoi, Reclamation? maReclamation) {
    Widget contenu;

    if (a.estRestituee) {
      contenu = _conseil(Icons.task_alt, 'Cet objet a été rendu à son propriétaire.');
    } else if (estAMoi) {
      contenu = Row(
        children: [
          Expanded(
            child: _boutonSecondaire(
              Icons.edit_outlined,
              'Modifier',
              () => Navigator.pushNamed(context, Routes.formulaire, arguments: a),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _boutonPrincipal(
              Icons.check,
              a.estPerdue ? 'Retrouvé' : 'Restitué',
              () => _marquerRestituee(context, a),
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
            ? 'Réclamation acceptée : contactez le trouveur pour récupérer l\'objet.'
            : maReclamation.estRefusee
                ? 'Votre réclamation a été refusée.'
                : 'Réclamation envoyée : en attente de la réponse du trouveur.';
        contenu = _conseil(Icons.inbox_outlined, texte);
      }
    } else {
      // Objet perdu par quelqu'un d'autre : je l'ai peut-être trouvé
      contenu = _boutonPrincipal(
        Icons.volunteer_activism_outlined,
        "Je l'ai trouvé",
        a.auteurTelephone.isEmpty
            ? null
            : () => envoyerMessage(
                  context,
                  a.auteurTelephone,
                  'Bonjour, je crois avoir trouvé votre « ${a.titre} » '
                  '(annonce CampusLost). Où peut-on se retrouver ?',
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

  Future<void> _marquerRestituee(BuildContext context, Annonce a) async {
    final annonces = context.read<AnnonceProvider>();
    final messager = ScaffoldMessenger.of(context);
    final ok = await confirmer(
      context,
      titre: a.estPerdue ? 'Objet retrouvé ?' : 'Objet restitué ?',
      message: "L'annonce sera retirée de l'accueil et rangée dans "
          '« Mes annonces › Restituées ».',
      action: 'Confirmer',
    );
    if (!ok) return;
    annonces.marquerRestituee(a.id);
    messager.showSnackBar(
        const SnackBar(content: Text('Bravo ! Annonce rangée dans « Restituées »')));
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
    final badge = a.estRestituee ? 'Restitué' : (a.estPerdue ? 'Perdu' : 'Trouvé');
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
            if (Navigator.canPop(context))
              Positioned(
                left: 12,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
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

  /// Pastille ronde cliquable avec une icône de contact.
  Widget _pastille(IconData icone, String aide, VoidCallback action) {
    return Tooltip(
      message: aide,
      child: Material(
        color: Couleurs.beigeClair,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: action,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icone, size: 20, color: Couleurs.marron),
          ),
        ),
      ),
    );
  }
}

/// Feuille « C'est à moi » : message et détail de preuve.
class _FeuilleReclamation extends StatefulWidget {
  final Annonce annonce;
  const _FeuilleReclamation({required this.annonce});

  @override
  State<_FeuilleReclamation> createState() => _FeuilleReclamationState();
}

class _FeuilleReclamationState extends State<_FeuilleReclamation> {
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
    final moi = context.read<AuthProvider>().utilisateur;
    if (moi == null) return;

    context.read<ReclamationProvider>().reclamer(
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
      content: Text('Réclamation envoyée. Suivez la réponse dans « Réclamations ».'),
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
              'Le trouveur comparera votre détail avec l\'objet avant de répondre.',
              style: TextStyle(color: Couleurs.texteDiscret),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _detail,
              decoration: _style(
                'Détail de preuve',
                'Ex. : porte-clés rouge, initiales gravées…',
              ),
              validator: (v) => (v == null || v.trim().length < 4)
                  ? 'Donnez un détail précis'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _message,
              maxLines: 3,
              decoration: _style('Message (facultatif)',
                  'Ex. : je l\'ai perdu mardi en sortant du cours…'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _envoyer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Couleurs.marron,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.send_outlined),
              label: const Text('Envoyer la réclamation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _style(String libelle, String exemple) => InputDecoration(
        labelText: libelle,
        hintText: exemple,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
