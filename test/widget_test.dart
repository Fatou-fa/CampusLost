import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campuslost/main.dart';
import 'package:campuslost/models/utilisateur_model.dart';
import 'package:campuslost/providers/annonce_provider.dart';
import 'package:campuslost/providers/auth_provider.dart';
import 'package:campuslost/providers/reclamation_provider.dart';

/// Lance l'application avec ou sans utilisateur connecté.
Future<void> lancerApp(WidgetTester tester, {Utilisateur? utilisateur}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [utilisateurInitialProvider.overrideWithValue(utilisateur)],
    child: const CampusLostApp(),
  ));
  await tester.pumpAndSettle();
}

final fatou = Utilisateur(
  id: 100,
  nom: 'Fall',
  prenom: 'Fatou',
  email: 'fatou@ugb.edu.sn',
  telephone: '770000001',
);

void main() {
  testWidgets('Sans session : écran de bienvenue', (tester) async {
    await lancerApp(tester);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text("J'ai déjà un compte"), findsOneWidget);
  });

  testWidgets('Avec session : accueil et barre du bas', (tester) async {
    await lancerApp(tester, utilisateur: fatou);
    expect(find.text('Bonjour Fatou'), findsOneWidget);
    expect(find.text('Catégories'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  test("L'accueil cache les annonces restituées", () {
    // ProviderContainer : utiliser Riverpod sans interface (tests)
    final conteneur = ProviderContainer();
    addTearDown(conteneur.dispose);
    final resultats = conteneur.read(resultatsProvider);
    expect(resultats.any((a) => a.estRestituee), isFalse);
  });

  test('Accepter une réclamation refuse les autres sur le même objet', () {
    final conteneur = ProviderContainer();
    addTearDown(conteneur.dispose);
    final reclamations = conteneur.read(reclamationsProvider.notifier);

    reclamations.reclamer(
      annonceId: 6,
      annonceTitre: 'Écouteurs sans fil',
      demandeurId: 300,
      demandeurNom: 'Test',
      demandeurTelephone: '',
      message: '',
      detail: 'boîtier blanc',
    );
    reclamations.accepter(1); // réclamation d'Awa

    final surAnnonce6 =
        conteneur.read(reclamationsProvider).where((r) => r.annonceId == 6);
    expect(surAnnonce6.where((r) => r.estAcceptee).length, 1);
    expect(surAnnonce6.where((r) => r.estRefusee).length, 1);
  });
}
