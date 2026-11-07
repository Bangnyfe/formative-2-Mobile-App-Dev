import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/incident_status.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_filter_bar.dart';
import '../../widgets/incident_list.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<StaffProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                for (final status in [
                  IncidentStatus.submitted,
                  IncidentStatus.inReview,
                  IncidentStatus.inProgress,
                  IncidentStatus.resolved,
                ])
                  Expanded(
                    child: _StatusCount(
                      status: status,
                      count: staff.countByStatus(status),
                      selected: staff.statusFilter == status,
                      onTap: () => staff.setStatusFilter(
                        staff.statusFilter == status ? null : status,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IncidentFilterBar(
            filters: staff,
            searchController: _searchController,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IncidentList(
              incidents: staff.filteredIncidents,
              hasAnyIncidents: staff.allIncidents.isNotEmpty,
              isLoading: staff.isLoading,
              errorMessage: staff.errorMessage,
              onClearFilters: _clearFilters,
              emptyState: const EmptyState(
                icon: Icons.task_alt_rounded,
                title: 'No reports yet',
                message: 'New campus reports will appear here.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IncidentStatus status;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: selected ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? status.color : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: status.color,
                ),
              ),
              Text(
                status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
