import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campuslost/main.dart';
import 'package:campuslost/providers/annonce_provider.dart';
import 'package:campuslost/providers/auth_provider.dart';

/// Lance l'application avec une session simulée.
Future<void> lancerApp(WidgetTester tester, {required bool connecte}) async {
  // Faux stockage du téléphone (pas de vrai SharedPreferences en test)
  SharedPreferences.setMockInitialValues(connecte
      ? {'session_connecte': true, 'utilisateur_prenom': 'Fatou'}
      : {});
  final auth = AuthProvider();
  await auth.chargerSession();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => AnnonceProvider()),
    ],
    child: const CampusLostApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Sans session : écran de bienvenue', (tester) async {
    await lancerApp(tester, connecte: false);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text("J'ai déjà un compte"), findsOneWidget);
  });

  testWidgets('Avec session : accueil directement', (tester) async {
    await lancerApp(tester, connecte: true);
    expect(find.text('Bonjour Fatou'), findsOneWidget);
    expect(find.text('Catégories'), findsOneWidget);
    expect(find.text('Trousseau de clés'), findsOneWidget);
  });
}
