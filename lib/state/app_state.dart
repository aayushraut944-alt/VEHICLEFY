import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

/// Where the backend lives by default:
///  * Android emulator -> the host machine is 10.0.2.2
///  * everything else  -> localhost (change it in Settings for a real phone)
String defaultBaseUrl() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000';
  }
  return 'http://127.0.0.1:5000';
}

class AppState extends ChangeNotifier {
  String baseUrl = defaultBaseUrl();
  String apiKey = '';

  /// Incremented whenever data changed (new lookup, history cleared, server changed)
  /// so screens know to reload.
  int version = 0;

  ApiService get api => ApiService(baseUrl, apiKey);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
    apiKey = prefs.getString('apiKey') ?? '';
    version++;
    notifyListeners();
  }

  Future<void> saveServer(String url, String key) async {
    baseUrl = url.trim().isEmpty ? defaultBaseUrl() : url.trim();
    apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', baseUrl);
    await prefs.setString('apiKey', apiKey);
    bump();
  }

  void bump() {
    version++;
    notifyListeners();
  }
}
