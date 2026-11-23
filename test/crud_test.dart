import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_necromancer/models/blueprint_model.dart';
import 'package:code_necromancer/config/api_config.dart';
import 'package:code_necromancer/providers/blueprint_provider.dart';
import 'package:code_necromancer/services/local_storage_service.dart';

void main() {
  group('BlueprintModel & BlueprintProvider Global State Tests', () {
    test('BlueprintModel serialization and deserialization', () {
      final json = {
        'id_blueprint': 10,
        'title': 'Unit Test Blueprint',
        'author': 'Tester Dev',
        'price': 'Rp 500.000',
        'stack_label': 'Flutter',
        'description': 'A test blueprint description',
        'is_verified': 1,
        'created_at': '2026-11-17 10:00:00',
      };

      final blueprint = BlueprintModel.fromJson(json);

      expect(blueprint.id, 10);
      expect(blueprint.title, 'Unit Test Blueprint');
      expect(blueprint.author, 'Tester Dev');
      expect(blueprint.price, 'Rp 500.000');
      expect(blueprint.stackLabel, 'Flutter');
      expect(blueprint.isVerified, true);

      final serialized = blueprint.toJson();
      expect(serialized['id_blueprint'], 10);
      expect(serialized['title'], 'Unit Test Blueprint');
      expect(serialized['is_verified'], 1);
    });

    test('ApiConfig returns proper endpoints', () {
      ApiConfig.resetHost();
      expect(ApiConfig.port, 80);

      final readUri = ApiConfig.readEndpoint;
      expect(readUri.path, '/api_blueprint/read.php');

      final createUri = ApiConfig.createEndpoint;
      expect(createUri.path, '/api_blueprint/create.php');

      final updateUri = ApiConfig.updateEndpoint;
      expect(updateUri.path, '/api_blueprint/update.php');

      final deleteUri = ApiConfig.deleteEndpoint;
      expect(deleteUri.path, '/api_blueprint/delete.php');
    });

    test('BlueprintProvider manages global filter, bookmark, and acquire state', () {
      final provider = BlueprintProvider();

      expect(provider.selectedCategoryIndex, 0);
      expect(provider.searchQuery, '');
      expect(provider.selectedSort, 'Populer');

      provider.setCategoryIndex(2);
      provider.setSearchQuery('Next.js');
      provider.setSelectedSort('Terbaru');

      expect(provider.selectedCategoryIndex, 2);
      expect(provider.searchQuery, 'Next.js');
      expect(provider.selectedSort, 'Terbaru');

      provider.resetFilter();
      expect(provider.selectedCategoryIndex, 0);
      expect(provider.searchQuery, '');

      // Bookmark & Acquire global state
      expect(provider.isBookmarked('Sistem ERP UMKM (Next.js)'), false);
      provider.toggleBookmark('Sistem ERP UMKM (Next.js)');
      expect(provider.isBookmarked('Sistem ERP UMKM (Next.js)'), true);

      expect(provider.isAcquired('Sistem ERP UMKM (Next.js)'), false);
      provider.toggleAcquireIP('Sistem ERP UMKM (Next.js)');
      expect(provider.isAcquired('Sistem ERP UMKM (Next.js)'), true);
    });

    test('4 Pilar PBO (Abstraction, Encapsulation, Inheritance, Polymorphism) works', () {
      const DigitalCodeAsset standardAsset = BlueprintModel(
        id: 1,
        title: 'Flutter Starter Kit',
        author: 'NecroDev',
        price: 'Rp 1.000.000',
        stackLabel: 'Flutter',
      );

      const DigitalCodeAsset enterpriseAsset = EnterpriseBlueprintModel(
        id: 2,
        title: 'Core Banking Engine',
        author: 'Lazarus Vault',
        price: 'Rp 15.000.000',
        stackLabel: 'Laravel',
        slaMonths: 24,
      );

      expect(standardAsset.assetCategory, 'Mobile Application Blueprint');
      expect(enterpriseAsset.assetCategory, 'Enterprise IP Vault (Laravel)');
      expect(
        enterpriseAsset.getLicenseSummary(),
        contains('Garansi SLA 24 Bulan'),
      );
    });

    test('SharedPreferences (LocalStorageService) saves and loads data properly', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService();

      await storage.saveDockerHost('192.168.1.100');
      expect(await storage.getDockerHost(), '192.168.1.100');

      await storage.saveBookmarkedTitles({'Sistem ERP UMKM (Next.js)'});
      expect(await storage.getBookmarkedTitles(), {'Sistem ERP UMKM (Next.js)'});

      await storage.saveLoginSession(
        email: 'alex.vance@developer.io',
        rememberMe: true,
      );
      expect(await storage.getSavedEmail(), 'alex.vance@developer.io');
      expect(await storage.getRememberMe(), true);
    });
  });
}
