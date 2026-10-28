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

        final fishOptions = formData.fishes.toSet().toList();
        final weightOptions = formData.weights.toSet().toList();

        // Deduplicate distributors uniquely by displayName to prevent Dropdown duplicate assertion errors
        final uniqueDistributors = <String, Distributor>{};
        for (final d in formData.distributors) {
          uniqueDistributors.putIfAbsent(d.displayName, () => d);
        }

        final distributorOptions = uniqueDistributors.keys.toList();

        final matchingDistributor = uniqueDistributors.values.where(
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

          // 1. Jenis Ikan
          _ValidatedDropdownField(
            label: 'Jenis ikan',
            placeholder: 'Pilih jenis ikan',
            value: data.fishType,
            options: fishOptions,
            hasError: _submitted && data.fishType.isEmpty,
            errorMessage: 'Harap pilih jenis ikan',
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

          // 4. Distributor tujuan - Auto-populates penerima and tujuan pulau
          _ValidatedDropdownField(
            label: 'Distributor tujuan',
            placeholder: 'Pilih distributor tujuan',
            value: matchingDistributor?.displayName ?? '',
            options: distributorOptions,
            hasError: _submitted &&
                (data.destinationLocation.isEmpty ||
                    data.receiverName.isEmpty),
            errorMessage: 'Harap pilih distributor tujuan',
            onChanged: (val) {
              final matched = formData.distributors
                  .where((d) => d.displayName == val)
                  .firstOrNull;
              if (matched != null) {
                widget.onDataChanged(
                  data.copyWith(
                    destinationLocation: matched.storeLocation,
                    receiverName: matched.name,
                  ),
                );
              }
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
