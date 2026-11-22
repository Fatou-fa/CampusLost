import 'package:campuslost/theme/couleurs.dart';
import 'package:flutter/material.dart';

class ReclamationsScreen extends StatefulWidget {
  const ReclamationsScreen({super.key});

  @override
  State<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends State<ReclamationsScreen> {
  // Données de démonstration correspondant à la maquette
  final List<Map<String, dynamic>> _reclamations = [
    {
      'initiales': 'AN',
      'nom': 'Awa N.',
      'sousTitre': 'il y a 20 min · Clé USB',
      'statut': 'EN ATTENTE',
      'message': '« Bonjour, je pense que c\'est ma clé USB, elle contient mon mémoire. »',
      'detail': 'une étiquette « AN » au dos',
    },
    {
      'initiales': 'IS',
      'nom': 'Ibrahima S.',
      'sousTitre': 'hier · Trousseau de clés',
      'statut': 'ACCEPTÉE',
      'message': null,
      'detail': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              const Text(
                'Réclamations',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Couleurs.marronFonce,
                ),
              ),
              const SizedBox(height: 6),
              // Sous-titre descriptif
              const Text(
                'Les demandes reçues sur les objets que vous avez trouvés.',
                style: TextStyle(
                  fontSize: 14,
                  color: Couleurs.texteDiscret,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // Liste des cartes de réclamation
              Expanded(
                child: ListView.separated(
                  itemCount: _reclamations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildCarteReclamation(_reclamations[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Construit une carte de réclamation (EN ATTENTE ou ACCEPTÉE)
  Widget _buildCarteReclamation(Map<String, dynamic> item, int index) {
    final estEnAttente = item['statut'] == 'EN ATTENTE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Couleurs.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      // En-tête : Avatar + Nom/Date + Badge de statut
      Row(
      children: [
      // Cercle d'initiales
      Container(
      width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: estEnAttente ? Couleurs.beige : Couleurs.beigeTrouve,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          item['initiales'] as String,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Couleurs.texte,
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Nom et objet concerné
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['nom'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Couleurs.texte,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item['sousTitre'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Couleurs.texteDiscret,
              ),
            ),
          ],
        ),
      ),
      // Badge de statut (EN ATTENTE en beige / ACCEPTÉE en vert doux)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: estEnAttente
              ? Couleurs.beigeClair
              : const Color(0xFFE3F3EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item['statut'] as String,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            color: estEnAttente
                ? Couleurs.marron
                : const Color(0xFF1F6E43),
          ),
        ),
      ),
      ],
    ),

    // Contenu détaillé si la demande est EN ATTENTE
    if (estEnAttente) ...[
    if (item['message'] != null) ...[
    const SizedBox(height: 14),
    Text(
    item['message'] as String,
    style: const TextStyle(
    fontSize: 14,
    color: Couleurs.texte,
    height: 1.4,
    ),
    ),
    ],
    if (item['detail'] != null) ...[
    const SizedBox(height: 12),
    // Encadré beige « Détail donné : ... »
    Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
    ),
    decoration: BoxDecoration(
    color: Couleurs.fond,
    borderRadius: BorderRadius.circular(10),
    ),
    child: RichText(
    text: TextSpan(
    style: const TextStyle(
    fontSize: 13,
    color: Couleurs.texte,
    ),
    children: [
    const TextSpan(
    text: 'Détail donné : ',
    style: TextStyle(fontWeight: FontWeight.bold),
    ),
    TextSpan(text: item['detail'] as String),
    ],
    ),
    ),
    ),
    ],
    const SizedBox(height: 16),
    // Boutons Refuser et Accepter côte à côte
    Row(
    children: [
    Expanded(
    child: SizedBox(
    height: 44,
    child: OutlinedButton.icon(
    onPressed: () {
    setState(() {
    _reclamations.removeAt(index);
    });
    },
    style: OutlinedButton.styleFrom(
    foregroundColor: Couleurs.texte,
    side: const BorderSide(color: Couleurs.bordure),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    icon: const Icon(Icons.close, size: 18),
    label: const Text(
    'Refuser',
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: SizedBox(
    height: 44,
    child: FilledButton.icon(
    onPressed: () {
    setState(() {
    _reclamations[index]['statut'] = 'ACCEPTÉE';
    });
    },
    style: FilledButton.styleFrom(
    backgroundColor: Couleurs.marron,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    icon: const Icon(Icons.check, size: 18),
    label: const Text(
    'Accepter',
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ] else ...[
    // Lien d'action si la demande est ACCEPTÉE
    const SizedBox(height: 14),
    GestureDetector(
    onTap: () {
    // Action ouvrir le contact ou la messagerie
    },
    child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.chat_bubble_outline_rounded,
      size: 16,
      color: Couleurs.marron,
    ),
      SizedBox(width: 6),
      Text(
        'Contacter pour la remise',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Couleurs.marron,
          decoration: TextDecoration.underline,
          decorationColor: Couleurs.marron,
        ),
      ),
    ],
    ),
    ),
    ],
        ],
      ),
    );
  }
  /// Barre de navigation du bas avec onglet « Réclamations » actif
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Couleurs.bordure)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Accueil', false),
              _buildNavItem(Icons.list_alt_rounded, 'Mes annonces', false),
// Bouton central rond beige (+)
              GestureDetector(
                onTap: () {
// Action publier une annonce
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Couleurs.beige,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Couleurs.texte,
                    size: 28,
                  ),
                ),
              ),
              _buildNavItem(Icons.inbox_outlined, 'Réclamations', true),
              _buildNavItem(Icons.person_outline, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }
  /// Élément individuel de la barre de navigation
  Widget _buildNavItem(IconData icon, String label, bool actif) {
    final couleur = actif ? Couleurs.marron : Couleurs.texteDiscret;
    return GestureDetector(
      onTap: () {
// Navigation entre les écrans
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: couleur, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: actif ? FontWeight.bold : FontWeight.w500,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}