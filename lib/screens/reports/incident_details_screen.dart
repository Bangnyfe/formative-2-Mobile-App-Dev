import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_thumbnail.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';

class IncidentDetailsScreen extends StatefulWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  // Created once so rebuilds don't resubscribe to Firestore.
  late final Stream<Incident?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<IncidentProvider>().watchIncident(widget.incidentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: StreamBuilder<Incident?>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load this report',
                message: 'Check your connection and try again.',
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final incident = snapshot.data;
          if (incident == null) {
            return const Center(
              child: EmptyState(
                icon: Icons.delete_outline,
                title: 'Report not found',
                message: 'This report may have been deleted.',
              ),
            );
          }
          return _DetailsBody(incident: incident);
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().appUser?.uid;
    final isOwner = incident.reporterId == uid;
    final reporter = isOwner
        ? (incident.isAnonymous ? 'You (anonymous)' : 'You')
        : incident.displayReporter;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncidentThumbnail(incident: incident, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${incident.category.label} • ${incident.location}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: incident.status),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          text: 'Submitted on ${Formatters.dateTime(incident.createdAt)}',
        ),
        _InfoRow(icon: Icons.person_outline, text: 'Reported by $reporter'),
        const SizedBox(height: 16),
        _Section(
          title: 'Status Timeline',
          child: StatusTimeline(incident: incident),
        ),
        _Section(
          title: 'Description',
          child: Text(
            incident.description,
            style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
          ),
        ),
        if (incident.photoUrl != null)
          _Section(
            title: 'Attached Photo',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(incident.photoUrl!, fit: BoxFit.cover),
            ),
          ),
        _Section(
          title: 'Activity',
          child: Column(
            children: [
              for (final change in incident.statusHistory.reversed)
                _ActivityTile(change: change),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.change});

  final StatusChange change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: change.status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.status.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (change.note != null && change.note!.isNotEmpty)
                  Text(change.note!),
                Text(
                  '${change.changedBy} • ${Formatters.dateTime(change.at)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
