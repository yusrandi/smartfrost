import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// 3-Step horizontal progress indicator for the new dispatch wizard:
/// 1. Coolbox
/// 2. Data ikan
/// 3. Konfirmasi
class DispatchStepIndicator extends StatelessWidget {
  const DispatchStepIndicator({super.key, required this.currentStep});

  /// 1-based index (1, 2, or 3)
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (step: 1, label: 'Coolbox'),
      (step: 2, label: 'Data ikan'),
      (step: 3, label: 'Konfirmasi'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            // Step Node (Circle + Label)
            _StepNode(
              stepNumber: steps[i].step,
              label: steps[i].label,
              isCompleted: steps[i].step < currentStep,
              isActive: steps[i].step == currentStep,
            ),

            // Connecting line to next step
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(top: 13, left: 4, right: 4),
                  color: steps[i].step < currentStep
                      ? AppColors.primary
                      : const Color(0xFFD3E2E6),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.stepNumber,
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  final int stepNumber;
  final String label;
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isReached = isCompleted || isActive;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step Circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isReached ? AppColors.primary : const Color(0xFFE8EEF1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                : Text(
                    '$stepNumber',
                    style: AppTypography.badge.copyWith(
                      color: isReached ? Colors.white : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isReached ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
