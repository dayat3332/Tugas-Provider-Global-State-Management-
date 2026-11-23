import 'package:shared_preferences/shared_preferences.dart';

/// Service Penyimpanan Lokal menggunakan SharedPreferences.
/// Menyimpan konfigurasi Host Docker API, daftar Bookmark (Wishlist),
/// daftar Akuisisi Lisensi IP, serta sesi Login ("Ingat Saya").
class LocalStorageService {
  static const String _keyDockerHost = 'docker_api_host';
  static const String _keyBookmarkedTitles = 'bookmarked_blueprints';
  static const String _keyAcquiredTitles = 'acquired_blueprints';
  static const String _keySavedEmail = 'saved_developer_email';
  static const String _keyRememberMe = 'remember_me_status';

  /// Menyimpan Host / IP Docker API ke SharedPreferences
  Future<void> saveDockerHost(String host) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDockerHost, host.trim());
    } catch (_) {}
  }

  /// Membaca Host / IP Docker API dari SharedPreferences
  Future<String?> getDockerHost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDockerHost);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus Host / IP Docker API custom dari SharedPreferences
  Future<void> clearDockerHost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDockerHost);
    } catch (_) {}
  }

  /// Menyimpan daftar judul Blueprint yang di-bookmark ke SharedPreferences
  Future<void> saveBookmarkedTitles(Set<String> titles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyBookmarkedTitles, titles.toList());
    } catch (_) {}
  }

  /// Membaca daftar judul Blueprint yang di-bookmark dari SharedPreferences
  Future<Set<String>> getBookmarkedTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyBookmarkedTitles);
      return list != null ? list.toSet() : <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  /// Menyimpan daftar judul Blueprint yang telah diakuisisi ke SharedPreferences
  Future<void> saveAcquiredTitles(Set<String> titles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyAcquiredTitles, titles.toList());
    } catch (_) {}
  }

  /// Membaca daftar judul Blueprint yang telah diakuisisi dari SharedPreferences
  Future<Set<String>> getAcquiredTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyAcquiredTitles);
      return list != null ? list.toSet() : <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  /// Menyimpan sesi login ("Ingat Saya" & Email Pengembang) ke SharedPreferences
  Future<void> saveLoginSession({
    required String email,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, rememberMe);
      if (rememberMe && email.trim().isNotEmpty) {
        await prefs.setString(_keySavedEmail, email.trim());
      } else {
        await prefs.remove(_keySavedEmail);
      }
    } catch (_) {}
  }

  /// Membaca email pengembang yang tersimpan di SharedPreferences
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedEmail);
    } catch (_) {
      return null;
    }
  }

  /// Membaca status checkbox "Ingat Saya" dari SharedPreferences
  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyRememberMe) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Menghapus sesi login saat pengguna Sign Out
  Future<void> clearLoginSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySavedEmail);
      await prefs.setBool(_keyRememberMe, false);
    } catch (_) {}
  }
}
