import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/routes.dart';
import '../providers/auth_provider.dart';
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

/// Propose SMS ou WhatsApp, avec un message déjà rédigé.
Future<void> envoyerMessage(
    BuildContext context, String telephone, String message) async {
  final numero = telephone.replaceAll(' ', '');
  final texte = Uri.encodeComponent(message);

  await showModalBottomSheet(
    context: context,
    backgroundColor: Couleurs.fond,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (feuille) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Envoyer un message',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Couleurs.marronFonce,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.sms_outlined, color: Couleurs.marron),
            title: const Text('SMS'),
            onTap: () {
              Navigator.pop(feuille);
              _ouvrir(context, Uri.parse('sms:$numero?body=$texte'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined, color: Couleurs.marron),
            title: const Text('WhatsApp'),
            onTap: () {
              Navigator.pop(feuille);
              // 221 : indicatif du Sénégal
              _ouvrir(context, Uri.parse('https://wa.me/221$numero?text=$texte'));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
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
Future<void> confirmerDeconnexion(BuildContext context) async {
  // On garde le navigateur et le provider avant les « await » :
  // l'écran peut disparaître pendant l'attente.
  final navigateur = Navigator.of(context, rootNavigator: true);
  final auth = context.read<AuthProvider>();

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
  navigateur.pushNamedAndRemoveUntil(Routes.bienvenue, (_) => false);
}
