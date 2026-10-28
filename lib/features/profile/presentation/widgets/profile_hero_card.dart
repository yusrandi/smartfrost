import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/user_profile.dart';

/// Top hero card on Profile screen presenting user identity, role, and organization.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.profile, this.onTap});

  final UserProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Center(
        child: Column(
          children: [
            // Avatar Vessel/Ship Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                LucideIcons.ship,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // User Name
            Text(
              profile.name,
              style: AppTypography.pageTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Organization & Location
            Text(
              profile.organizationLocation,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Access Role Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: AppRadius.radiusPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.shieldCheck,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    profile.accessRoleLabel,
                    style: AppTypography.badge.copyWith(
                      color: AppColors.successText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat detail profil',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
