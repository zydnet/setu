import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String geminiVisionUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}

class AppConstants {
  static const String appName = 'setu';
  static const int cameraWaitDurationMs = 2000;
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
}