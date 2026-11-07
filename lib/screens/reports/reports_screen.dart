import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_filter_bar.dart';
import '../../widgets/incident_list.dart';

/// Campus-wide feed and the user's own reports, switched with a toggle.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.onReportTap});

  final VoidCallback onReportTap;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<IncidentProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isMine = provider.scope == FeedScope.mine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<FeedScope>(
                segments: const [
                  ButtonSegment(
                    value: FeedScope.campus,
                    label: Text('Campus'),
                    icon: Icon(Icons.apartment_rounded),
                  ),
                  ButtonSegment(
                    value: FeedScope.mine,
                    label: Text('My Reports'),
                    icon: Icon(Icons.person_outline),
                  ),
                ],
                selected: {provider.scope},
                onSelectionChanged: (selection) =>
                    provider.setScope(selection.first),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          IncidentFilterBar(
            filters: provider,
            searchController: _searchController,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IncidentList(
              incidents: provider.filteredIncidents,
              hasAnyIncidents: provider.scopedIncidents.isNotEmpty,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onClearFilters: _clearFilters,
              emptyState: EmptyState(
                icon: Icons.inbox_outlined,
                title: isMine ? 'No reports yet' : 'No campus reports yet',
                message: isMine
                    ? 'When you report an issue it will appear here.'
                    : 'Be the first to report an issue on campus.',
                actionLabel: 'Report an issue',
                onAction: widget.onReportTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
