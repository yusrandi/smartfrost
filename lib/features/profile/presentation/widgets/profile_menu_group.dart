import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/user_profile.dart';

/// Grouped operational settings and identity options menu card.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({
    super.key,
    required this.profile,
    this.onAccountInfoTap,
    this.onPermissionsTap,
    this.onLogoutTap,
  });

  final UserProfile profile;
  final VoidCallback? onAccountInfoTap;
  final VoidCallback? onPermissionsTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 1. Informasi akun
          _ProfileMenuItem(
            icon: LucideIcons.user,
            title: 'Informasi akun',
            subtitle: 'Role dan identitas pengguna',
            onTap: onAccountInfoTap,
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
          const Divider(),

          // 2. Status sinkronisasi
          _ProfileMenuItem(
            icon: LucideIcons.refreshCw,
            title: 'Status sinkronisasi',
            subtitle: profile.syncStatusDescription,
            trailing: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),

          // 3. Hak akses
          _ProfileMenuItem(
            icon: LucideIcons.shieldCheck,
            title: 'Hak akses',
            subtitle: profile.permissionsDescription,
            onTap: onPermissionsTap,
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
          const Divider(),

          // 4. Keluar dari akun
          _ProfileMenuItem(
            icon: LucideIcons.logOut,
            title: 'Keluar dari akun',
            subtitle: 'Kembali ke pilihan role',
            onTap: onLogoutTap,
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              // Icon in light cyan container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing action
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
