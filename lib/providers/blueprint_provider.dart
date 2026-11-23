import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/blueprint_model.dart';
import '../services/blueprint_service.dart';
import '../services/local_storage_service.dart';

/// Global State Management menggunakan Provider (ChangeNotifier)
/// Terintegrasi dengan SharedPreferences (LocalStorageService) untuk menyimpan
/// Host Docker API, daftar Bookmark (Wishlist), dan Akuisisi IP secara persisten.
class BlueprintProvider extends ChangeNotifier {
  final BlueprintService _blueprintService;
  final LocalStorageService _localStorage;

  BlueprintProvider({
    BlueprintService? blueprintService,
    LocalStorageService? localStorage,
  })  : _blueprintService = blueprintService ?? BlueprintService(),
        _localStorage = localStorage ?? LocalStorageService();

  // State Utama Blueprint & Koneksi Backend
  List<BlueprintModel> _blueprints = [];
  bool _isLoading = false;
  bool _isBackendConnected = false;

  // State Filter & Pencarian Global
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  String _selectedSort = 'Populer';

  // State Global Bookmark (Wishlist) & Akuisisi Lisensi IP
  final Set<String> _bookmarkedTitles = {};
  final Set<String> _acquiredTitles = {};

  // Getters
  List<BlueprintModel> get blueprints => List.unmodifiable(_blueprints);
  bool get isLoading => _isLoading;
  bool get isBackendConnected => _isBackendConnected;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;
  String get apiHost => ApiConfig.host;
  String get apiBaseUrl => ApiConfig.baseUrl;
  Set<String> get bookmarkedTitles => Set.unmodifiable(_bookmarkedTitles);
  Set<String> get acquiredTitles => Set.unmodifiable(_acquiredTitles);

  /// Daftar blueprint yang telah difilter berdasarkan kategori, pencarian, dan urutan
  List<BlueprintModel> get filteredBlueprints {
    List<BlueprintModel> list = List.from(_blueprints);

    // Filter kategori berdasarkan chip:
    // 0: Semua, 1: Populer, 2: Frontend, 3: Backend, 4: Mobile, 5: AI/ML
    if (_selectedCategoryIndex == 1) {
      list = list.where((b) {
        final l = b.stackLabel.toLowerCase();
        return l.contains('laravel') ||
            l.contains('next') ||
            l.contains('flutter') ||
            l.contains('fastapi');
      }).toList();
    } else if (_selectedCategoryIndex == 2) {
      list = list.where((b) {
        final l = b.stackLabel.toLowerCase();
        return l.contains('next') || l.contains('react');
      }).toList();
    } else if (_selectedCategoryIndex == 3) {
      list = list.where((b) {
        final l = b.stackLabel.toLowerCase();
        return l.contains('laravel') || l.contains('fastapi');
      }).toList();
    } else if (_selectedCategoryIndex == 4) {
      list = list
          .where((b) => b.stackLabel.toLowerCase().contains('flutter'))
          .toList();
    } else if (_selectedCategoryIndex == 5) {
      list = list.where((b) {
        final l = b.stackLabel.toLowerCase();
        return l.contains('ai') || l.contains('python');
      }).toList();
    }

    // Filter teks pencarian
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((b) {
        return b.title.toLowerCase().contains(query) ||
            b.author.toLowerCase().contains(query) ||
            b.stackLabel.toLowerCase().contains(query) ||
            b.description.toLowerCase().contains(query);
      }).toList();
    }

    // Urutkan
    if (_selectedSort == 'Terbaru') {
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
    }

    return list;
  }

  /// Memuat data yang tersimpan di SharedPreferences (Host Docker, Bookmark, Akuisisi IP)
  Future<void> loadLocalPreferences() async {
    final savedHost = await _localStorage.getDockerHost();
    if (savedHost != null && savedHost.isNotEmpty) {
      ApiConfig.setHost(savedHost);
    }

    final savedBookmarks = await _localStorage.getBookmarkedTitles();
    if (savedBookmarks.isNotEmpty) {
      _bookmarkedTitles.addAll(savedBookmarks);
    }

    final savedAcquired = await _localStorage.getAcquiredTitles();
    if (savedAcquired.isNotEmpty) {
      _acquiredTitles.addAll(savedAcquired);
    }
  }

  /// READ: Memuat seluruh data blueprint dari Docker MySQL API & SharedPreferences ke Global State
  Future<void> loadBlueprints() async {
    _isLoading = true;
    notifyListeners();

    await loadLocalPreferences();
    final isOnline = await _blueprintService.isBackendConnected();
    final data = await _blueprintService.getBlueprints();

    _isBackendConnected = isOnline;
    _blueprints = data;
    _isLoading = false;
    notifyListeners();
  }

  /// CREATE: Menambahkan blueprint baru dan memperbarui Global State
  Future<bool> createBlueprint(BlueprintModel blueprint) async {
    _isLoading = true;
    notifyListeners();

    final success = await _blueprintService.createBlueprint(blueprint);
    if (success) {
      await loadBlueprints();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  /// UPDATE: Memperbarui blueprint yang sudah ada dan menyinkronkan Global State
  Future<bool> updateBlueprint(BlueprintModel blueprint) async {
    _isLoading = true;
    notifyListeners();

    final success = await _blueprintService.updateBlueprint(blueprint);
    if (success) {
      await loadBlueprints();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  /// DELETE: Menghapus blueprint berdasarkan ID dan memperbarui Global State
  Future<bool> deleteBlueprint(int id) async {
    final success = await _blueprintService.deleteBlueprint(id);
    if (success) {
      _blueprints.removeWhere((b) => b.id == id);
      notifyListeners();
      await loadBlueprints();
    }
    return success;
  }

  /// Mengubah kategori filter aktif
  void setCategoryIndex(int index) {
    if (_selectedCategoryIndex == index) return;
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  /// Mengubah kata kunci pencarian
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Mengubah opsi pengurutan
  void setSelectedSort(String sort) {
    if (_selectedSort == sort) return;
    _selectedSort = sort;
    notifyListeners();
  }

  /// Mereset filter kategori dan pencarian ke default
  void resetFilter() {
    _selectedCategoryIndex = 0;
    _searchQuery = '';
    notifyListeners();
  }

  /// Mengubah konfigurasi host/IP Docker API, menyimpannya ke SharedPreferences, lalu memuat ulang data
  Future<void> updateApiHost(String newHost) async {
    ApiConfig.setHost(newHost);
    await _localStorage.saveDockerHost(newHost);
    notifyListeners();
    await loadBlueprints();
  }

  /// Mereset host/IP Docker API ke default platform, menghapus di SharedPreferences, lalu memuat ulang data
  Future<void> resetApiHost() async {
    ApiConfig.resetHost();
    await _localStorage.clearDockerHost();
    notifyListeners();
    await loadBlueprints();
  }

  /// Mengecek apakah blueprint sudah di-bookmark ke Wishlist global
  bool isBookmarked(String title) => _bookmarkedTitles.contains(title);

  /// Toggle status bookmark blueprint di Global State & simpan ke SharedPreferences
  void toggleBookmark(String title) {
    if (_bookmarkedTitles.contains(title)) {
      _bookmarkedTitles.remove(title);
    } else {
      _bookmarkedTitles.add(title);
    }
    _localStorage.saveBookmarkedTitles(_bookmarkedTitles);
    notifyListeners();
  }

  /// Mengecek apakah lisensi IP blueprint sudah diakuisisi
  bool isAcquired(String title) => _acquiredTitles.contains(title);

  /// Toggle status akuisisi lisensi IP di Global State & simpan ke SharedPreferences
  void toggleAcquireIP(String title) {
    if (_acquiredTitles.contains(title)) {
      _acquiredTitles.remove(title);
    } else {
      _acquiredTitles.add(title);
    }
    _localStorage.saveAcquiredTitles(_acquiredTitles);
    notifyListeners();
  }
}
