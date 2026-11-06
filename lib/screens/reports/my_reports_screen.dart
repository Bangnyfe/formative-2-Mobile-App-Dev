import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import 'incident_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.onReportTap});

  final VoidCallback onReportTap;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
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
    final results = provider.filteredIncidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search title, location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: provider.searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CategoryFilterButton(
                  selected: provider.categoryFilter,
                  onSelected: provider.setCategoryFilter,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: provider.statusFilter == null,
                  onTap: () => provider.setStatusFilter(null),
                ),
                for (final status in IncidentStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: provider.statusFilter == status,
                    onTap: () => provider.setStatusFilter(status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildList(provider, results)),
        ],
      ),
    );
  }

  Widget _buildList(IncidentProvider provider, List<Incident> results) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Something went wrong',
          message: provider.errorMessage!,
        ),
      );
    }
    if (provider.myIncidents.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.inbox_outlined,
          title: 'No reports yet',
          message: 'When you report an issue it will appear here.',
          actionLabel: 'Report an issue',
          onAction: widget.onReportTap,
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matching reports',
          message: 'Try a different search or filter.',
          actionLabel: 'Clear filters',
          onAction: _clearFilters,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final incident = results[index];
        return IncidentCard(
          incident: incident,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.accentLight,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.accent : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  const _CategoryFilterButton({
    required this.selected,
    required this.onSelected,
  });

  final IncidentCategory? selected;
  final ValueChanged<IncidentCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isActive = selected != null;

    return PopupMenuButton<IncidentCategory?>(
      tooltip: 'Filter by category',
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All categories')),
        for (final category in IncidentCategory.values)
          PopupMenuItem(
            value: category,
            child: Row(
              children: [
                Icon(category.icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(category.label),
              ],
            ),
          ),
      ],
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Icon(
          isActive ? selected!.icon : Icons.tune_rounded,
          color: isActive ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}
