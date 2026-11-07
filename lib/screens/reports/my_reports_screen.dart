import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_filter_bar.dart';
import '../../widgets/incident_list.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          IncidentFilterBar(
            filters: provider,
            searchController: _searchController,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IncidentList(
              incidents: provider.filteredIncidents,
              hasAnyIncidents: provider.myIncidents.isNotEmpty,
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              onClearFilters: _clearFilters,
              emptyState: EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No reports yet',
                message: 'When you report an issue it will appear here.',
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
