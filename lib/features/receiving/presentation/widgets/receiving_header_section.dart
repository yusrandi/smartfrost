import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Header section displaying the operational receiving title and subtitle.
class ReceivingHeaderSection extends StatelessWidget {
  const ReceivingHeaderSection({
    super.key,
    this.distributorName,
    this.title = 'Penerimaan ikan',
    this.subtitle = 'Periksa data batch sebelum melakukan serah terima.',
  });

  final String? distributorName;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (distributorName != null && distributorName!.isNotEmpty) ...[
          Text(distributorName!.toUpperCase(), style: AppTypography.overline),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(title, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.pageSubtitle),
      ],
    );
  }
}
