import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/segmented_tab_bar.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../../dispatch/data/services/firestore_dispatch_service.dart';
import '../../../dispatch/domain/models/new_dispatch_data.dart';
import '../../../dispatch/presentation/pages/dispatch_tracking_page.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../receiving/presentation/pages/receiving_detail_page.dart';
import '../../data/mock/mock_history_data.dart';
import '../../domain/models/history_batch_item.dart';
import '../../domain/models/history_filter.dart';
import '../widgets/history_batch_card.dart';
import '../widgets/history_filter_chips.dart';
import '../widgets/history_search_bar.dart';

/// Comprehensive History Screen supporting both Pengiriman and Penerimaan
/// with role segmented toggle, keyword search, and status chips,
/// filtered per distributor ownership and role.
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.initialRoleIndex = 0,
    this.onRoleChanged,
    this.user,
  });

  final int initialRoleIndex;
  final ValueChanged<int>? onRoleChanged;
  final UserProfile? user;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late int _activeRoleIndex;
  HistoryFilterStatus _selectedFilter = HistoryFilterStatus.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeRoleIndex = widget.initialRoleIndex;
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRoleIndex != widget.initialRoleIndex) {
      _activeRoleIndex = widget.initialRoleIndex;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleRoleChanged(int index) {
    setState(() => _activeRoleIndex = index);
    widget.onRoleChanged?.call(index);
  }

  List<HistoryBatchItem> _filterItems(List<HistoryBatchItem> dataset) {
    return dataset.where((item) {
      // Filter by category status
      if (_selectedFilter != HistoryFilterStatus.all) {
        if (item.filterCategory != _selectedFilter) return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchCode = item.batchCode.toLowerCase().contains(query);
        final matchFish = item.fishType.toLowerCase().contains(query);
        final matchRoute = item.route?.toLowerCase().contains(query) ?? false;
        final matchSupplier =
            item.supplier?.toLowerCase().contains(query) ?? false;

        if (!matchCode && !matchFish && !matchRoute && !matchSupplier) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openTrackingDetail(
    HistoryBatchItem item,
    UserProfile? user, {
    required bool isDispatch,
  }) {
    if (!isDispatch) {
      final origin = item.route != null && item.route!.contains('→')
          ? item.route!.split('→').first.trim()
          : (item.supplier ?? '-');
      final dest = item.route != null && item.route!.contains('→')
          ? item.route!.split('→').last.trim()
          : (user?.storeLocation.isNotEmpty == true ? user!.storeLocation : '-');

      double weightVal = 50.0;
      final parsed = double.tryParse(item.weightLabel.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (parsed != null && parsed > 0) weightVal = parsed;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceivingDetailPage(
            batchId: item.batchCode,
            coolboxId: item.coolboxId.isNotEmpty ? item.coolboxId : 'SFR-CB-01',
            fishType: item.fishType,
            weightKg: weightVal,
            supplierName: item.supplier ?? '-',
            originLocation: origin,
            destinationLocation: dest,
            temperature: -2.4,
            frostScore: 90,
            initialStatus: item.statusLabel,
            formattedDate: item.date,
            receiverName: user?.name,
            receiverLocation: user?.storeLocation,
          ),
        ),
      );
      return;
    }

    final dispatchData = NewDispatchData(
      batchId: item.batchCode,
      coolboxId: item.coolboxId.isNotEmpty ? item.coolboxId : 'SFR-CB-01',
      senderName: item.supplier ?? user?.name ?? '-',
      fishType: item.fishType,
      weightRange: item.weightLabel,
      originLocation: item.route != null && item.route!.contains('→')
          ? item.route!.split('→').first.trim()
          : (user?.storeLocation.isNotEmpty == true
                ? user!.storeLocation
                : '-'),
      destinationLocation: item.route != null && item.route!.contains('→')
          ? item.route!.split('→').last.trim()
          : '-',
      receiverName: 'Penerima Pulau',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DispatchTrackingPage(data: dispatchData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDispatch = _activeRoleIndex == 0;
    final pageTitle = isDispatch ? 'Riwayat pengiriman' : 'Riwayat penerimaan';
    final activeUser = widget.user ?? AuthSession.instance.currentUser;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Role Switcher Segment
          SegmentedTabBar(
            selectedIndex: _activeRoleIndex,
            onTabChanged: _handleRoleChanged,
            tabs: const [
              SegmentTabItem(label: 'Pengiriman', icon: LucideIcons.send),
              SegmentTabItem(label: 'Penerimaan', icon: LucideIcons.inbox),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 2: Header Context
          Text(pageTitle, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.xs),

          // Section 3: Search Input
          HistorySearchBar(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: AppSpacing.md),

          // Section 4: Filter Status Chips
          HistoryFilterChips(
            selectedFilter: _selectedFilter,
            onFilterSelected: (status) =>
                setState(() => _selectedFilter = status),
          ),
          const SizedBox(height: AppSpacing.lg),

          // StreamBuilder for real-time history filtered per distributor & role
          StreamBuilder<List<HistoryBatchItem>>(
            key: ValueKey('history_stream_${isDispatch}_${activeUser?.email}'),
            stream: FirestoreDispatchService.instance.streamHistoryItems(
              isDispatch: isDispatch,
              user: activeUser,
            ),
            builder: (context, snapshot) {
              final realItems = snapshot.data ?? const [];
              final hasData = snapshot.hasData;
              final List<HistoryBatchItem> dataset = hasData
                  ? realItems
                  : (activeUser?.email == 'sasa@smartfrost.id'
                        ? (isDispatch
                              ? MockHistoryData.dispatchHistoryItems
                              : MockHistoryData.receivingHistoryItems)
                        : const <HistoryBatchItem>[]);

              final items = _filterItems(dataset);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${items.length} batch tersimpan di perangkat ini.',
                    style: AppTypography.pageSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Section 5: Batch Item Cards List
                  if (items.isEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Text(
                        'Tidak ada batch riwayat yang sesuai.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ] else ...[
                    for (final item in items) ...[
                      HistoryBatchCard(
                        item: item,
                        onTap: () => _openTrackingDetail(
                          item,
                          activeUser,
                          isDispatch: isDispatch,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
