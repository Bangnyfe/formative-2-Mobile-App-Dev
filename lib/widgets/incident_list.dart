import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../screens/reports/incident_details_screen.dart';
import 'empty_state.dart';
import 'incident_card.dart';

/// A list of reports with loading, error and empty states.
class IncidentList extends StatelessWidget {
  const IncidentList({
    super.key,
    required this.incidents,
    required this.hasAnyIncidents,
    required this.isLoading,
    required this.emptyState,
    required this.onClearFilters,
    this.errorMessage,
  });

  final List<Incident> incidents;
  final bool hasAnyIncidents;
  final bool isLoading;
  final String? errorMessage;
  final Widget emptyState;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return _centered(
        EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Something went wrong',
          message: errorMessage!,
        ),
      );
    }
    if (!hasAnyIncidents) {
      return _centered(emptyState);
    }
    if (incidents.isEmpty) {
      return _centered(
        EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matching reports',
          message: 'Try a different search or filter.',
          actionLabel: 'Clear filters',
          onAction: onClearFilters,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
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

  // Scrollable so the message never overflows when the keyboard is open.
  Widget _centered(Widget child) {
    return Center(child: SingleChildScrollView(child: child));
  }
}
