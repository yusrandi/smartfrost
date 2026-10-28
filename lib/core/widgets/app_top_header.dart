import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'smart_frost_logo.dart';

/// Top header bar matching the SmartFrost operational interface:
/// - Left: Vector SmartFrost brand logo
/// - Right: Online connection indicator, notification bell, and user avatar ("DB")
class AppTopHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppTopHeader({
    super.key,
    this.userInitials = 'DB',
    this.isOnline = true,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final String userInitials;
  final bool isOnline;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppSpacing.lg,
      title: const SmartFrostLogo(height: 32),
      actions: [
        // Online / Sync status indicator pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.radiusPill,
          ),
          child: Icon(
            LucideIcons.wifi,
            size: 16,
            color: isOnline ? AppColors.success : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Notification Bell Button
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.headerActionBg,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  LucideIcons.bell,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                if (hasNotification)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // User Avatar Circle
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.avatarNavy,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              userInitials,
              style: AppTypography.badge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
      ],
    );
  }
}
