import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_assets.dart';
import '../../models/blueprint_model.dart';
import '../../providers/blueprint_provider.dart';
import '../../config/api_config.dart';
import '../../navigation/bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../buyer/home_screen.dart';
import '../buyer/wishlist_screen.dart';
import '../buyer/library_screen.dart';
import '../profile_screen.dart';
import '../blueprint_form_screen.dart';
import '../../ip_detail_screen.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<BlueprintProvider?>(context, listen: false);
      if (provider != null && provider.blueprints.isEmpty && !provider.isLoading) {
        provider.loadBlueprints();
      }
    });
  }

  Future<void> _openCreateForm(BuildContext ctx) async {
    final result = await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => const BlueprintFormScreen(),
      ),
    );
    if (result == true && ctx.mounted) {
      ctx.read<BlueprintProvider>().loadBlueprints();
    }
  }

  Future<void> _openEditForm(BuildContext ctx, BlueprintModel blueprint) async {
    final result = await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlueprintFormScreen(blueprint: blueprint),
      ),
    );
    if (result == true && ctx.mounted) {
      ctx.read<BlueprintProvider>().loadBlueprints();
    }
  }

  Future<void> _confirmDelete(BuildContext ctx, BlueprintModel blueprint) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 24),
            SizedBox(width: 8),
            Text('Hapus Blueprint', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${blueprint.title}" dari database Docker?',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && ctx.mounted) {
      final success =
          await ctx.read<BlueprintProvider>().deleteBlueprint(blueprint.id);
      if (!ctx.mounted) return;
      if (success) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Blueprint "${blueprint.title}" berhasil dihapus'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus blueprint dari Docker database'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  void _showConfigureIpDialog(BuildContext parentContext) {
    final provider = parentContext.read<BlueprintProvider>();
    final controller = TextEditingController(text: ApiConfig.host);
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfigurasi Host Docker API', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan 10.0.2.2 untuk Android Emulator, 127.0.0.1 untuk Desktop/Chrome, atau IP LAN Wi-Fi (misal: 192.168.0.150) untuk HP fisik.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Host / IP Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetApiHost();
            },
            child: const Text('Reset Default'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.updateApiHost(controller.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _navigateToTab(int index) {
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const WishlistScreen();
        break;
      case 2:
        target = const LibraryScreen();
        break;
      case 3:
        target = const ProfileScreen();
        break;
      default:
        target = const HomeScreen();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => target,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGlobalProvider =
        Provider.of<BlueprintProvider?>(context, listen: false) != null;
    if (!hasGlobalProvider) {
      return ChangeNotifierProvider<BlueprintProvider>(
        create: (_) => BlueprintProvider()..loadBlueprints(),
        child: Builder(
          builder: (ctx) => _buildSellScaffold(ctx),
        ),
      );
    }
    return _buildSellScaffold(context);
  }

  Widget _buildSellScaffold(BuildContext context) {
    final provider = context.watch<BlueprintProvider>();
    final blueprints = provider.blueprints;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Blueprint',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              onProfileTap: () => _navigateToTab(3),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.loadBlueprints,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 16),
                          _buildDockerStatusCard(provider),
                          const SizedBox(height: 20),
                          _buildSectionTitle(blueprints.length),
                          const SizedBox(height: 12),
                          if (provider.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (blueprints.isEmpty)
                            _buildEmptyState(context)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: blueprints.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, index) {
                                final bp = blueprints[index];
                                return _buildBlueprintManageCard(context, bp);
                              },
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            BottomNavBar(
              currentIndex: 0,
              onTap: _navigateToTab,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller Studio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manajemen CRUD Blueprint Code',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.primary),
              tooltip: 'Konfigurasi IP Docker',
              onPressed: () => _showConfigureIpDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDockerStatusCard(BlueprintProvider provider) {
    final isConnected = provider.isBackendConnected;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? const Color(0xFFBBF7D0) : const Color(0xFFFECDD3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isConnected ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? 'Docker MySQL Backend Terhubung'
                      : 'Docker Backend Belum Terhubung',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isConnected
                        ? const Color(0xFF15803D)
                        : const Color(0xFFBE123C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Endpoint: ${ApiConfig.baseUrl}',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isConnected
                        ? const Color(0xFF166534)
                        : const Color(0xFF9F1239),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: provider.loadBlueprints,
            tooltip: 'Cek ulang koneksi',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Blueprint ($count)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'Create • Read • Update • Delete',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBlueprintManageCard(BuildContext context, BlueprintModel bp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppSvgIcon(
                  assetName: bp.stackSvg,
                  width: 26,
                  height: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bp.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Publisher: ${bp.author}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bp.stackLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bp.price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Detail button
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IPDetailScreen(
                        title: bp.title,
                        author: bp.author,
                        price: bp.price,
                        blueprint: bp,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textSecondary),
                label: const Text('Detail', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 4),
              // Edit button
              TextButton.icon(
                onPressed: () => _openEditForm(context, bp),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: const Text('Edit', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 4),
              // Delete button
              TextButton.icon(
                onPressed: () => _confirmDelete(context, bp),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                label: const Text('Hapus', style: TextStyle(fontSize: 12, color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Blueprint',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Klik tombol di bawah untuk menambahkan blueprint pertama Anda ke Docker MySQL.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openCreateForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Blueprint'),
            ),
          ],
        ),
      ),
    );
  }
}
