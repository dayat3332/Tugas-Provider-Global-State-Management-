import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/blueprint_model.dart';
import '../providers/blueprint_provider.dart';
import '../services/blueprint_service.dart';

class BlueprintFormScreen extends StatefulWidget {
  final BlueprintModel? blueprint;

  const BlueprintFormScreen({super.key, this.blueprint});

  bool get isEdit => blueprint != null;

  @override
  State<BlueprintFormScreen> createState() => _BlueprintFormScreenState();
}

class _BlueprintFormScreenState extends State<BlueprintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blueprintService = BlueprintService();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  late String _selectedStack;
  late bool _isVerified;
  bool _isLoading = false;

  final List<String> _stacks = [
    'Next.js',
    'Laravel',
    'Flutter',
    'FastAPI',
    'Python AI',
    'React',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.blueprint;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _priceController = TextEditingController(text: b?.price ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _selectedStack = b?.stackLabel ?? 'Next.js';
    _isVerified = b?.isVerified ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBlueprint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String price = _priceController.text.trim();
    if (!price.toLowerCase().startsWith('rp') && !price.toLowerCase().contains('gratis')) {
      price = 'Rp $price';
    }

    final blueprintData = BlueprintModel(
      id: widget.blueprint?.id ?? 0,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      price: price,
      stackLabel: _selectedStack,
      description: _descriptionController.text.trim(),
      isVerified: _isVerified,
    );

    final provider = Provider.of<BlueprintProvider?>(context, listen: false);
    bool success = false;
    if (provider != null) {
      if (widget.isEdit) {
        success = await provider.updateBlueprint(blueprintData);
      } else {
        success = await provider.createBlueprint(blueprintData);
      }
    } else {
      if (widget.isEdit) {
        success = await _blueprintService.updateBlueprint(blueprintData);
      } else {
        success = await _blueprintService.createBlueprint(blueprintData);
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Blueprint "${blueprintData.title}" berhasil diperbarui!'
                : 'Blueprint "${blueprintData.title}" berhasil dipublikasikan!',
          ),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Gagal memperbarui blueprint ke Docker database'
                : 'Gagal menambahkan blueprint ke Docker database',
          ),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Ubah Blueprint' : 'Publikasi Blueprint Baru',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderBanner(),
                    const SizedBox(height: 20),

                    // Card Form
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Judul Blueprint Source Code *'),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Misal: Sistem ERP UMKM Terpadu',
                              icon: Icons.title_rounded,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Judul tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Author / Publisher Studio *'),
                          TextFormField(
                            controller: _authorController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Misal: NecroArch Studio',
                              icon: Icons.verified_user_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Author tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Harga Valuasi Lisensi *'),
                          TextFormField(
                            controller: _priceController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            keyboardType: TextInputType.text,
                            decoration: _inputDecoration(
                              hintText: 'Misal: 2.500.000 atau Rp 2.500.000',
                              icon: Icons.monetization_on_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Harga tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Ekosistem / Tech Stack *'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _stacks.map((stack) {
                              final isSelected = _selectedStack == stack;
                              return ChoiceChip(
                                label: Text(
                                  stack,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _selectedStack = stack);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Deskripsi Teknis Blueprint'),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hintText:
                                  'Jelaskan arsitektur, dependensi utama, dan keunggulan source code ini...',
                              icon: Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // AST Verified Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AST VERIFIED 100%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Telah diaudit lolos uji keamanan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isVerified,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) {
                                  setState(() => _isVerified = val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBlueprint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.isEdit
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.cloud_upload_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.isEdit
                                        ? 'Simpan Perubahan'
                                        : 'Publikasikan ke Docker Database',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dns_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEdit
                      ? 'Mode Edit (Metode Update)'
                      : 'Mode Tambah (Metode Create)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Data tersimpan langsung ke MySQL Database melalui Docker container.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
