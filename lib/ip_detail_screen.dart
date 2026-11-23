import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'constants/app_assets.dart';
import 'models/blueprint_model.dart';
import 'providers/blueprint_provider.dart';
import 'services/blueprint_service.dart';
import 'screens/blueprint_form_screen.dart';

class IPDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String price;
  final BlueprintModel? blueprint;

  const IPDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.price,
    this.blueprint,
  });

  @override
  State<IPDetailScreen> createState() => _IPDetailScreenState();
}

class _IPDetailScreenState extends State<IPDetailScreen> {
  bool _localBookmarked = false;
  bool _localAcquired = false;
  late BlueprintModel? _blueprint;

  @override
  void initState() {
    super.initState();
    _blueprint = widget.blueprint;
  }

  String get _currentTitle => _blueprint?.title ?? widget.title;

  void _toggleBookmark(BlueprintProvider? provider) {
    if (provider != null) {
      provider.toggleBookmark(_currentTitle);
    } else {
      setState(() {
        _localBookmarked = !_localBookmarked;
      });
    }
  }

  void _toggleAcquireIP(BlueprintProvider? provider) {
    if (provider != null) {
      provider.toggleAcquireIP(_currentTitle);
    } else {
      setState(() {
        _localAcquired = !_localAcquired;
      });
    }
  }

  Future<void> _editBlueprint() async {
    if (_blueprint == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlueprintFormScreen(blueprint: _blueprint),
      ),
    );
    if (updated == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteBlueprint() async {
    if (_blueprint == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Blueprint', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus "${_blueprint!.title}" dari Docker database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<BlueprintProvider?>(context, listen: false);
      final success = provider != null
          ? await provider.deleteBlueprint(_blueprint!.id)
          : await BlueprintService().deleteBlueprint(_blueprint!.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blueprint berhasil dihapus'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlueprintProvider?>(context);
    final title = _currentTitle;
    final author = _blueprint?.author ?? widget.author;
    final price = _blueprint?.price ?? widget.price;
    final isBookmarked =
        provider != null ? provider.isBookmarked(title) : _localBookmarked;
    final isAcquired =
        provider != null ? provider.isAcquired(title) : _localAcquired;
    final description = (_blueprint != null && _blueprint!.description.isNotEmpty)
        ? _blueprint!.description
        : 'Enterprise Resource Planning terpadu dan arsitektur kode siap produksi yang telah melalui audit statis otomatis.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Blueprint & IP',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_blueprint != null && _blueprint!.id > 0) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Edit Blueprint',
              onPressed: _editBlueprint,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
              tooltip: 'Hapus Blueprint',
              onPressed: _deleteBlueprint,
            ),
          ],
          IconButton(
            onPressed: () => _toggleBookmark(provider),
            tooltip: 'Bookmark Blueprint',
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppColors.orange : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card (Passing Data: title, author, price)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppSvgIcon(
                                    assetName: AppAssets.centang,
                                    width: 14,
                                    height: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'AST VERIFIED 100%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _blueprint != null ? _blueprint!.stackLabel : 'Full IP Transfer',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBEAFE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.code_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Publisher: $author',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        const Text(
                          'Valuasi Akuisisi Lisensi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi Blueprint
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Deskripsi & Spesifikasi Kode',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NecroEngine AST Guarantee Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppSvgIcon(
                              assetName: AppAssets.helt,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'NecroEngine AST Guarantee',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Repositori ini telah diaudit secara otomatis menggunakan analisis Abstract Syntax Tree (AST), bebas kerentanan kritis, lengkap dengan dokumentasi deployment & hak komersial penuh.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tombol Aksi Stateful (Provider Global State)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _toggleBookmark(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBookmarked
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFEFF6FF),
                              foregroundColor: isBookmarked
                                  ? const Color(0xFFD97706)
                                  : AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    isBookmarked ? 'Saved' : 'Bookmark',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _toggleAcquireIP(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAcquired
                                  ? AppColors.green
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isAcquired
                                      ? Icons.check_circle_rounded
                                      : Icons.shopping_bag_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isAcquired ? 'IP Acquired' : 'Acquire IP',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
