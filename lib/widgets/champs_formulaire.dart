import 'package:flutter/material.dart';

import '../theme/couleurs.dart';

/// Éléments communs à tous les formulaires de l'application, pour qu'ils
/// aient le même style : libellé au-dessus du champ, icône, coins
/// arrondis, bordure marron quand le champ est actif.

/// Style d'un champ (utilisé par ChampFormulaire et ListeFormulaire).
InputDecoration styleChamp({String? exemple, IconData? icone, Widget? suffixe}) {
  OutlineInputBorder bord(Color couleur, [double epaisseur = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: couleur, width: epaisseur),
      );

  return InputDecoration(
    hintText: exemple,
    hintStyle: TextStyle(color: Couleurs.texteDiscret.withValues(alpha: 0.6)),
    prefixIcon: icone == null ? null : Icon(icone, color: Couleurs.marron, size: 22),
    suffixIcon: suffixe,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: bord(Couleurs.bordure),
    focusedBorder: bord(Couleurs.marron, 1.6),
    errorBorder: bord(const Color(0xFFC8553D)),
    focusedErrorBorder: bord(const Color(0xFFC8553D), 1.6),
    disabledBorder: bord(Couleurs.bordure),
    border: bord(Couleurs.bordure),
  );
}

/// Libellé en gras au-dessus d'un champ.
class TitreChamp extends StatelessWidget {
  final String texte;
  final bool facultatif;

  const TitreChamp(this.texte, {super.key, this.facultatif = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text.rich(
        TextSpan(
          text: texte,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Couleurs.texte,
          ),
          children: [
            if (facultatif)
              const TextSpan(
                text: '  (facultatif)',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Couleurs.texteDiscret,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Champ de texte avec son libellé.
///
/// [cache] : mot de passe, avec un bouton « œil » pour l'afficher.
/// [obligatoire] : message « Obligatoire » si vide (sauf si [validation]
/// est donné). [surAppui] + [lectureSeule] : champ qui ouvre autre chose
/// (calendrier…) au lieu du clavier.
class ChampFormulaire extends StatefulWidget {
  final TextEditingController? controleur;
  final String libelle;
  final String? exemple;
  final IconData? icone;
  final TextInputType clavier;
  final int lignes;
  final bool cache;
  final bool obligatoire;
  final bool lectureSeule;
  final bool actif;
  final String? valeurInitiale;
  final VoidCallback? surAppui;
  final Widget? suffixe;
  final String? Function(String?)? validation;
  final ValueChanged<String>? surChangement;

  const ChampFormulaire({
    super.key,
    this.controleur,
    required this.libelle,
    this.exemple,
    this.icone,
    this.clavier = TextInputType.text,
    this.lignes = 1,
    this.cache = false,
    this.obligatoire = true,
    this.lectureSeule = false,
    this.actif = true,
    this.valeurInitiale,
    this.surAppui,
    this.suffixe,
    this.validation,
    this.surChangement,
  });

  @override
  State<ChampFormulaire> createState() => _ChampFormulaireState();
}

class _ChampFormulaireState extends State<ChampFormulaire> {
  late bool _masque = widget.cache; // texte caché (mot de passe)

  @override
  Widget build(BuildContext context) {
    // Bouton œil pour les mots de passe
    final oeil = widget.cache
        ? IconButton(
            tooltip: _masque ? 'Afficher' : 'Masquer',
            onPressed: () => setState(() => _masque = !_masque),
            icon: Icon(
              _masque ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Couleurs.texteDiscret,
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitreChamp(widget.libelle, facultatif: !widget.obligatoire),
        TextFormField(
          controller: widget.controleur,
          initialValue: widget.controleur == null ? widget.valeurInitiale : null,
          keyboardType: widget.lignes > 1 ? TextInputType.multiline : widget.clavier,
          maxLines: widget.cache ? 1 : widget.lignes,
          obscureText: _masque,
          readOnly: widget.lectureSeule,
          enabled: widget.actif,
          onTap: widget.surAppui,
          onChanged: widget.surChangement,
          textCapitalization: widget.clavier == TextInputType.text
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          style: const TextStyle(fontSize: 15, color: Couleurs.texte),
          decoration: styleChamp(
            exemple: widget.exemple,
            icone: widget.icone,
            suffixe: oeil ?? widget.suffixe,
          ),
          validator: widget.validation ??
              (valeur) => widget.obligatoire &&
                      (valeur == null || valeur.trim().isEmpty)
                  ? 'Obligatoire'
                  : null,
        ),
      ],
    );
  }
}

/// Carte blanche qui regroupe quelques champs sous un titre avec icône.
class SectionFormulaire extends StatelessWidget {
  final String titre;
  final IconData icone;
  final List<Widget> children;

  const SectionFormulaire({
    super.key,
    required this.titre,
    required this.icone,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Couleurs.marronFonce.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Couleurs.beigeClair,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, size: 19, color: Couleurs.marron),
              ),
              const SizedBox(width: 10),
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Grand bouton marron pleine largeur, avec un indicateur de chargement.
class BoutonPrincipal extends StatelessWidget {
  final String texte;
  final IconData? icone;
  final VoidCallback? onPressed;
  final bool enCours;

  const BoutonPrincipal({
    super.key,
    required this.texte,
    this.icone,
    this.onPressed,
    this.enCours = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: enCours ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Couleurs.marron,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: enCours
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(texte,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

/// Puce à choisir (catégorie, emplacement…), avec une image ou une icône.
class PuceChoix extends StatelessWidget {
  final String libelle;
  final bool choisie;
  final VoidCallback onTap;
  final Widget? image;

  const PuceChoix({
    super.key,
    required this.libelle,
    required this.choisie,
    required this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(image == null ? 14 : 6, 6, 14, 6),
        decoration: BoxDecoration(
          color: choisie ? Couleurs.marron : Couleurs.fond,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: choisie ? Couleurs.marron : Couleurs.bordure),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              Container(
                width: 28,
                height: 28,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: image,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              libelle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: choisie ? FontWeight.w600 : FontWeight.w500,
                color: choisie ? Colors.white : Couleurs.texte,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
