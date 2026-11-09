import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/services/firestore_master_data_service.dart';
import '../../domain/models/new_dispatch_data.dart';

/// Step 2: Input fish cargo parameters, logistics route, and receiving party,
/// equipped with initial placeholder prompts and strict validation.
class DispatchStepFishData extends StatefulWidget {
  const DispatchStepFishData({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onBack,
    required this.onNext,
  });

  final NewDispatchData data;
  final ValueChanged<NewDispatchData> onDataChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<DispatchStepFishData> createState() => _DispatchStepFishDataState();
}

class _DispatchStepFishDataState extends State<DispatchStepFishData> {
  bool _submitted = false;
  final Set<String> _customFishes = {};

  Future<void> _handleAddNewFish(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _customFishes.add(trimmed);
    });
    // Persist to Firebase RTDB master_fishes
    FirestoreMasterDataService.instance.addFishType(trimmed);

    // Update dispatch form data
    widget.onDataChanged(widget.data.copyWith(fishType: trimmed));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jenis ikan "$trimmed" berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddFishDialog(BuildContext context, [String? initialText]) async {
    final textController = TextEditingController(text: initialText ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  LucideIcons.fish,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tambah Jenis Ikan',
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan nama jenis ikan yang ingin ditambahkan ke daftar muatan:',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Jenis Ikan',
                    hintText: 'Misal: Ikan Kakap Putih, Ikan Tuna...',
                    hintStyle: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: Color(0xFF00A9CE),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama jenis ikan tidak boleh kosong';
                    }
                    if (val.trim().length < 3) {
                      return 'Nama jenis ikan minimal 3 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Batal',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogCtx, textController.text.trim());
                }
              },
              child: const Text('Simpan & Pilih'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _handleAddNewFish(result);
    }
  }

  void _validateAndProceed() {
    final hasFish = widget.data.fishType.isNotEmpty;
    final hasWeight = widget.data.weightRange.isNotEmpty;
    final hasOrigin = widget.data.originLocation.isNotEmpty;
    final hasDestination = widget.data.destinationLocation.isNotEmpty;
    final hasReceiver = widget.data.receiverName.isNotEmpty;

    if (!hasFish ||
        !hasWeight ||
        !hasOrigin ||
        !hasDestination ||
        !hasReceiver) {
      setState(() => _submitted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Mohon lengkapi seluruh data muatan sebelum melanjutkan.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return StreamBuilder<MasterFormData>(
      stream: FirestoreMasterDataService.instance.streamFormData(),
      initialData: const MasterFormData(
        fishes: FirestoreMasterDataService.defaultFishes,
        weights: FirestoreMasterDataService.defaultWeights,
        distributors: FirestoreMasterDataService.defaultDistributors,
      ),
      builder: (context, snapshot) {
        final formData = snapshot.data ??
            const MasterFormData(
              fishes: FirestoreMasterDataService.defaultFishes,
              weights: FirestoreMasterDataService.defaultWeights,
              distributors: FirestoreMasterDataService.defaultDistributors,
            );

        final fishOptions = (Set<String>.from(formData.fishes)..addAll(_customFishes))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (data.fishType.isNotEmpty && !fishOptions.contains(data.fishType)) {
          fishOptions.add(data.fishType);
          fishOptions.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        }
        final weightOptions = formData.weights.toSet().toList();

        // Deduplicate distributors uniquely by displayName to prevent Dropdown duplicate assertion errors
        final uniqueDistributors = <String, Distributor>{};
        for (final d in formData.distributors) {
          uniqueDistributors.putIfAbsent(d.displayName, () => d);
        }

        // Sort distributors ascending (A-Z) by display name
        final sortedDistributors = uniqueDistributors.values.toList()
          ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

        final matchingDistributor = sortedDistributors.where(
          (d) =>
              d.name == data.receiverName &&
              d.storeLocation == data.destinationLocation,
        ).firstOrNull;

        return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with fish icon, title, and subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  LucideIcons.fish,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data muatan',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lengkapi informasi untuk ketertelusuran batch.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 0. Pengirim (Distributor) - Auto-filled
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengirim (Distributor)',
                style: AppTypography.cardSubtitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.building2,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.senderName,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Akun distributor Anda (terisi otomatis)',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Otomatis',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 1. Jenis Ikan (Searchable, Sorted A-Z, & Can Add Custom Fish)
          _SearchableFishField(
            label: 'Jenis ikan',
            placeholder: 'Pilih jenis ikan',
            value: data.fishType,
            options: fishOptions,
            hasError: _submitted && data.fishType.isEmpty,
            errorMessage: 'Harap pilih jenis ikan',
            onAddNew: () => _showAddFishDialog(context),
            onQuickAdd: (name) => _handleAddNewFish(name),
            onChanged: (val) {
              widget.onDataChanged(data.copyWith(fishType: val));
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Berat ikan (kg)
          _ValidatedDropdownField(
            label: 'Berat ikan (kg)',
            placeholder: 'Pilih berat ikan',
            value: data.weightRange,
            options: weightOptions,
            hasError: _submitted && data.weightRange.isEmpty,
            errorMessage: 'Harap pilih berat ikan',
            onChanged: (val) {
              widget.onDataChanged(data.copyWith(weightRange: val));
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Lokasi awal (Terkunci otomatis sesuai lokasi toko/dermaga distributor)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi awal',
                style: AppTypography.cardSubtitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _submitted && data.originLocation.isEmpty
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFE2E8F0),
                    width: _submitted && data.originLocation.isEmpty
                        ? 1.5
                        : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.mapPin,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.originLocation.isNotEmpty
                                ? data.originLocation
                                : 'Lokasi toko/dermaga belum ditentukan',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Lokasi toko/dermaga distributor Anda (terisi otomatis)',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Otomatis',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_submitted && data.originLocation.isEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Lokasi awal distributor belum terisi di profil',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFFDC2626),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. Distributor tujuan - Auto-populates penerima and tujuan pulau (searchable & sorted A-Z)
          _SearchableDistributorField(
            label: 'Distributor tujuan',
            placeholder: 'Pilih distributor tujuan',
            selected: matchingDistributor,
            distributors: sortedDistributors,
            hasError: _submitted &&
                (data.destinationLocation.isEmpty ||
                    data.receiverName.isEmpty),
            errorMessage: 'Harap pilih distributor tujuan',
            onChanged: (matched) {
              widget.onDataChanged(
                data.copyWith(
                  destinationLocation: matched.storeLocation,
                  receiverName: matched.name,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // 5. Penerima & Lokasi Tujuan (Terisi otomatis dari distributor tujuan)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penerima & Lokasi tujuan',
                style: AppTypography.cardSubtitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _submitted &&
                            (data.receiverName.isEmpty ||
                                data.destinationLocation.isEmpty)
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFE2E8F0),
                    width: _submitted &&
                            (data.receiverName.isEmpty ||
                                data.destinationLocation.isEmpty)
                        ? 1.5
                        : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.userCheck,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.receiverName.isNotEmpty
                                ? data.receiverName
                                : 'Belum memilih distributor tujuan',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: data.receiverName.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            data.destinationLocation.isNotEmpty
                                ? 'Tujuan: ${data.destinationLocation} (terisi otomatis)'
                                : 'Nama penerima dan pulau tujuan terisi otomatis saat memilih distributor',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Otomatis',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_submitted &&
                  (data.receiverName.isEmpty ||
                      data.destinationLocation.isEmpty)) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 13,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Penerima dan tujuan akan terisi otomatis setelah memilih distributor di atas',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFFDC2626),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sensor & GPS Disclaimer Note Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F8),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFCBE8EF), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.thermometer,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    'Data suhu dan GPS hanya akan ditampilkan jika perangkat sensor terhubung. Aplikasi tidak membuat data sensor simulasi.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons: Kembali vs Tinjau data →
          Row(
            children: [
              // Kembali
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(
                      color: Color(0xFFD0D7DE),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Kembali',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Tinjau data → (validates all fields before proceeding)
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tinjau data',
                        style: AppTypography.cardTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(LucideIcons.arrowRight, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
);
}
}

class _ValidatedDropdownField extends StatelessWidget {
  const _ValidatedDropdownField({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hasError = false,
    this.errorMessage,
  });

  final String label;
  final String placeholder;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // Strictly deduplicate options to guarantee uniqueness for DropdownButton assertion
    final uniqueOptions = options.toSet().toList();
    final isSelected = value.isNotEmpty && uniqueOptions.contains(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.badge.copyWith(
            color: hasError ? const Color(0xFFDC2626) : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFDC2626)
                  : (isSelected
                        ? const Color(0xFF00A9CE)
                        : const Color(0xFFCBD5E1)),
              width: hasError ? 1.5 : 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isSelected ? value : null,
              hint: Text(
                placeholder,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                LucideIcons.chevronDown,
                size: 20,
                color: hasError
                    ? const Color(0xFFDC2626)
                    : AppColors.textSecondary,
              ),
              items: uniqueOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 13,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Text(
                errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SearchableDistributorField extends StatelessWidget {
  const _SearchableDistributorField({
    required this.label,
    required this.placeholder,
    required this.selected,
    required this.distributors,
    required this.onChanged,
    this.hasError = false,
    this.errorMessage,
  });

  final String label;
  final String placeholder;
  final Distributor? selected;
  final List<Distributor> distributors;
  final ValueChanged<Distributor> onChanged;
  final bool hasError;
  final String? errorMessage;

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _DistributorSearchSheet(
          distributors: distributors,
          selected: selected,
          onSelected: (distributor) {
            Navigator.pop(sheetContext);
            onChanged(distributor);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selected != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.badge.copyWith(
            color: hasError ? const Color(0xFFDC2626) : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _openSearchSheet(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : (isSelected
                        ? const Color(0xFF00A9CE)
                        : const Color(0xFFCBD5E1)),
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSelected ? selected!.displayName : placeholder,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  LucideIcons.chevronsUpDown,
                  size: 18,
                  color: hasError
                      ? const Color(0xFFDC2626)
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 13,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Text(
                errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DistributorSearchSheet extends StatefulWidget {
  const _DistributorSearchSheet({
    required this.distributors,
    required this.selected,
    required this.onSelected,
  });

  final List<Distributor> distributors;
  final Distributor? selected;
  final ValueChanged<Distributor> onSelected;

  @override
  State<_DistributorSearchSheet> createState() => _DistributorSearchSheetState();
}

class _DistributorSearchSheetState extends State<_DistributorSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.distributors.where((d) {
      if (query.isEmpty) return true;
      return d.name.toLowerCase().contains(query) ||
          d.storeLocation.toLowerCase().contains(query) ||
          d.displayName.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    LucideIcons.building2,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Distributor Tujuan',
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Cari dan pilih lokasi distributor penerima',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: AppColors.textSecondary,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama distributor atau dermaga...',
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        color: AppColors.textSecondary,
                        splashRadius: 16,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: Color(0xFF00A9CE),
                    width: 1.5,
                  ),
                ),
              ),
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // List Count / Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  'Distributor (${filtered.length})',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  'Urut A-Z',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable list or empty state
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.searchX,
                            size: 28,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Distributor tidak ditemukan',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Coba kata kunci pencarian nama atau dermaga lain',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = widget.selected != null &&
                          widget.selected!.name == item.name &&
                          widget.selected!.storeLocation == item.storeLocation;

                      return InkWell(
                        onTap: () => widget.onSelected(item),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0FDF4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.building2,
                                    size: 16,
                                    color: isSelected
                                        ? const Color(0xFF16A34A)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTypography.body.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected
                                            ? const Color(0xFF15803D)
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.mapPin,
                                          size: 12,
                                          color: isSelected
                                              ? const Color(0xFF16A34A)
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.storeLocation.isNotEmpty
                                                ? item.storeLocation
                                                : 'Lokasi belum ditentukan',
                                            style: AppTypography.caption.copyWith(
                                              fontSize: 11,
                                              color: isSelected
                                                  ? const Color(0xFF16A34A)
                                                  : AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  LucideIcons.check,
                                  size: 18,
                                  color: Color(0xFF16A34A),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _SearchableFishField extends StatelessWidget {
  const _SearchableFishField({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.onAddNew,
    required this.onQuickAdd,
    this.hasError = false,
    this.errorMessage,
  });

  final String label;
  final String placeholder;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddNew;
  final ValueChanged<String> onQuickAdd;
  final bool hasError;
  final String? errorMessage;

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _FishSearchSheet(
          options: options,
          selected: value,
          onSelected: (fish) {
            Navigator.pop(sheetContext);
            onChanged(fish);
          },
          onAddNew: () {
            Navigator.pop(sheetContext);
            onAddNew();
          },
          onQuickAdd: (fishName) {
            Navigator.pop(sheetContext);
            onQuickAdd(fishName);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = value.isNotEmpty && options.contains(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.badge.copyWith(
                color: hasError ? const Color(0xFFDC2626) : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onAddNew,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.plusCircle,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah baru',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _openSearchSheet(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : (isSelected
                        ? const Color(0xFF00A9CE)
                        : const Color(0xFFCBD5E1)),
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSelected ? value : placeholder,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  LucideIcons.chevronsUpDown,
                  size: 18,
                  color: hasError
                      ? const Color(0xFFDC2626)
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 13,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Text(
                errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FishSearchSheet extends StatefulWidget {
  const _FishSearchSheet({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.onAddNew,
    required this.onQuickAdd,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddNew;
  final ValueChanged<String> onQuickAdd;

  @override
  State<_FishSearchSheet> createState() => _FishSearchSheetState();
}

class _FishSearchSheetState extends State<_FishSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.options.where((fish) {
      if (query.isEmpty) return true;
      return fish.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final exactMatch = widget.options.any(
      (fish) => fish.trim().toLowerCase() == query,
    );
    final canQuickAdd = query.isNotEmpty && !exactMatch;

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    LucideIcons.fish,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Jenis Ikan',
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Pilih atau tambahkan jenis ikan baru jika belum ada',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: AppColors.textSecondary,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari atau ketik nama jenis ikan...',
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        color: AppColors.textSecondary,
                        splashRadius: 16,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: Color(0xFF00A9CE),
                    width: 1.5,
                  ),
                ),
              ),
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Quick Add Card if query doesn't exist
          if (canQuickAdd) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: InkWell(
                onTap: () => widget.onQuickAdd(_searchController.text.trim()),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.plus,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              color: const Color(0xFF1E40AF),
                            ),
                            children: [
                              const TextSpan(text: 'Tambahkan '),
                              TextSpan(
                                text: '"${_searchController.text.trim()}"',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(text: ' sebagai jenis ikan baru'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // List Count / Info & Add Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  'Jenis Ikan (${filtered.length})',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onAddNew,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.plus,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Tambah manual',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable list
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.fishOff,
                            size: 28,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Ikan tidak ditemukan',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol tambah di atas untuk menambahkan jenis ikan ini ke daftar.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = widget.selected == item;

                      return InkWell(
                        onTap: () => widget.onSelected(item),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0FDF4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.fish,
                                    size: 16,
                                    color: isSelected
                                        ? const Color(0xFF16A34A)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? const Color(0xFF15803D)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  LucideIcons.check,
                                  size: 18,
                                  color: Color(0xFF16A34A),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
