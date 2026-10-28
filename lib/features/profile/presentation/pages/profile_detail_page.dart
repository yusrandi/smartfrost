import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../domain/models/user_profile.dart';

/// Full-screen Detail Profile & Account Information Page for a SmartFrost Distributor.
///
/// Presents comprehensive operational identity:
/// 1. Dark Petrol Navy Hero Distributor Identity Card
/// 2. Identity & Contact Information Card
/// 3. Harbor / Island Base & Operational Logistics Hub Card
/// 4. Cold-Chain Access, Privileges & IoT Telemetry Specs Card
/// 5. In-place profile editing for quick updates
class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key, this.profile});

  final UserProfile? profile;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  UserProfile get _activeProfile {
    return AuthSession.instance.currentUser ??
        widget.profile ??
        const UserProfile(
          name: 'Distributor Pangkep',
          organization: 'CV Laut Segar Pangkep',
          location: 'Kabupaten Pangkep',
          accessRoleLabel: 'Akses Pengirim & Penerima',
          permissionsDescription: 'Operasional logistik rantai dingin',
        );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    final current = _activeProfile;
    final nameController = TextEditingController(text: current.name);
    final orgController = TextEditingController(text: current.organization);
    final phoneController = TextEditingController(text: current.phoneNumber);
    String selectedStore = current.storeLocation;

    // Available dock/island options
    final availableDocks = [
      'Dermaga Maccini Baji',
      'Dermaga Biringkassi',
      'Pulau Karanrang',
      'Pulau Sanane',
      'Pulau Jangan-Jangangan',
      'Pulau Kalupu',
      'Pulau Kapoposang',
    ];

    if (!availableDocks.contains(selectedStore) && selectedStore.isNotEmpty) {
      availableDocks.insert(0, selectedStore);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom:
                    MediaQuery.of(modalContext).viewInsets.bottom + AppSpacing.xl,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Handle Bar
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
                    const SizedBox(height: AppSpacing.lg),

                    // Sheet Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            LucideIcons.userCheck,
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
                                'Edit Profil Distributor',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Perbarui identitas & pangkalan operasional',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Field 1: Nama Lengkap
                    Text(
                      'Nama Lengkap / Penanggung Jawab',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.user,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 2: Nama Badan Usaha / Organisasi
                    Text(
                      'Badan Usaha / Kelompok Nelayan',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: orgController,
                      decoration: InputDecoration(
                        hintText: 'Nama usaha atau organisasi',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.building2,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 3: Nomor Telepon / WhatsApp
                    Text(
                      'Nomor Telepon / WhatsApp',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+62 8xx-xxxx-xxxx',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.phone,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 4: Lokasi Pangkalan / Dermaga
                    Text(
                      'Pangkalan Utama / Dermaga',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStore,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.anchor,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      items: availableDocks.toSet().map((dock) {
                        return DropdownMenuItem<String>(
                          value: dock,
                          child: Text(
                            dock,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedStore = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final newOrg = orgController.text.trim();
                          final newPhone = phoneController.text.trim();

                          Navigator.of(sheetContext).pop();

                          await AuthSession.instance.updateProfile(
                            name: newName.isNotEmpty ? newName : null,
                            organization: newOrg.isNotEmpty ? newOrg : null,
                            storeLocation: selectedStore,
                            phoneNumber: newPhone.isNotEmpty ? newPhone : null,
                          );

                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      LucideIcons.circleCheck,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text('Profil distributor berhasil diperbarui!'),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Simpan Perubahan',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        final profile = _activeProfile;
        final distributorId =
            'SF-DIST-${(profile.name.hashCode.abs() % 9000 + 1000)}';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Kembali',
            ),
            title: Text(
              'Informasi Akun Distributor',
              style: AppTypography.cardTitle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  LucideIcons.edit3,
                  size: 20,
                  color: AppColors.primary,
                ),
                tooltip: 'Edit Profil',
                onPressed: () => _showEditProfileBottomSheet(context),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dark Petrol Navy Hero Distributor Identity Card
                _DistributorHeroIdentityCard(
                  profile: profile,
                  distributorId: distributorId,
                  onEditTap: () => _showEditProfileBottomSheet(context),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Data Identitas & Kontak Akun
                _InfoSectionCard(
                  icon: LucideIcons.user,
                  title: 'Identitas & Kontak',
                  subtitle: 'Informasi penanggung jawab distributor resmi',
                  items: [
                    _InfoRowItem(
                      label: 'Nama Lengkap',
                      value: profile.name,
                      icon: LucideIcons.user,
                    ),
                    _InfoRowItem(
                      label: 'Badan Usaha / Organisasi',
                      value: profile.organization,
                      icon: LucideIcons.building2,
                    ),
                    _InfoRowItem(
                      label: 'Email Terdaftar',
                      value: profile.email,
                      icon: LucideIcons.mail,
                    ),
                    _InfoRowItem(
                      label: 'Nomor Kontak / WhatsApp',
                      value: profile.phoneNumber,
                      icon: LucideIcons.phone,
                    ),
                    _InfoRowItem(
                      label: 'ID Distributor',
                      value: distributorId,
                      icon: LucideIcons.hash,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Lokasi Pangkalan & Hub Logistik
                _InfoSectionCard(
                  icon: LucideIcons.anchor,
                  title: 'Pangkalan & Wilayah Operasional',
                  subtitle: 'Titik pelabuhan & hub distribusi cold-chain',
                  items: [
                    _InfoRowItem(
                      label: 'Pangkalan Utama',
                      value: profile.storeLocation,
                      icon: LucideIcons.anchor,
                      valueColor: AppColors.primary,
                    ),
                    _InfoRowItem(
                      label: 'Wilayah Administrasi',
                      value: profile.location,
                      icon: LucideIcons.mapPin,
                    ),
                    _InfoRowItem(
                      label: 'Koordinat GPS Hub',
                      value: profile.coordinatesFormatted,
                      icon: LucideIcons.compass,
                    ),
                    _InfoRowItem(
                      label: 'Tipe Fasilitas',
                      value: 'Cold Storage & Coolbox Loading Dock',
                      icon: LucideIcons.box,
                    ),
                    _InfoRowItem(
                      label: 'Kawasan Laut',
                      value: 'Kepulauan Spermonde, Pangkajene & Kepulauan',
                      icon: LucideIcons.waves,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Konfigurasi Akses & Rantai Dingin
                _InfoSectionCard(
                  icon: LucideIcons.snowflake,
                  title: 'Wewenang & Rantai Dingin',
                  subtitle: 'Integrasi sensor IoT dan kepatuhan cold-chain',
                  items: [
                    _InfoRowItem(
                      label: 'Peran Operasional',
                      value: profile.accessRoleLabel,
                      icon: LucideIcons.shieldCheck,
                    ),
                    _InfoRowItem(
                      label: 'Cakupan Hak Akses',
                      value: profile.permissionsDescription,
                      icon: LucideIcons.keyRound,
                    ),
                    _InfoRowItem(
                      label: 'Telemetri IoT Suhu',
                      value: 'Sensor DS18B20 & GPS Live Leaflet',
                      icon: LucideIcons.thermometerSnowflake,
                    ),
                    _InfoRowItem(
                      label: 'Algoritma FrostScore',
                      value: 'Penilaian Risiko Mutu & Cold-Chain Real-Time',
                      icon: LucideIcons.activity,
                    ),
                    _InfoRowItem(
                      label: 'Status Sinkronisasi',
                      value: profile.syncStatusDescription,
                      icon: LucideIcons.refreshCw,
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick Edit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onPressed: () => _showEditProfileBottomSheet(context),
                    icon: const Icon(
                      LucideIcons.edit3,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Ubah Informasi Profil',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dark Petrol Navy Hero Distributor Identity Card
class _DistributorHeroIdentityCard extends StatelessWidget {
  const _DistributorHeroIdentityCard({
    required this.profile,
    required this.distributorId,
    this.onEditTap,
  });

  final UserProfile profile;
  final String distributorId;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF144E63), // Dark teal petrol navy
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF144E63).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar with Vessel / Ship icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  LucideIcons.ship,
                  size: 28,
                  color: Colors.white,
                ),
              ),

              // Status Pill with Green Dot
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusPill,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80), // Bright green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Distributor Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Distributor Name
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Organization & Store Location
          Text(
            '${profile.organization} • ${profile.storeLocation}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Divider inside Hero
          Divider(color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: AppSpacing.sm),

          // Bottom Stats: Distributor ID & Role Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID DISTRIBUTOR',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distributorId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEditTap,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        LucideIcons.edit2,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Section Card with Header Icon and Key-Value List Items
class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_InfoRowItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),

          // Items List
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    items[i].icon,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  SizedBox(
                    width: 130,
                    child: Text(
                      items[i].label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      items[i].value,
                      textAlign: TextAlign.end,
                      style: AppTypography.bodySmall.copyWith(
                        color: items[i].valueColor ?? AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Divider(
                color: AppColors.borderSubtle,
                height: 1,
                thickness: 0.8,
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRowItem {
  const _InfoRowItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
}
