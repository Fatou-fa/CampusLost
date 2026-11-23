import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/couleurs.dart';
import '../utils/actions.dart';

/// Une conversation : bulles de messages, zone de saisie, et en haut
/// l'appel téléphonique et le menu (voir l'annonce, signaler, bloquer).
///
/// Les deux moyens de contact restent au choix de l'utilisateur :
/// écrire ici, ou appeler (le numéro n'est jamais affiché).
class ConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String texteInitial; // message pré-rempli (ex. « Je l'ai trouvé »)

  const ConversationScreen({
    super.key,
    required this.conversationId,
    this.texteInitial = '',
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late final TextEditingController _saisie;

  @override
  void initState() {
    super.initState();
    _saisie = TextEditingController(text: widget.texteInitial);
    // On marque les messages comme lus juste APRÈS l'affichage :
    // Riverpod interdit de modifier un provider pendant la construction.
    Future.microtask(_marquerLus);
  }

  @override
  void dispose() {
    _saisie.dispose();
    super.dispose();
  }

  void _marquerLus() {
    final moi = ref.read(authProvider);
    if (moi == null || !mounted) return;
    ref.read(conversationsProvider.notifier).marquerLus(widget.conversationId, moi.id);
  }

  void _envoyer() {
    final texte = _saisie.text.trim();
    final moi = ref.read(authProvider);
    if (texte.isEmpty || moi == null) return;
    ref.read(conversationsProvider.notifier).envoyer(widget.conversationId, moi.id, texte);
    _saisie.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(conversationParIdProvider(widget.conversationId));
    final moi = ref.watch(authProvider);
    if (c == null || moi == null) {
      return const Scaffold(body: Center(child: Text('Conversation introuvable')));
    }

    // Nouveaux messages reçus pendant que l'écran est ouvert : on les lit
    ref.listen(conversationParIdProvider(widget.conversationId), (_, _) {
      Future.microtask(_marquerLus);
    });

    final telephone = c.autreTelephone(moi.id);
    final jaiBloque = c.bloqueePar == moi.id;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Couleurs.beige,
              child: Text(
                initiales(c.autreNom(moi.id)),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.autreNom(moi.id),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(c.annonceTitre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Couleurs.marron)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Appel téléphonique, au choix de l'utilisateur
          if (telephone.isNotEmpty && !c.estBloquee)
            IconButton(
              tooltip: 'Appeler',
              onPressed: () => appeler(context, telephone),
              icon: const Icon(Icons.phone_outlined, color: Couleurs.marron),
            ),
          PopupMenuButton<String>(
            onSelected: (choix) => _menu(choix, c, moi.id),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'annonce', child: Text("Voir l'annonce")),
              const PopupMenuItem(value: 'signaler', child: Text('Signaler cette personne')),
              if (!c.estBloquee)
                const PopupMenuItem(value: 'bloquer', child: Text('Bloquer'))
              else if (jaiBloque)
                const PopupMenuItem(value: 'debloquer', child: Text('Débloquer')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Rappel de sécurité, toujours visible
          Container(
            width: double.infinity,
            color: Couleurs.beigeClair,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 18, color: Couleurs.marron),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Rendez-vous dans un lieu public du campus. "
                    "Ne payez jamais pour récupérer un objet.",
                    style: TextStyle(fontSize: 12, color: Couleurs.marron),
                  ),
                ),
              ],
            ),
          ),

          // Messages : reverse = le plus récent en bas, près de la saisie
          Expanded(
            child: c.messages.isEmpty
                ? const Center(
                    child: Text('Écrivez le premier message.',
                        style: TextStyle(color: Couleurs.texteDiscret)),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: c.messages.length,
                    itemBuilder: (context, index) {
                      final m = c.messages[c.messages.length - 1 - index];
                      return _bulle(m, m.auteurId == moi.id);
                    },
                  ),
          ),

          // Zone de saisie, ou message si la conversation est bloquée
          c.estBloquee ? _bandeauBloque(jaiBloque) : _zoneSaisie(),
        ],
      ),
    );
  }

  /// Bulle de message : à droite et marron pour moi, à gauche et blanche
  /// pour l'autre personne.
  Widget _bulle(Message m, bool deMoi) {
    return Align(
      alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: deMoi ? Couleurs.marron : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(deMoi ? 18 : 4),
            bottomRight: Radius.circular(deMoi ? 4 : 18),
          ),
          border: deMoi ? null : Border.all(color: Couleurs.bordure),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m.texte,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: deMoi ? Colors.white : Couleurs.texte,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              heureCourte(m.heure),
              style: TextStyle(
                fontSize: 11,
                color: deMoi
                    ? Colors.white.withValues(alpha: 0.75)
                    : Couleurs.texteDiscret,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoneSaisie() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _saisie,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Votre message…',
                    filled: true,
                    fillColor: Couleurs.fond,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Envoyer',
                onPressed: _envoyer,
                style: IconButton.styleFrom(backgroundColor: Couleurs.marron),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bandeauBloque(bool jaiBloque) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            jaiBloque
                ? 'Vous avez bloqué cette personne. Débloquez-la (menu ⋮) pour lui écrire.'
                : 'Cette conversation a été fermée par votre interlocuteur.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Couleurs.texteDiscret),
          ),
        ),
      ),
    );
  }

  Future<void> _menu(String choix, Conversation c, String moiId) async {
    final conversations = ref.read(conversationsProvider.notifier);
    switch (choix) {
      case 'annonce':
        context.push(Routes.detail(c.annonceId));
      case 'signaler':
        // On signale la personne (l'autre participant)
        await signaler(context, ref,
            cible: 'personne',
            cibleId: moiId == c.proprietaireId ? c.visiteurId : c.proprietaireId);
      case 'bloquer':
        final ok = await confirmer(
          context,
          titre: 'Bloquer ${c.autreNom(moiId)} ?',
          message: 'Vous ne pourrez plus vous écrire ni vous appeler depuis '
              'cette conversation.',
          action: 'Bloquer',
          danger: true,
        );
        if (ok) conversations.bloquer(c.id, moiId);
      case 'debloquer':
        conversations.debloquer(c.id);
    }
  }
}
