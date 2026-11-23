import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';
import '../widgets/photo_annonce.dart';

/// Liste de mes conversations, la plus récente en haut.
/// Ouvert depuis l'icône « Messages » de l'accueil ou depuis le Profil.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(mesConversationsProvider);
    final moiId = ref.watch(authProvider)?.id ?? 0;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: const Text(
          'Messages',
          style: TextStyle(color: Couleurs.marronFonce, fontWeight: FontWeight.bold),
        ),
      ),
      body: conversations.isEmpty
          ? const _AucuneConversation()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ligne(context, conversations[index], moiId),
            ),
    );
  }

  /// Une conversation : photo de l'objet, nom, aperçu du dernier message.
  Widget _ligne(BuildContext context, Conversation c, int moiId) {
    final nonLus = c.nonLus(moiId);
    final dernier = c.dernier;
    final apercu = dernier == null
        ? 'Nouvelle conversation'
        : '${dernier.auteurId == moiId ? 'Vous : ' : ''}${dernier.texte}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(Routes.conversation(c.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo de l'objet avec les initiales de l'autre personne
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Couleurs.beigeTrouve,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: PhotoAnnonce(chemin: c.annoncePhoto, tailleIcone: 24),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Couleurs.beige,
                        child: Text(
                          initiales(c.autreNom(moiId)),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Couleurs.marronFonce,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.autreNom(moiId),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Couleurs.texte,
                      ),
                    ),
                    Text(
                      c.annonceTitre,
                      style: const TextStyle(fontSize: 12, color: Couleurs.marron),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.estBloquee ? 'Conversation bloquée' : apercu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: nonLus > 0 ? Couleurs.texte : Couleurs.texteDiscret,
                        fontWeight: nonLus > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Heure du dernier message et nombre de non lus
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (dernier != null)
                    Text(heureCourte(dernier.heure),
                        style: const TextStyle(
                            fontSize: 12, color: Couleurs.texteDiscret)),
                  const SizedBox(height: 6),
                  if (nonLus > 0)
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: const Color(0xFFC8553D),
                      child: Text('$nonLus',
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Message affiché quand il n'y a encore aucune conversation.
class _AucuneConversation extends StatelessWidget {
  const _AucuneConversation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 56, color: Couleurs.beige),
            SizedBox(height: 12),
            Text(
              "Aucun message pour l'instant.\nOuvrez une annonce et touchez "
              "« Écrire » pour discuter avec son auteur, sans partager "
              'votre numéro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Couleurs.texteDiscret, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
