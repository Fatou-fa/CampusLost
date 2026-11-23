import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../widgets/bouton_retour.dart';
import '../widgets/champs_formulaire.dart';

/// Écran 3 : création d'un compte.
///
/// L'utilisateur ne s'inscrit qu'une seule fois : ensuite, l'application
/// le garde connecté (voir AuthService).
class InscriptionScreen extends ConsumerStatefulWidget {
  const InscriptionScreen({super.key});

  @override
  ConsumerState<InscriptionScreen> createState() => _InscriptionScreenState();
}

// ConsumerState : comme State, avec en plus « ref » pour lire les providers
class _InscriptionScreenState extends ConsumerState<InscriptionScreen> {
  bool _enCours = false; // vrai pendant l'enregistrement

  // Clé du formulaire : permet de lancer la validation de tous les champs
  final _formKey = GlobalKey<FormState>();

  // Un contrôleur par champ pour lire le texte saisi
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();

  @override
  void dispose() {
    // Libère la mémoire des contrôleurs quand l'écran est fermé
    _prenom.dispose();
    _nom.dispose();
    _telephone.dispose();
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  /// Vérifie le formulaire, crée le compte puis ouvre l'accueil.
  Future<void> _creerCompte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enCours = true);
    final erreur = await ref.read(authProvider.notifier).inscrire(
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      email: _email.text.trim(),
      telephone: _telephone.text.trim(),
      motDePasse: _motDePasse.text,
    );
    if (!mounted) return; // l'écran a pu être fermé pendant l'attente
    setState(() => _enCours = false);

    if (erreur == null) {
      // go : remplace toute la pile, le retour ne ramène pas à l'inscription
      context.go(Routes.accueil);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      // Même présentation que l'écran de connexion de Gilbert
      // Flèche de retour vers l'écran de bienvenue
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        elevation: 0,
        leading: const BoutonRetour(),
      ),
      // SingleChildScrollView : le formulaire défile quand le clavier s'ouvre
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo carré marron foncé
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Couleurs.marronFonce,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: Couleurs.beige, size: 34),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Une seule fois : ensuite, l'application vous garde connecté(e).",
                style: TextStyle(fontSize: 15, color: Couleurs.texteDiscret, height: 1.4),
              ),
              const SizedBox(height: 28),

              // Prénom et nom côte à côte
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ChampFormulaire(
                      controleur: _prenom,
                      libelle: 'Prénom',
                      exemple: 'Awa',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChampFormulaire(
                      controleur: _nom,
                      libelle: 'Nom',
                      exemple: 'Ndiaye',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ChampFormulaire(
                controleur: _telephone,
                libelle: 'Téléphone',
                exemple: '77 000 00 00',
                icone: Icons.phone_outlined,
                clavier: TextInputType.phone,
                validation: _verifierTelephone,
              ),
              const SizedBox(height: 18),
              ChampFormulaire(
                controleur: _email,
                libelle: 'Email',
                exemple: 'prenom.nom@ugb.edu.sn',
                icone: Icons.mail_outline,
                clavier: TextInputType.emailAddress,
                validation: _verifierEmail,
              ),
              const SizedBox(height: 18),
              ChampFormulaire(
                controleur: _motDePasse,
                libelle: 'Mot de passe',
                exemple: '6 caractères minimum',
                icone: Icons.lock_outline,
                cache: true,
                validation: _verifierMotDePasse,
              ),
              const SizedBox(height: 28),

              BoutonPrincipal(
                texte: 'Créer mon compte',
                onPressed: _creerCompte,
                enCours: _enCours,
              ),
              const SizedBox(height: 12),

              // Lien vers la connexion pour ceux qui ont déjà un compte
              TextButton(
                onPressed: () => context.pushReplacement(Routes.connexion),
                child: const Text(
                  "J'ai déjà un compte",
                  style: TextStyle(color: Couleurs.marron, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Couleurs.texteDiscret),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Votre numéro n'est jamais affiché dans l'application.",
                      style: TextStyle(fontSize: 12, color: Couleurs.texteDiscret),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Règles de validation ----------

  String? _verifierTelephone(String? valeur) {
    final chiffres = (valeur ?? '').replaceAll(' ', '');
    if (chiffres.length != 9) return 'Numéro à 9 chiffres';
    return null;
  }

  String? _verifierEmail(String? valeur) {
    if (valeur == null || !valeur.contains('@')) return 'Email invalide';
    return null;
  }

  String? _verifierMotDePasse(String? valeur) {
    if (valeur == null || valeur.length < 6) return '6 caractères minimum';
    return null;
  }
}
