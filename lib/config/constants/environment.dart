import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {

  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl = dotenv.env['API_URL'] ?? 'No está configurado el API_URL';
  static String apiUrlPlace = dotenv.env['API_URL_PLACE'] ?? 'No está configurado el API_URL_PLACE';
  static String apiKeyGooglePlace = dotenv.env['API_KEY_GOOGLE_PLACE'] ?? 'No está configurado el API_KEY_GOOGLE_PLACE';
  static String apiKeyGoogleGeocode = dotenv.env['API_KEY_GOOGLE_GEOCODE'] ?? 'No está configurado el API_KEY_GOOGLE_GEOCODE';

}

