import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/routes.dart';
import '../models/annonce_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/couleurs.dart';

/// Petites actions réutilisées par plusieurs écrans.

/// Initiales d'un nom (« Moussa D. » → « MD »).
String initiales(String nom) {
  final mots = nom.trim().split(' ').where((m) => m.isNotEmpty).toList();
  if (mots.isEmpty) return '?';
  if (mots.length == 1) return mots.first[0].toUpperCase();
  return (mots[0][0] + mots[1][0]).toUpperCase();
}

/// Met la première lettre en majuscule (« fatou » → « Fatou »).
String majuscule(String mot) {
  if (mot.isEmpty) return mot;
  return mot[0].toUpperCase() + mot.substring(1);
}

/// Ouvre une application externe (téléphone, SMS, WhatsApp).
/// Affiche un message si aucune application ne peut l'ouvrir.
Future<void> _ouvrir(BuildContext context, Uri adresse) async {
  final messager = ScaffoldMessenger.of(context);
  bool ouvert = false;
  try {
    ouvert = await launchUrl(adresse, mode: LaunchMode.externalApplication);
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert) {
    messager.showSnackBar(
      const SnackBar(content: Text("Aucune application disponible pour cette action")),
    );
  }
}

/// Lance un appel téléphonique.
Future<void> appeler(BuildContext context, String telephone) {
  return _ouvrir(context, Uri(scheme: 'tel', path: telephone.replaceAll(' ', '')));
}

/// Heure courte d'un message : « 14:05 » aujourd'hui, sinon « 21/11 ».
String heureCourte(DateTime heure) {
  final maintenant = DateTime.now();
  String deux(int n) => n.toString().padLeft(2, '0');
  final memeJour = heure.year == maintenant.year &&
      heure.month == maintenant.month &&
      heure.day == maintenant.day;
  return memeJour
      ? '${deux(heure.hour)}:${deux(heure.minute)}'
      : '${deux(heure.day)}/${deux(heure.month)}';
}

/// Ouvre (ou crée) la conversation au sujet d'une annonce, puis l'affiche.
///
/// - Si je ne suis pas l'auteur de l'annonce : j'écris à l'auteur.
/// - Si je suis l'auteur : j'écris à la personne donnée par [interlocuteurId]
///   (par exemple celle qui a demandé à récupérer l'objet).
/// [texte] pré-remplit la zone de saisie.
void ecrireA(
  BuildContext context,
  WidgetRef ref, {
  required Annonce annonce,
  int? interlocuteurId,
  String interlocuteurNom = '',
  String interlocuteurTelephone = '',
  String texte = '',
}) {
  final moi = ref.read(authProvider);
  if (moi == null) return;
  final jeSuisAuteur = moi.id == annonce.auteurId;
  if (jeSuisAuteur && interlocuteurId == null) return;

  final monNom = '${majuscule(moi.prenom)} '
          '${moi.nom.isEmpty ? '' : '${moi.nom[0].toUpperCase()}.'}'
      .trim();

  final id = ref.read(conversationsProvider.notifier).ouvrir(
        annonceId: annonce.id,
        annonceTitre: annonce.titre,
        annoncePhoto: annonce.photoUrl,
        proprietaireId: annonce.auteurId,
        proprietaireNom: annonce.auteurNom,
        proprietaireTelephone: annonce.auteurTelephone,
        visiteurId: jeSuisAuteur ? interlocuteurId! : moi.id,
        visiteurNom: jeSuisAuteur ? interlocuteurNom : monNom,
        visiteurTelephone: jeSuisAuteur ? interlocuteurTelephone : moi.telephone,
      );
  context.push(Routes.conversation(id, texte: texte));
}

/// Signalement d'une annonce ou d'une personne : l'utilisateur choisit
/// un motif dans une liste, puis reçoit un message de confirmation.
Future<void> signaler(
  BuildContext context,
  WidgetRef ref, {
  required String cible, // "annonce" ou "personne"
  required int cibleId,
}) async {
  final moi = ref.read(authProvider);
  final messager = ScaffoldMessenger.of(context);
  const motifs = [
    "Tentative d'arnaque (argent demandé…)",
    'Fausse annonce',
    'Propos insultants ou déplacés',
    'Autre problème',
  ];

  final motif = await showDialog<String>(
    context: context,
    builder: (dialogue) => SimpleDialog(
      title: Text(cible == 'annonce' ? 'Signaler cette annonce' : 'Signaler cette personne'),
      children: [
        for (final m in motifs)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogue, m),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(m),
          ),
      ],
    ),
  );
  if (motif == null || moi == null) return;

  ref.read(signalementsProvider.notifier).signaler(
        cible: cible,
        cibleId: cibleId,
        motif: motif,
        auteurId: moi.id,
      );
  messager.showSnackBar(const SnackBar(
    content: Text('Merci. Le signalement sera vérifié par l\'équipe CampusLost.'),
  ));
}

/// Demande confirmation (retourne true si l'utilisateur accepte).
Future<bool> confirmer(
  BuildContext context, {
  required String titre,
  required String message,
  required String action,
  bool danger = false,
}) async {
  final reponse = await showDialog<bool>(
    context: context,
    builder: (dialogue) => AlertDialog(
      title: Text(titre),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogue, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogue, true),
          style: TextButton.styleFrom(
            foregroundColor: danger ? const Color(0xFFB3261E) : Couleurs.marron,
          ),
          child: Text(action),
        ),
      ],
    ),
  );
  return reponse == true;
}

/// Demande confirmation, ferme la session puis revient à l'écran Bienvenue.
/// [ref] vient du widget qui appelle (ConsumerWidget / ConsumerState).
Future<void> confirmerDeconnexion(BuildContext context, WidgetRef ref) async {
  // On garde le routeur et le notifier avant les « await » :
  // l'écran peut disparaître pendant l'attente.
  final routeur = GoRouter.of(context);
  final auth = ref.read(authProvider.notifier);

  final ok = await confirmer(
    context,
    titre: 'Se déconnecter ?',
    message: 'Vous devrez vous reconnecter pour publier ou contacter un étudiant.',
    action: 'Se déconnecter',
    danger: true,
  );
  if (!ok) return;

  await auth.deconnecter();
  // On vide la pile d'écrans : le bouton retour ne ramène pas à l'accueil
  routeur.go(Routes.bienvenue); // go : remplace toute la pile d'écrans
}
