import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';

/// Écran 3 : création d'un compte.
///
/// L'utilisateur ne s'inscrit qu'une seule fois : ensuite, l'application
/// le garde connecté (voir AuthService).
class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
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

    final auth = context.read<AuthProvider>();
    final reussi = await auth.inscrire(
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      email: _email.text.trim(),
      telephone: _telephone.text.trim(),
      motDePasse: _motDePasse.text,
    );
    if (!mounted) return; // l'écran a pu être fermé pendant l'attente

    if (reussi) {
      // On vide la pile : le bouton retour ne ramène pas à l'inscription
      Navigator.pushNamedAndRemoveUntil(context, Routes.accueil, (_) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.erreur ?? 'Erreur')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vrai pendant l'enregistrement : on désactive le bouton
    final enCours = context.watch<AuthProvider>().enCours;

    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: Couleurs.marronFonce,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // SingleChildScrollView : le formulaire défile quand le clavier s'ouvre
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Une seule fois : ensuite, l'application vous garde connecté(e).",
                style: TextStyle(color: Couleurs.texteDiscret),
              ),
              const SizedBox(height: 24),

              // Prénom et nom côte à côte
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _champ(_prenom, 'Prénom', 'Awa')),
                  const SizedBox(width: 12),
                  Expanded(child: _champ(_nom, 'Nom', 'Ndiaye')),
                ],
              ),
              const SizedBox(height: 16),
              _champ(_telephone, 'Téléphone', '77 000 00 00',
                  clavier: TextInputType.phone, validation: _verifierTelephone),
              const SizedBox(height: 16),
              _champ(_email, 'Email', 'prenom.nom@ugb.edu.sn',
                  clavier: TextInputType.emailAddress,
                  validation: _verifierEmail),
              const SizedBox(height: 16),
              _champ(_motDePasse, 'Mot de passe', '6 caractères minimum',
                  cache: true, validation: _verifierMotDePasse),
              const SizedBox(height: 32),

              // Bouton principal
              ElevatedButton(
                onPressed: enCours ? null : _creerCompte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Couleurs.marron,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: enCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Créer mon compte',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 16),

              // Lien vers la connexion pour ceux qui ont déjà un compte
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, Routes.connexion),
                child: const Text(
                  "J'ai déjà un compte",
                  style: TextStyle(color: Couleurs.marron),
                ),
              ),
              const Text(
                "Votre numéro n'est visible que des utilisateurs connectés.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Couleurs.texteDiscret),
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

  /// Crée un champ de saisie avec son libellé.
  /// [cache] masque le texte (mot de passe), [clavier] choisit le type de
  /// clavier, [validation] vérifie la valeur (par défaut : champ obligatoire).
  Widget _champ(
    TextEditingController controleur,
    String libelle,
    String exemple, {
    bool cache = false,
    TextInputType clavier = TextInputType.text,
    String? Function(String?)? validation,
  }) {
    return TextFormField(
      controller: controleur,
      obscureText: cache,
      keyboardType: clavier,
      validator: validation ??
          (valeur) =>
              (valeur == null || valeur.trim().isEmpty) ? 'Obligatoire' : null,
      decoration: InputDecoration(
        labelText: libelle,
        hintText: exemple,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
