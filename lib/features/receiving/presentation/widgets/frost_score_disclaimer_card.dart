import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Footnote disclaimer explaining the operational role of FrostScore in the cold chain.
class FrostScoreDisclaimerCard extends StatelessWidget {
  const FrostScoreDisclaimerCard({
    super.key,
    this.message =
        'FrostScore adalah indikator risiko rantai dingin, bukan hasil laboratorium atau sertifikat keamanan pangan.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              LucideIcons.info,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppTypography.caption)),
        ],
      ),
    );
  }
}
