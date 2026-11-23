import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../models/annonce_model.dart';
import '../providers/annonce_provider.dart';
import '../providers/reclamation_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/photo_annonce.dart';

/// Onglet « Mes annonces » (design de Gilbert) : les annonces publiées par
/// l'utilisateur connecté, en deux listes « En cours » et « Restituées ».
/// Actions : ouvrir, modifier, marquer comme restituée, supprimer.
class MesAnnoncesScreen extends ConsumerStatefulWidget {
  const MesAnnoncesScreen({super.key});

  @override
  ConsumerState<MesAnnoncesScreen> createState() => _MesAnnoncesScreenState();
}

class _MesAnnoncesScreenState extends ConsumerState<MesAnnoncesScreen> {
  // 0 = En cours, 1 = Restituées
  int _ongletActif = 0;

  @override
  Widget build(BuildContext context) {
    // Annonces de l'utilisateur connecté, recalculées automatiquement
    final mesAnnonces = ref.watch(mesAnnoncesProvider);
    final reclamations = ref.watch(reclamationsProvider);

    final enCours = mesAnnonces.where((a) => !a.estRestituee).toList();
    final restituees = mesAnnonces.where((a) => a.estRestituee).toList();
    final affichees = _ongletActif == 0 ? enCours : restituees;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mes annonces',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 6),
              const Text(
                'Les objets que vous avez signalés, perdus ou trouvés.',
                style: TextStyle(fontSize: 14, color: Couleurs.texteDiscret),
              ),
              // Sélecteur d'onglets (En cours / Terminées)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Couleurs.beigeTrouve,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _onglet(0, 'En cours (${enCours.length})'),
                    _onglet(1, 'Terminées (${restituees.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Liste des annonces, ou message si elle est vide
              Expanded(
                child: affichees.isEmpty
                    ? _listeVide()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: affichees.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final annonce = affichees[index];
                          // Nombre de réclamations en attente sur cette annonce
                          final enAttente = reclamations
                              .where((r) =>
                                  r.annonceId == annonce.id && r.estEnAttente)
                              .length;
                          return _carte(annonce, enAttente);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton d'onglet (En cours ou Restituées).
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
            boxShadow: estActif
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: estActif ? FontWeight.bold : FontWeight.w500,
              color: estActif ? Couleurs.marronFonce : Couleurs.texteDiscret,
            ),
          ),
        ),
      ),
    );
  }

  /// Message affiché quand la liste est vide.
  Widget _listeVide() {
    final enCours = _ongletActif == 0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(enCours ? Icons.inventory_2_outlined : Icons.task_alt,
              size: 56, color: Couleurs.beige),
          const SizedBox(height: 12),
          Text(
            enCours
                ? "Vous n'avez aucune annonce en cours."
                : "Aucune annonce terminée pour l'instant.\n"
                  "Quand un objet est rendu ou retrouvé, l'annonce arrive ici.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Couleurs.texteDiscret, fontSize: 15),
          ),
          if (enCours) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.publier),
              style: ElevatedButton.styleFrom(
                backgroundColor: Couleurs.marron,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Publier une annonce'),
            ),
          ],
        ],
      ),
    );
  }

  /// Carte d'une de mes annonces, avec ses boutons d'action.
  Widget _carte(Annonce annonce, int reclamationsEnAttente) {
    final estPerdu = annonce.estPerdue;
    var details = '${annonce.lieu} · ${annonce.date}';
    if (reclamationsEnAttente > 0) {
      details += ' · $reclamationsEnAttente demande'
          '${reclamationsEnAttente > 1 ? 's' : ''} à traiter';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            context.push(Routes.detail(annonce.id)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Couleurs.bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo de l'objet
                  Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Couleurs.beigeTrouve,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: PhotoAnnonce(chemin: annonce.photoUrl, tailleIcone: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge PERDU / TROUVÉ
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: estPerdu
                                ? Couleurs.beigeClair
                                : Couleurs.beigeTrouve,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estPerdu ? 'PERDU' : 'TROUVÉ',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Couleurs.marron,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          annonce.titre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Couleurs.texte,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          details,
                          style: TextStyle(
                            fontSize: 13,
                            color: reclamationsEnAttente > 0
                                ? Couleurs.marron
                                : Couleurs.texteDiscret,
                            fontWeight: reclamationsEnAttente > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu « ⋮ » : supprimer
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Couleurs.texteDiscret),
                    onSelected: (_) => _supprimer(annonce),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'supprimer',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                            SizedBox(width: 10),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Boutons d'action uniquement pour les annonces en cours
              if (!annonce.estRestituee) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _bouton(
                        Icons.edit_outlined,
                        'Modifier',
                        () => context.push(Routes.modifierAnnonce(annonce.id)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _bouton(
                        Icons.check,
                        estPerdu ? "Je l'ai retrouvé" : 'Objet rendu',
                        () => _marquerRestituee(annonce),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouton(IconData icone, String texte, VoidCallback action) {
    return OutlinedButton.icon(
      onPressed: action,
      style: OutlinedButton.styleFrom(
        foregroundColor: Couleurs.marron,
        side: const BorderSide(color: Couleurs.bordure),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      icon: Icon(icone, size: 17),
      label: Text(texte,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _marquerRestituee(Annonce annonce) async {
    final annonces = ref.read(annoncesProvider.notifier);
    final messager = ScaffoldMessenger.of(context);
    final ok = await confirmer(
      context,
      titre: annonce.estPerdue
          ? 'Vous avez retrouvé votre objet ?'
          : 'Objet rendu à son propriétaire ?',
      message: "L'annonce « ${annonce.titre} » ne sera plus visible sur "
          "l'accueil. Vous la retrouverez dans « Terminées ».",
      action: 'Confirmer',
    );
    if (!ok) return;
    annonces.marquerRestituee(annonce.id);
    messager.showSnackBar(
      const SnackBar(content: Text('Bravo ! Annonce rangée dans « Terminées »')),
    );
  }

  Future<void> _supprimer(Annonce annonce) async {
    final annonces = ref.read(annoncesProvider.notifier);
    final reclamations = ref.read(reclamationsProvider.notifier);
    final messager = ScaffoldMessenger.of(context);
    final ok = await confirmer(
      context,
      titre: "Supprimer l'annonce ?",
      message: "« ${annonce.titre} » sera définitivement supprimée.",
      action: 'Supprimer',
      danger: true,
    );
    if (!ok) return;
    annonces.supprimer(annonce.id);
    reclamations.supprimerPourAnnonce(annonce.id);
    messager.showSnackBar(const SnackBar(content: Text('Annonce supprimée')));
  }
}
