import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campuslost/main.dart';
import 'package:campuslost/providers/annonce_provider.dart';
import 'package:campuslost/providers/auth_provider.dart';
import 'package:campuslost/providers/reclamation_provider.dart';

/// Lance l'application avec une session simulée.
Future<void> lancerApp(WidgetTester tester, {required bool connecte}) async {
  // Faux stockage du téléphone (pas de vrai SharedPreferences en test)
  SharedPreferences.setMockInitialValues(connecte
      ? {
          'session_connecte': true,
          'utilisateur_id': 100,
          'utilisateur_prenom': 'Fatou',
          'utilisateur_nom': 'Fall',
        }
      : {});
  final auth = AuthProvider();
  await auth.chargerSession();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => AnnonceProvider()),
      ChangeNotifierProvider(create: (_) => ReclamationProvider()),
    ],
    child: CampusLostApp(dejaConnecte: auth.estConnecte),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Sans session : écran de bienvenue', (tester) async {
    await lancerApp(tester, connecte: false);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text("J'ai déjà un compte"), findsOneWidget);
  });

  testWidgets('Avec session : accueil et barre du bas', (tester) async {
    await lancerApp(tester, connecte: true);
    expect(find.text('Bonjour Fatou'), findsOneWidget);
    expect(find.text('Catégories'), findsOneWidget);
    expect(find.text('Mes annonces'), findsWidgets); // onglet de la barre
    expect(find.text('Profil'), findsOneWidget);
  });

  test('La recherche cache les annonces restituées', () {
    final annonces = AnnonceProvider();
    expect(annonces.resultats.any((a) => a.estRestituee), isFalse);
  });

  test('Accepter une réclamation refuse les autres sur le même objet', () {
    final r = ReclamationProvider();
    r.reclamer(
      annonceId: 6,
      annonceTitre: 'Écouteurs sans fil',
      demandeurId: 300,
      demandeurNom: 'Test',
      demandeurTelephone: '',
      message: '',
      detail: 'boîtier blanc',
    );
    r.accepter(1); // réclamation d'Awa
    final liste = r.recues([6]);
    expect(liste.where((x) => x.estAcceptee).length, 1);
    expect(liste.where((x) => x.estRefusee).length, 1);
  });
}
