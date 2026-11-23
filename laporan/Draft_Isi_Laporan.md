# Draft Isi Laporan TUBES PM1 - CodeNecromancer

## B. Deskripsi Proyek
CodeNecromancer adalah aplikasi Flutter untuk menampilkan dan mengelola data blueprint. Data blueprint diambil melalui HTTP dari API PHP dan tabel MySQL `tb_blueprints`. Fungsi pengambilan data menggunakan endpoint hasil `ApiConfig.filterEndpoint`.

**Kode asli — `lib/services/blueprint_service.dart:47-78`**
```dart
/// READ (Asynchronous): Mengambil seluruh blueprint dari MySQL melalui Docker backend
@override
Future<List<BlueprintModel>> getBlueprints({
  String? search,
  String? stack,
}) async {
  try {
    final uri = ApiConfig.filterEndpoint(search: search, stack: stack);
    final response = await http.get(uri).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final list = decoded['data'] as List;
        return list
            .map((item) =>
                BlueprintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return defaultBlueprints;
  } catch (e) {
    return defaultBlueprints;
  }
}
```

<mark>[Sisipkan screenshot: Halaman daftar blueprint aplikasi]</mark>

## C. Fitur & Peran Pengguna
### 1. Pengelolaan blueprint (CRUD)
Aplikasi menyediakan operasi tambah, ubah, dan hapus blueprint melalui HTTP POST.

**Kode asli — `lib/services/blueprint_service.dart:81-114`**
```dart
/// CREATE (Asynchronous): Menambahkan blueprint baru ke database
@override
Future<bool> createBlueprint(BlueprintModel blueprint) async {
  try {
    final response = await http
        .post(
          ApiConfig.createEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(blueprint.toJson()),
        )
        .timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['success'] == true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

/// UPDATE (Asynchronous): Memperbarui blueprint yang sudah ada di database
@override
Future<bool> updateBlueprint(BlueprintModel blueprint) async {
  try {
    final response = await http
        .post(
          ApiConfig.updateEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(blueprint.toJson()),
        )
        .timeout(_timeoutDuration);
```

**Kode asli — `lib/services/blueprint_service.dart:127-147`**
```dart
/// DELETE (Asynchronous): Menghapus blueprint berdasarkan ID dari database
@override
Future<bool> deleteBlueprint(int id) async {
  try {
    final response = await http
        .post(
          ApiConfig.deleteEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_blueprint': id}),
        )
        .timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['success'] == true;
    }
    return false;
  } catch (e) {
    return false;
  }
}
```

### 2. Pencarian, filter, dan pengurutan
Provider memfilter blueprint menurut kategori, teks pada judul/penulis/stack/deskripsi, lalu mengurutkan opsi `Terbaru`.

**Kode asli — `lib/providers/blueprint_provider.dart:81-98`**
```dart
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
```

### 3. Wishlist dan akuisisi lisensi
State global menyediakan himpunan judul yang ditandai dan judul yang diakuisisi.

**Kode asli — `lib/providers/blueprint_provider.dart:30-44`**
```dart
// State Global Bookmark (Wishlist) & Akuisisi Lisensi IP
final Set<String> _bookmarkedTitles = {};
final Set<String> _acquiredTitles = {};

Set<String> get bookmarkedTitles => Set.unmodifiable(_bookmarkedTitles);
Set<String> get acquiredTitles => Set.unmodifiable(_acquiredTitles);
```

<mark>[Sisipkan screenshot: Filter/pencarian atau form pengelolaan blueprint]</mark>

## D. Arsitektur & Teknologi
### 1. Dependensi
Proyek memakai Flutter, `http`, `provider`, dan `shared_preferences`.

**Kode asli — `pubspec.yaml:30-40`**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.17
  http: ^1.6.0
  provider: ^6.1.5+1
  shared_preferences: ^2.5.6
```

### 2. State management
`BlueprintProvider` mewarisi `ChangeNotifier`, menyimpan service API dan local storage.

**Kode asli — `lib/providers/blueprint_provider.dart:7-18`**
```dart
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
}
```

### 3. Model dan PBO
`DigitalCodeAsset` adalah kelas abstrak. `BlueprintModel` mewarisinya dan mengimplementasikan `assetCategory`.

**Kode asli — `lib/models/blueprint_model.dart:12-18,36-43`**
```dart
abstract class DigitalCodeAsset {
  final int _id;
  final String _title;
  final String _author;
  final String _price;

  String get assetCategory;
  String getLicenseSummary();
  Map<String, dynamic> toJson();
}

/// [3. INHERITANCE]: BlueprintModel mewarisi (extends) DigitalCodeAsset
class BlueprintModel extends DigitalCodeAsset {
```

### 4. Konfigurasi API
Host Android default `10.0.2.2`; platform lain `127.0.0.1`. Endpoint CRUD disusun dari `baseUrl`.

**Kode asli — `lib/config/api_config.dart:10-17,45-57`**
```dart
static String get _defaultHost {
  if (kIsWeb) return '127.0.0.1';
  try {
    if (Platform.isAndroid) return '10.0.2.2';
  } catch (_) {}
  return '127.0.0.1';
}

static String get baseUrl {
  if (_port == 80) {
    return 'http://$_host/$_basePath';
  }
  return 'http://$_host:$_port/$_basePath';
}

static Uri get readEndpoint => Uri.parse('$baseUrl/read.php');
static Uri get createEndpoint => Uri.parse('$baseUrl/create.php');
static Uri get updateEndpoint => Uri.parse('$baseUrl/update.php');
static Uri get deleteEndpoint => Uri.parse('$baseUrl/delete.php');
```

## E. Firebase

## F. Google Login

## G. Push Notification

## H. Database & API
### 1. Database
Database bernama `db_code_necromancer`. Tabel `tb_blueprints` menyimpan ID, judul, penulis, harga, stack, deskripsi, status verifikasi, dan waktu dibuat.

**Kode asli — `database/init.sql:1-16`**
```sql
CREATE DATABASE IF NOT EXISTS `db_code_necromancer`;
USE `db_code_necromancer`;

CREATE TABLE IF NOT EXISTS `tb_blueprints` (
  `id_blueprint` INT(11) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `author` VARCHAR(255) NOT NULL,
  `price` VARCHAR(100) NOT NULL,
  `stack_label` VARCHAR(100) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `is_verified` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_blueprint`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 2. API Read dan filter
`read.php` menerima parameter `search`, `stack`, dan `id`; kemudian mengembalikan JSON dengan `success`, `total`, dan `data`.

**Kode asli — `htdocs/api_blueprint/read.php:4-26,40-44`**
```php
$search = isset($_GET['search']) ? mysqli_real_escape_string($koneksi, trim($_GET['search'])) : '';
$stack  = isset($_GET['stack']) ? mysqli_real_escape_string($koneksi, trim($_GET['stack'])) : '';
$id     = isset($_GET['id']) ? (int)$_GET['id'] : 0;

if (!empty($search)) {
    $whereClauses[] = "(title LIKE '%$search%' OR author LIKE '%$search%' OR description LIKE '%$search%' OR stack_label LIKE '%$search%')";
}

if (!empty($stack) && strtolower($stack) !== 'semua' && strtolower($stack) !== 'all') {
    $whereClauses[] = "LOWER(stack_label) = LOWER('$stack')";
}

$sql = "SELECT * FROM tb_blueprints";
if (count($whereClauses) > 0) {
    $sql .= " WHERE " . implode(" AND ", $whereClauses);
}
$sql .= " ORDER BY id_blueprint DESC";

echo json_encode([
    "success" => true,
    "total" => count($data),
    "data" => $data
]);
```

### 3. API Create
`create.php` membaca payload JSON atau `$_POST`, memvalidasi judul, lalu menjalankan `INSERT`.

**Kode asli — `htdocs/api_blueprint/create.php:4-15,17-43`**
```php
$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}

$title       = isset($input['title']) ? mysqli_real_escape_string($koneksi, trim($input['title'])) : '';
$author      = isset($input['author']) ? mysqli_real_escape_string($koneksi, trim($input['author'])) : '';
$price       = isset($input['price']) ? mysqli_real_escape_string($koneksi, trim($input['price'])) : '';
$stackLabel  = isset($input['stack_label']) ? mysqli_real_escape_string($koneksi, trim($input['stack_label'])) : 'Laravel';

if (empty($title)) {
    echo json_encode([
        "success" => false,
        "message" => "Judul blueprint tidak boleh kosong"
    ]);
    exit();
}

$sql = "INSERT INTO tb_blueprints (title, author, price, stack_label, description, is_verified) 
        VALUES ('$title', '$author', '$price', '$stackLabel', '$description', '$isVerified')";

$result = mysqli_query($koneksi, $sql);

if ($result) {
    $newId = mysqli_insert_id($koneksi);
    echo json_encode([
        "success" => true,
        "message" => "Blueprint berhasil ditambahkan",
        "id_blueprint" => $newId
    ]);
}
```

### 4. Endpoint
- `htdocs/api_blueprint/read.php`
- `htdocs/api_blueprint/create.php`
- `htdocs/api_blueprint/update.php`
- `htdocs/api_blueprint/delete.php`

<mark>[Sisipkan screenshot: Struktur tabel tb_blueprints pada phpMyAdmin]</mark>
<mark>[Sisipkan screenshot: Respons endpoint read.php atau create.php]</mark>
