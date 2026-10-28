import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/smart_frost_logo.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../data/mock/mock_profile_data.dart';
import '../../domain/models/user_profile.dart';
import '../widgets/demo_version_card.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_menu_group.dart';
import 'profile_detail_page.dart';

/// User Profile Screen displaying operator credentials, synchronization status,
/// access level, and system version notes.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile,
    this.isDispatch = true,
    this.onLogoutPressed,
  });

  final UserProfile? profile;
  final bool isDispatch;
  final VoidCallback? onLogoutPressed;

  UserProfile get _effectiveProfile {
    if (profile != null) return profile!;
    if (AuthSession.instance.currentUser != null) {
      return AuthSession.instance.currentUser!;
    }
    return isDispatch
        ? MockProfileData.dispatchProfile
        : MockProfileData.receivingProfile;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        final activeProfile = _effectiveProfile;
        final canPop = Navigator.of(context).canPop();

        void openProfileDetail() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileDetailPage(profile: activeProfile),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: canPop
                ? IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Kembali',
                  )
                : null,
            title: const SmartFrostLogo(height: 30),
            titleSpacing: canPop ? 0 : AppSpacing.lg,
            actions: [
              // Online / Sync status indicator pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.radiusPill,
                ),
                child: const Icon(
                  LucideIcons.wifi,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
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
                // Section 1: Header Context
                Text('AKUN', style: AppTypography.overline),
                const SizedBox(height: AppSpacing.xs),
                Text('Profil pengguna', style: AppTypography.pageTitle),
                const SizedBox(height: AppSpacing.lg),

                // Section 2: Profile Hero Card
                ProfileHeroCard(
                  profile: activeProfile,
                  onTap: openProfileDetail,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Section 3: Operational Settings & Permissions Menu
                ProfileMenuGroup(
                  profile: activeProfile,
                  onAccountInfoTap: openProfileDetail,
                  onLogoutTap: onLogoutPressed ??
                      () async {
                        await AuthSession.instance.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AuthPage(initialIsLogin: true),
                            ),
                            (route) => false,
                          );
                        }
                      },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Section 4: Demo / Offline Environment Note
                const DemoVersionCard(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}
