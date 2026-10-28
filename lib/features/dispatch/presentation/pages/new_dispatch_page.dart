import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../data/services/firestore_dispatch_service.dart';
import '../../domain/models/new_dispatch_data.dart';
import 'dispatch_tracking_page.dart';
import '../widgets/dispatch_step_confirmation.dart';
import '../widgets/dispatch_step_coolbox.dart';
import '../widgets/dispatch_step_fish_data.dart';
import '../widgets/dispatch_step_indicator.dart';

/// Multi-step form wizard for creating a new fish batch dispatch:
/// - Step 1: Scan QR / Select Coolbox
/// - Step 2: Cargo & Route Information
/// - Step 3: Confirmation & Sensor Handshake Review
class NewDispatchPage extends StatefulWidget {
  const NewDispatchPage({
    super.key,
    this.initialData = const NewDispatchData(),
    this.onDispatchCreated,
  });

  final NewDispatchData initialData;
  final ValueChanged<NewDispatchData>? onDispatchCreated;

  @override
  State<NewDispatchPage> createState() => _NewDispatchPageState();
}

class _NewDispatchPageState extends State<NewDispatchPage> {
  late int _currentStep;
  late NewDispatchData _formData;

  @override
  void initState() {
    super.initState();
    _currentStep = 1;
    final activeUser = AuthSession.instance.currentUser;
    final initialCoolbox = widget.initialData.coolboxId.isNotEmpty
        ? widget.initialData.coolboxId
        : 'SFR-CB-042';
    final initialBatch = widget.initialData.batchId.isNotEmpty
        ? widget.initialData.batchId
        : NewDispatchData.generateBatchId(coolboxId: initialCoolbox);

    _formData = widget.initialData.copyWith(
      coolboxId: initialCoolbox,
      coolboxIds: [initialCoolbox],
      batchId: initialBatch,
      senderName: widget.initialData.senderName.isNotEmpty
          ? widget.initialData.senderName
          : (activeUser != null && activeUser.organization.isNotEmpty
                ? activeUser.organization
                : (activeUser?.name ?? '-')),
      originLocation: widget.initialData.originLocation.isNotEmpty
          ? widget.initialData.originLocation
          : (activeUser?.storeLocation ?? '-'),
    );
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    }
  }

  Future<void> _handleConfirm() async {
    widget.onDispatchCreated?.call(_formData);
    await FirestoreDispatchService.instance.saveDispatch(_formData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Pengiriman batch ${_formData.batchId} berhasil dibuat!',
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    // Navigate to live sea route tracking page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DispatchTrackingPage(data: _formData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget stepWidget;

    switch (_currentStep) {
      case 2:
        stepWidget = DispatchStepFishData(
          key: const ValueKey('step_2'),
          data: _formData,
          onDataChanged: (updated) => setState(() => _formData = updated),
          onBack: _handleBack,
          onNext: _handleNext,
        );
      case 3:
        stepWidget = DispatchStepConfirmation(
          key: const ValueKey('step_3'),
          data: _formData,
          onEditData: () => setState(() => _currentStep = 2),
          onConfirmSend: _handleConfirm,
        );
      case 1:
      default:
        stepWidget = DispatchStepCoolbox(
          key: const ValueKey('step_1'),
          selectedCoolboxId: _formData.coolboxId,
          onCoolboxChanged: (id) => setState(() {
            _formData = _formData.copyWith(
              coolboxId: id,
              coolboxIds: [id],
              batchId: NewDispatchData.generateBatchId(coolboxId: id),
            );
          }),
          onNext: _handleNext,
        );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: InkWell(
              onTap: _handleBack,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Pengiriman baru',
          style: AppTypography.cardTitle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Online indicator
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
          const SizedBox(width: AppSpacing.sm),

          // Bell notification
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.headerActionBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bell,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar DA
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.avatarNavy,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'DA',
              style: AppTypography.badge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            // Horizontal 3-Step Indicator
            DispatchStepIndicator(currentStep: _currentStep),
            const SizedBox(height: AppSpacing.md),

            // Step Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: stepWidget,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
