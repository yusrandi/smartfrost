import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_top_header.dart';

/// Base Shell Layout for SmartFrost with:
/// - Persistent top operational app header
/// - Content area supporting child page or indexed tab views
/// - Custom bottom navigation bar with 4 items: Beranda, Kirim/Scan QR, Riwayat, Profil
class MainShellLayout extends StatefulWidget {
  const MainShellLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.userInitials = 'SF',
    this.scanLabel = 'Scan QR',
    this.onTabSelected,
    this.onScanPressed,
    this.onProfilePressed,
  });

  final Widget child;
  final int currentIndex;
  final String userInitials;
  final String scanLabel;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onScanPressed;
  final VoidCallback? onProfilePressed;

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant MainShellLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  void _handleTabTap(int index) {
    setState(() => _selectedIndex = index);
    widget.onTabSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopHeader(
        userInitials: widget.userInitials,
        onProfileTap: widget.onProfilePressed,
      ),
      body: widget.child,
      bottomNavigationBar: _SmartFrostBottomBar(
        selectedIndex: _selectedIndex,
        scanLabel: widget.scanLabel,
        onTabTap: _handleTabTap,
        onScanTap: widget.onScanPressed ?? () {},
      ),
    );
  }
}

class _SmartFrostBottomBar extends StatelessWidget {
  const _SmartFrostBottomBar({
    required this.selectedIndex,
    required this.scanLabel,
    required this.onTabTap,
    required this.onScanTap,
  });

  final int selectedIndex;
  final String scanLabel;
  final ValueChanged<int> onTabTap;
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Beranda (Kiri)
              Expanded(
                child: _NavItem(
                  icon: LucideIcons.house,
                  label: 'Beranda',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTabTap(0),
                ),
              ),

              // 2. Hot Prominent Button: Kirim / Scan QR (Tepat di Tengah Simetris)
              Expanded(
                child: _ProminentScanButton(label: scanLabel, onTap: onScanTap),
              ),

              // 3. Riwayat (Kanan)
              Expanded(
                child: _NavItem(
                  icon: LucideIcons.history,
                  label: 'Riwayat',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTabTap(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prominent elevated center action button for scanning cold-box QR codes.
class _ProminentScanButton extends StatelessWidget {
  const _ProminentScanButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF139BB7),
                      AppColors.primary,
                      Color(0xFF096C84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(
                  LucideIcons.qrCode,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.badge.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: isSelected
                  ? AppTypography.badge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )
                  : AppTypography.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
