import 'package:flutter_test/flutter_test.dart';

import 'package:campuslost/main.dart';

void main() {
  testWidgets("L'accueil affiche les annonces et filtre les objets perdus",
      (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLostApp());

    // Les 4 annonces d'exemple sont affichées
    expect(find.text("Qu'avez-vous perdu ?"), findsOneWidget);
    expect(find.text('Trousseau de clés'), findsOneWidget);

    // Après un clic sur « Perdus », les objets trouvés disparaissent
    await tester.tap(find.text('Perdus'));
    await tester.pump();
    expect(find.text('Trousseau de clés'), findsNothing);
    expect(find.text("Carte d'étudiant"), findsOneWidget);
  });
}
