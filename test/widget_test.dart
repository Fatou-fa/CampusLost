import 'package:flutter_test/flutter_test.dart';

import 'package:campuslost/main.dart';

void main() {
  testWidgets("L'accueil affiche les annonces d'exemple",
      (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLostApp());

    expect(find.text('Catégories'), findsOneWidget);
    expect(find.text('Trousseau de clés'), findsOneWidget);
    expect(find.text("Carte d'étudiant"), findsOneWidget);
  });
}
