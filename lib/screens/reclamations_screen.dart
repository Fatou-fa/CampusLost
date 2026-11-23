import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../models/reclamation_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/reclamation_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';

/// Onglet « Réclamations » (design de Gilbert).
///
///  - Reçues : les personnes qui disent être propriétaires d'un objet que
///    j'ai publié. Je compare le détail donné, puis j'accepte ou je refuse.
///  - Envoyées : mes propres demandes et leur réponse.
class ReclamationsScreen extends ConsumerStatefulWidget {
  const ReclamationsScreen({super.key});

  @override
  ConsumerState<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends ConsumerState<ReclamationsScreen> {
  int _ongletActif = 0; // 0 = Reçues, 1 = Envoyées

  // Couleurs des statuts
  static const vertFond = Color(0xFFE3F3EA);
  static const vertTexte = Color(0xFF1F6E43);
  static const rougeFond = Color(0xFFFBEAE5);
  static const rougeTexte = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    // Listes calculées par Riverpod (voir reclamation_provider.dart)
    final recues = ref.watch(reclamationsRecuesProvider);
    final envoyees = ref.watch(reclamationsEnvoyeesProvider);
    final affichees = _ongletActif == 0 ? recues : envoyees;
    final enAttente = recues.where((r) => r.estEnAttente).length;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demandes',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _ongletActif == 0
                    ? 'Des personnes pensent que les objets que vous avez '
                        'trouvés sont à elles. Vérifiez leur détail, puis répondez.'
                    : "Les objets que vous avez demandé à récupérer, et la réponse.",
                style: const TextStyle(
                  fontSize: 14,
                  color: Couleurs.texteDiscret,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Sélecteur Reçues / Envoyées
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Couleurs.beigeTrouve,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _onglet(0, enAttente > 0
                        ? 'Reçues ($enAttente à traiter)'
                        : 'Reçues (${recues.length})'),
                    _onglet(1, 'Mes demandes (${envoyees.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: affichees.isEmpty
                    ? _listeVide()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: affichees.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            _carte(affichees[index], recue: _ongletActif == 0),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onglet(int index, String titre) {
    final estActif = _ongletActif == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _ongletActif = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: estActif ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: estActif ? FontWeight.bold : FontWeight.w500,
              color: estActif ? Couleurs.marronFonce : Couleurs.texteDiscret,
            ),
          ),
        ),
      ),
    );
  }

  Widget _listeVide() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 56, color: Couleurs.beige),
          const SizedBox(height: 12),
          Text(
            _ongletActif == 0
                ? "Aucune demande pour l'instant.\nElles arrivent ici quand "
                    "quelqu'un reconnaît un objet que vous avez trouvé."
                : "Vous n'avez rien demandé.\nVous reconnaissez un objet ? "
                    "Ouvrez son annonce et touchez « C'est à moi ».",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Couleurs.texteDiscret, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Carte d'une réclamation. [recue] : vrai pour l'onglet « Reçues ».
  Widget _carte(Reclamation r,
      {required bool recue}) {
    // Badge selon le statut
    final String badge;
    final Color fondBadge;
    final Color texteBadge;
    if (r.estAcceptee) {
      badge = 'ACCEPTÉE';
      fondBadge = vertFond;
      texteBadge = vertTexte;
    } else if (r.estRefusee) {
      badge = 'REFUSÉE';
      fondBadge = rougeFond;
      texteBadge = rougeTexte;
    } else {
      badge = 'EN ATTENTE';
      fondBadge = Couleurs.beigeClair;
      texteBadge = Couleurs.marron;
    }

    // Reçue : on voit le demandeur. Envoyée : on voit l'auteur de l'annonce.
    final annonce = ref.watch(annonceParIdProvider(r.annonceId));
    final nom = recue ? r.demandeurNom : (annonce?.auteurNom ?? 'Annonce supprimée');
    final telephone = recue ? r.demandeurTelephone : (annonce?.auteurTelephone ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : initiales, nom, objet et badge de statut
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: r.estEnAttente ? Couleurs.beige : Couleurs.beigeTrouve,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initiales(nom),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Couleurs.texte,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Couleurs.texte,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.date} · ${r.annonceTitre}',
                      style: const TextStyle(
                          fontSize: 12, color: Couleurs.texteDiscret),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fondBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: texteBadge,
                  ),
                ),
              ),
            ],
          ),

          // Message du demandeur
          if (r.message.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '« ${r.message} »',
              style: const TextStyle(fontSize: 14, color: Couleurs.texte, height: 1.4),
            ),
          ],

          // Détail de preuve (visible seulement par celui qui a publié)
          if (recue && r.detail.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Couleurs.fond,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: Couleurs.texte),
                  children: [
                    const TextSpan(
                      text: 'Détail donné : ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: r.detail),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Boutons selon la situation
          if (recue && r.estEnAttente)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _refuser(r),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Couleurs.texte,
                      side: const BorderSide(color: Couleurs.bordure),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _accepter(r),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Couleurs.marron,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accepter'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                // Voir l'annonce concernée
                if (annonce != null)
                  TextButton.icon(
                    onPressed: () => context.push(Routes.detail(annonce.id)),
                    style: TextButton.styleFrom(foregroundColor: Couleurs.marron),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text("Voir l'annonce"),
                  ),
                const Spacer(),
                // Une fois acceptée : on se contacte pour la remise de
                // l'objet, en écrivant dans l'app OU en appelant
                if (r.estAcceptee && annonce != null) ...[
                  IconButton.filledTonal(
                    tooltip: 'Écrire',
                    onPressed: () => ecrireA(
                      context,
                      ref,
                      annonce: annonce,
                      // Reçue : j'ai publié l'annonce, j'écris au demandeur
                      interlocuteurId: recue ? r.demandeurId : null,
                      interlocuteurNom: r.demandeurNom,
                      interlocuteurTelephone: r.demandeurTelephone,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                  ),
                  if (telephone.isNotEmpty)
                    IconButton.filledTonal(
                      tooltip: 'Appeler',
                      onPressed: () => appeler(context, telephone),
                      icon: const Icon(Icons.phone_outlined),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _accepter(Reclamation r) async {
    final reclamations = ref.read(reclamationsProvider.notifier);
    final annonces = ref.read(annoncesProvider.notifier);
    final messager = ScaffoldMessenger.of(context);
    final ok = await confirmer(
      context,
      titre: "C'est bien à ${r.demandeurNom} ?",
      message: 'Vous confirmez que « ${r.annonceTitre} » appartient à '
          '${r.demandeurNom}. Vous pourrez ensuite l\'appeler pour lui rendre '
          "l'objet. Les autres demandes sur cet objet seront refusées.",
      action: 'Oui, accepter',
    );
    if (!ok) return;
    reclamations.accepter(r.id);
    annonces.marquerRestituee(r.annonceId);
    messager.showSnackBar(SnackBar(
      content: Text('Appelez ${r.demandeurNom} pour lui rendre l\'objet'),
    ));
  }

  Future<void> _refuser(Reclamation r) async {
    final reclamations = ref.read(reclamationsProvider.notifier);
    final ok = await confirmer(
      context,
      titre: 'Refuser cette demande ?',
      message: 'Le détail donné par ${r.demandeurNom} ne correspond pas à l\'objet ?',
      action: 'Refuser',
      danger: true,
    );
    if (ok) reclamations.refuser(r.id);
  }
}
