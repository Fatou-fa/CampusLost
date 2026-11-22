/// Configuration de l'accès à l'API PHP.
///
/// L'API n'est pas encore branchée : ces valeurs serviront quand l'équipe
/// aura écrit les fichiers PHP (auth/login.php, annonces/liste.php…).
class ApiConfig {
  /// Adresse de l'API vue depuis l'émulateur Android.
  /// 10.0.2.2 = « localhost » de l'ordinateur, vu depuis l'émulateur.
  /// Sur un vrai téléphone, remplacer par l'adresse IP de l'ordinateur.
  static const String baseUrl = 'http://10.0.2.2/campuslost/api';

  /// Points d'accès prévus (voir le dossier de conception, section 4.6).
  static const String inscription = '$baseUrl/auth/register.php';
  static const String connexion = '$baseUrl/auth/login.php';
  static const String annonces = '$baseUrl/annonces/liste.php';

  /// Temps maximum d'attente d'une réponse du serveur.
  static const Duration delaiMax = Duration(seconds: 10);
}
