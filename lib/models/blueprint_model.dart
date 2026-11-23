import '../constants/app_assets.dart';

/// ============================================================================
/// IMPLEMENTASI 4 PILAR PBO (PEMROGRAMAN BERORIENTASI OBJEK / OOP)
/// 1. ABSTRACTION (Abstraksi)  : abstract class DigitalCodeAsset
/// 2. ENCAPSULATION (Enkapsulasi): private fields (_id, _title, dll.) + Getters
/// 3. INHERITANCE (Pewarisan)  : BlueprintModel extends DigitalCodeAsset,
///                               EnterpriseBlueprintModel extends BlueprintModel
/// 4. POLYMORPHISM (Polimorfisme): @override getLicenseSummary() & assetCategory
/// ============================================================================

/// [1. ABSTRACTION]: Kelas abstrak sebagai kerangka dasar aset kode digital
abstract class DigitalCodeAsset {
  // [2. ENCAPSULATION]: Atribut private hanya bisa diakses lewat getter
  final int _id;
  final String _title;
  final String _author;
  final String _price;

  const DigitalCodeAsset({
    required int id,
    required String title,
    required String author,
    required String price,
  })  : _id = id,
        _title = title,
        _author = author,
        _price = price;

  // Public Getters untuk membaca atribut private (Enkapsulasi)
  int get id => _id;
  String get title => _title;
  String get author => _author;
  String get price => _price;

  /// Kontrak method abstrak yang wajib diimplementasikan oleh kelas turunan
  String get assetCategory;
  String getLicenseSummary();
  Map<String, dynamic> toJson();
}

/// [3. INHERITANCE]: BlueprintModel mewarisi (extends) DigitalCodeAsset
class BlueprintModel extends DigitalCodeAsset {
  // [2. ENCAPSULATION]: Field private internal BlueprintModel
  final String _stackLabel;
  final String _description;
  final bool _isVerified;
  final DateTime? _createdAt;

  const BlueprintModel({
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required String stackLabel,
    String description = '',
    bool isVerified = true,
    DateTime? createdAt,
  })  : _stackLabel = stackLabel,
        _description = description,
        _isVerified = isVerified,
        _createdAt = createdAt;

  // Getters (Enkapsulasi)
  String get stackLabel => _stackLabel;
  String get description => _description;
  bool get isVerified => _isVerified;
  DateTime? get createdAt => _createdAt;

  /// [4. POLYMORPHISM]: Implementasi spesifik kategori aset berdasarkan stack
  @override
  String get assetCategory {
    final lower = _stackLabel.toLowerCase();
    if (lower.contains('flutter')) return 'Mobile Application Blueprint';
    if (lower.contains('next') || lower.contains('react')) {
      return 'Frontend Web Blueprint';
    }
    if (lower.contains('laravel') || lower.contains('fastapi')) {
      return 'Backend Architecture Blueprint';
    }
    return 'Full-Stack Production Blueprint';
  }

  /// [4. POLYMORPHISM]: Implementasi ringkasan lisensi standar
  @override
  String getLicenseSummary() {
    final status = _isVerified ? 'AST Verified 100%' : 'Unverified';
    return '$title oleh $author [$stackLabel - $status] ($price)';
  }

  factory BlueprintModel.fromJson(Map<String, dynamic> json) {
    return BlueprintModel(
      id: json['id_blueprint'] is int
          ? json['id_blueprint']
          : int.tryParse(json['id_blueprint']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      stackLabel: json['stack_label']?.toString() ?? 'Flutter',
      description: json['description']?.toString() ?? '',
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id_blueprint': id,
      'title': title,
      'author': author,
      'price': price,
      'stack_label': stackLabel,
      'description': description,
      'is_verified': isVerified ? 1 : 0,
    };
  }

  BlueprintModel copyWith({
    int? id,
    String? title,
    String? author,
    String? price,
    String? stackLabel,
    String? description,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return BlueprintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      stackLabel: stackLabel ?? this.stackLabel,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Mengembalikan asset SVG yang sesuai dengan stack teknologi
  String get stackSvg {
    final lower = stackLabel.toLowerCase();
    if (lower.contains('laravel')) return AppAssets.laravel;
    if (lower.contains('next')) return AppAssets.nextjs;
    if (lower.contains('react')) return AppAssets.react;
    if (lower.contains('python')) return AppAssets.python;
    return AppAssets.coding;
  }
}

/// [3. INHERITANCE] & [4. POLYMORPHISM]:
/// Subclass turunan dari BlueprintModel dengan perilaku polimorfik khusus Enterprise
class EnterpriseBlueprintModel extends BlueprintModel {
  final int _slaMonths;

  const EnterpriseBlueprintModel({
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.stackLabel,
    super.description,
    super.isVerified,
    super.createdAt,
    int slaMonths = 12,
  }) : _slaMonths = slaMonths;

  int get slaMonths => _slaMonths;

  @override
  String get assetCategory => 'Enterprise IP Vault ($stackLabel)';

  @override
  String getLicenseSummary() {
    return '${super.getLicenseSummary()} + Garansi SLA $_slaMonths Bulan';
  }
}
