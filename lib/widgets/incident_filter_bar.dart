import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../providers/incident_filters.dart';

/// Search box, category menu and status chips for a report list.
class IncidentFilterBar extends StatelessWidget {
  const IncidentFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
  });

  final IncidentFilters filters;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: filters.setSearchQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search title, location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: filters.searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              filters.setSearchQuery('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CategoryFilterButton(
                selected: filters.categoryFilter,
                onSelected: filters.setCategoryFilter,
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
                selected: filters.statusFilter == null,
                onTap: () => filters.setStatusFilter(null),
              ),
              for (final status in IncidentStatus.values)
                _FilterChip(
                  label: status.label,
                  selected: filters.statusFilter == status,
                  onTap: () => filters.setStatusFilter(status),
                ),
            ],
          ),
        ),
      ],
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
