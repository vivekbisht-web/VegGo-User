//
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  static const String _keyAuthToken = 'auth_token';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_keyAccessToken, token);
    await _prefs.setString(_keyAuthToken, token);
  }

  static String? getAccessToken() {
    return _prefs.getString(_keyAccessToken) ?? _prefs.getString(_keyAuthToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_keyRefreshToken, token);
  }

  static String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  static Future<void> clearToken() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
  }

  static bool isTokenExpired(String? token) {
    if (token == null || token.trim().isEmpty) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final normalized = base64Url.normalize(payload);
      final decodedJson = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(decodedJson);

      if (payloadMap.containsKey('exp') && payloadMap['exp'] != null) {
        final exp = payloadMap['exp'];
        if (exp is num) {
          final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
            exp.toInt() * 1000,
            isUtc: true,
          );
          return DateTime.now().toUtc().isAfter(expiryDate);
        }
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  static bool hasTokens() {
    final access = getAccessToken();
    return access != null && access.trim().isNotEmpty;
  }

  static bool isAccessTokenExpired() {
    return isTokenExpired(getAccessToken());
  }

  static bool isRefreshTokenExpired() {
    return isTokenExpired(getRefreshToken());
  }

  static bool hasValidTokens() {
    final access = getAccessToken();
    final refresh = getRefreshToken();
    final isAccessAlive = access != null && access.trim().isNotEmpty && !isTokenExpired(access);
    final isRefreshAlive = refresh != null && refresh.trim().isNotEmpty && !isTokenExpired(refresh);
    return isAccessAlive || isRefreshAlive;
  }

  static bool areBothTokensExpired() {
    final access = getAccessToken();
    final refresh = getRefreshToken();
    final isAccessExpired = isTokenExpired(access);
    final isRefreshExpired = isTokenExpired(refresh);

    if (refresh == null || refresh.trim().isEmpty) {
      return isAccessExpired;
    }
    return isAccessExpired && isRefreshExpired;
  }

  static Future<void> saveToken(String token) async {
    await saveAccessToken(token);
  }

  static String? getToken() {
    return getAccessToken();
  }

  static Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }

  static bool isOnboardingComplete() {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Location methods
  static const String _keyLatitude = 'custom_latitude';
  static const String _keyLongitude = 'custom_longitude';
  static const String _keyLocationName = 'custom_location_name';

  static Future<void> saveLocation(double lat, double lng, String name) async {
    await _prefs.setDouble(_keyLatitude, lat);
    await _prefs.setDouble(_keyLongitude, lng);
    await _prefs.setString(_keyLocationName, name);
  }

  static double? getLatitude() {
    return _prefs.getDouble(_keyLatitude);
  }

  static double? getLongitude() {
    return _prefs.getDouble(_keyLongitude);
  }

  static String? getLocationName() {
    return _prefs.getString(_keyLocationName);
  }

  static Future<void> clearLocation() async {
    await _prefs.remove(_keyLatitude);
    await _prefs.remove(_keyLongitude);
    await _prefs.remove(_keyLocationName);
  }
}
