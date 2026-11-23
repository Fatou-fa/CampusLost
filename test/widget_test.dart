import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campuslost/main.dart';
import 'package:campuslost/models/annonce_model.dart';
import 'package:campuslost/models/message_model.dart';
import 'package:campuslost/models/reclamation_model.dart';
import 'package:campuslost/models/signalement_model.dart';
import 'package:campuslost/models/utilisateur_model.dart';
import 'package:campuslost/providers/annonce_provider.dart';
import 'package:campuslost/providers/auth_provider.dart';
import 'package:campuslost/providers/reclamation_provider.dart';
import 'package:campuslost/repositories/annonce_repository.dart';
import 'package:campuslost/repositories/message_repository.dart';
import 'package:campuslost/repositories/reclamation_repository.dart';

// =====================================================================
//  Faux repositories : les tests ne parlent pas à Firebase.
//  « implements » : même interface que le vrai repository, mais les
//  données restent en mémoire.
// =====================================================================

class FauxAnnonces implements AnnonceRepository {
  FauxAnnonces(this.liste);
  final List<Annonce> liste;

  @override
  Stream<List<Annonce>> ecouter() => Stream.value(List.of(liste));
  @override
  String nouvelId() => 'a${liste.length + 1}';
  @override
  Future<void> ajouter(Annonce annonce) async => liste.add(annonce);
  @override
  Future<void> modifier(Annonce annonce) async {}
  @override
  Future<void> changerStatut(String id, String statut) async {}
  @override
  Future<void> supprimer(String id) async {}
  @override
  Future<void> ajouterExemplesSiVide() async {}
}

class FauxReclamations implements ReclamationRepository {
  FauxReclamations(this.liste);
  final List<Reclamation> liste;
  final _flux = StreamController<List<Reclamation>>.broadcast();
  var _numero = 0;

  void _publier() => _flux.add(List.of(liste));

  @override
  Stream<List<Reclamation>> ecouter(String moiId) async* {
    yield List.of(liste);
    yield* _flux.stream;
  }

  @override
  String nouvelId() => 'r${++_numero}';
  @override
  Future<void> ajouter(Reclamation r) async {
    liste.add(r);
    _publier();
  }

  @override
  Future<void> changerStatuts(Map<String, String> statutParId) async {
    for (var i = 0; i < liste.length; i++) {
      final statut = statutParId[liste[i].id];
      if (statut != null) liste[i] = liste[i].copieAvecStatut(statut);
    }
    _publier();
  }

  @override
  Future<void> supprimer(List<String> ids) async {
    liste.removeWhere((r) => ids.contains(r.id));
    _publier();
  }
}

class FauxMessages implements MessageRepository {
  @override
  Stream<List<Conversation>> ecouter(String moiId) => Stream.value(const []);
  @override
  Future<void> creer(Conversation c) async {}
  @override
  Future<void> envoyer(String conversationId, Message message) async {}
  @override
  Future<void> remplacerMessages(String conversationId, List<Message> messages) async {}
  @override
  Future<void> changerBlocage(String conversationId, String? moiId) async {}
  @override
  Future<void> signaler(Signalement s) async {}
}

// =====================================================================
//  Données de test
// =====================================================================

final fatou = Utilisateur(
  id: 'u100',
  nom: 'Fall',
  prenom: 'Fatou',
  email: 'fatou@ugb.edu.sn',
  telephone: '770000001',
);

Annonce annonceTest(String id, String statut) => Annonce(
      id: id,
      titre: 'Objet $id',
      description: '',
      type: 'trouve',
      statut: statut,
      date: 'Lundi',
      categorie: 'Clés',
      lieu: 'Resto U',
      auteurId: 'u100',
      auteurNom: 'Fatou F.',
    );

/// Laisse passer les événements des flux (Stream) avant de vérifier.
Future<void> attendre() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Lance l'application avec ou sans utilisateur connecté.
Future<void> lancerApp(WidgetTester tester, {Utilisateur? utilisateur}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      utilisateurInitialProvider.overrideWithValue(utilisateur),
      annonceRepositoryProvider.overrideWithValue(
          FauxAnnonces([annonceTest('a1', 'active')])),
      reclamationRepositoryProvider.overrideWithValue(FauxReclamations([])),
      messageRepositoryProvider.overrideWithValue(FauxMessages()),
    ],
    child: const CampusLostApp(),
  ));
  await tester.pumpAndSettle();
}

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

  test("L'accueil cache les annonces restituées", () async {
    // ProviderContainer : utiliser Riverpod sans interface (tests)
    final conteneur = ProviderContainer(overrides: [
      utilisateurInitialProvider.overrideWithValue(fatou),
      annonceRepositoryProvider.overrideWithValue(FauxAnnonces([
        annonceTest('a1', 'active'),
        annonceTest('a2', 'restitue'),
      ])),
    ]);
    addTearDown(conteneur.dispose);
    conteneur.listen(resultatsProvider, (_, _) {}); // garde le provider actif
    await attendre();

    final resultats = conteneur.read(resultatsProvider);
    expect(resultats.length, 1);
    expect(resultats.any((a) => a.estRestituee), isFalse);
  });

  test('Accepter une réclamation refuse les autres sur le même objet', () async {
    final awa = Reclamation(
      id: 'r-awa',
      message: 'Ce sont mes écouteurs',
      date: 'Lundi',
      statut: 'en_attente',
      annonceId: 'a6',
      annonceTitre: 'Écouteurs sans fil',
      proprietaireId: 'u100',
      demandeurId: 'u201',
      demandeurNom: 'Awa N.',
    );
    final conteneur = ProviderContainer(overrides: [
      utilisateurInitialProvider.overrideWithValue(fatou),
      reclamationRepositoryProvider.overrideWithValue(FauxReclamations([awa])),
    ]);
    addTearDown(conteneur.dispose);
    conteneur.listen(reclamationsProvider, (_, _) {});
    await attendre();

    final reclamations = conteneur.read(reclamationsProvider.notifier);
    await reclamations.reclamer(
      annonceId: 'a6',
      annonceTitre: 'Écouteurs sans fil',
      proprietaireId: 'u100',
      demandeurId: 'u300',
      demandeurNom: 'Test',
      demandeurTelephone: '',
      message: '',
      detail: 'boîtier blanc',
    );
    await attendre();
    await reclamations.accepter('r-awa');
    await attendre();

    final surAnnonce6 =
        conteneur.read(reclamationsProvider).where((r) => r.annonceId == 'a6');
    expect(surAnnonce6.length, 2);
    expect(surAnnonce6.where((r) => r.estAcceptee).length, 1);
    expect(surAnnonce6.where((r) => r.estRefusee).length, 1);
  });
}
