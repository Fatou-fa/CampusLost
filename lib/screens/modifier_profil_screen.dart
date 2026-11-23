import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';
import '../widgets/champs_formulaire.dart';

/// Modification du prénom, du nom et du téléphone.
/// L'email sert d'identifiant : il n'est pas modifiable.
class ModifierProfilScreen extends ConsumerStatefulWidget {
  const ModifierProfilScreen({super.key});

  @override
  ConsumerState<ModifierProfilScreen> createState() =>
      _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends ConsumerState<ModifierProfilScreen> {
  bool _enCours = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prenom;
  late final TextEditingController _nom;
  late final TextEditingController _telephone;

  @override
  void initState() {
    super.initState();
    // Les champs sont pré-remplis avec les informations actuelles
    final moi = ref.read(authProvider);
    _prenom = TextEditingController(text: moi?.prenom ?? '');
    _nom = TextEditingController(text: moi?.nom ?? '');
    _telephone = TextEditingController(text: moi?.telephone ?? '');
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enCours = true);
    final erreur = await ref.read(authProvider.notifier).modifierProfil(
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      telephone: _telephone.text.replaceAll(' ', ''),
    );
    if (!mounted) return;
    setState(() => _enCours = false);
    final messager = ScaffoldMessenger.of(context);
    if (erreur == null) {
      context.pop();
      messager.showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
    } else {
      messager.showSnackBar(SnackBar(content: Text(erreur)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final moi = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Couleurs.fond,
      appBar: AppBar(
        backgroundColor: Couleurs.fond,
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(color: Couleurs.marronFonce, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionFormulaire(
                titre: 'Mes informations',
                icone: Icons.person_outline,
                children: [
                  ChampFormulaire(
                    controleur: _prenom,
                    libelle: 'Prénom',
                    icone: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  ChampFormulaire(
                    controleur: _nom,
                    libelle: 'Nom',
                    icone: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  ChampFormulaire(
                    controleur: _telephone,
                    libelle: 'Téléphone',
                    icone: Icons.phone_outlined,
                    clavier: TextInputType.phone,
                    validation: (v) => (v ?? '').replaceAll(' ', '').length == 9
                        ? null
                        : 'Numéro à 9 chiffres',
                  ),
                  const SizedBox(height: 16),
                  // Email affiché mais non modifiable (c'est l'identifiant)
                  ChampFormulaire(
                    libelle: 'Email (non modifiable)',
                    valeurInitiale: moi?.email ?? '',
                    icone: Icons.mail_outline,
                    actif: false,
                    obligatoire: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BoutonPrincipal(
                texte: 'Enregistrer',
                icone: Icons.check,
                onPressed: _enregistrer,
                enCours: _enCours,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
