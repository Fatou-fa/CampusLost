import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/couleurs.dart';

/// Modification du prénom, du nom et du téléphone.
/// L'email sert d'identifiant : il n'est pas modifiable.
class ModifierProfilScreen extends StatefulWidget {
  const ModifierProfilScreen({super.key});

  @override
  State<ModifierProfilScreen> createState() => _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends State<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prenom;
  late final TextEditingController _nom;
  late final TextEditingController _telephone;

  @override
  void initState() {
    super.initState();
    // Les champs sont pré-remplis avec les informations actuelles
    final moi = context.read<AuthProvider>().utilisateur;
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
    final auth = context.read<AuthProvider>();
    final reussi = await auth.modifierProfil(
      nom: _nom.text.trim(),
      prenom: _prenom.text.trim(),
      telephone: _telephone.text.replaceAll(' ', ''),
    );
    if (!mounted) return;
    final messager = ScaffoldMessenger.of(context);
    if (reussi) {
      Navigator.pop(context);
      messager.showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
    } else {
      messager.showSnackBar(SnackBar(content: Text(auth.erreur ?? 'Erreur')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _champ(_prenom, 'Prénom'),
              const SizedBox(height: 16),
              _champ(_nom, 'Nom'),
              const SizedBox(height: 16),
              _champ(
                _telephone,
                'Téléphone',
                clavier: TextInputType.phone,
                validation: (v) => (v ?? '').replaceAll(' ', '').length == 9
                    ? null
                    : 'Numéro à 9 chiffres',
              ),
              const SizedBox(height: 16),
              // Email affiché mais non modifiable
              TextFormField(
                initialValue: auth.utilisateur?.email ?? '',
                enabled: false,
                decoration: _style('Email (non modifiable)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: auth.enCours ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Couleurs.marron,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _style(String libelle) => InputDecoration(
        labelText: libelle,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _champ(TextEditingController controleur, String libelle,
      {TextInputType clavier = TextInputType.text,
      String? Function(String?)? validation}) {
    return TextFormField(
      controller: controleur,
      keyboardType: clavier,
      decoration: _style(libelle),
      validator: validation ??
          (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
    );
  }
}
