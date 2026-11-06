import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';
import '../reports/incident_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onReportTap,
    required this.onSeeAllTap,
  });

  final VoidCallback onReportTap;
  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;
    final incidents = context.watch<IncidentProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.firstName} 👋',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Help make our campus safer.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ReportBanner(onReportTap: onReportTap),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Report Summary', onSeeAll: onSeeAllTap),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  icon: Icons.description_outlined,
                  count: incidents.myIncidents.length,
                  label: 'My Reports',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryTile(
                  icon: Icons.schedule,
                  count: incidents.activeCount,
                  label: 'In Progress',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryTile(
                  icon: Icons.check,
                  count: incidents.countByStatus(IncidentStatus.resolved),
                  label: 'Resolved',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryTile(
                  icon: Icons.priority_high,
                  count: incidents.countByStatus(IncidentStatus.submitted),
                  label: 'Submitted',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Recent Reports', onSeeAll: onSeeAllTap),
          const SizedBox(height: 12),
          if (incidents.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (incidents.recentIncidents.isEmpty)
            EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No reports yet',
              message: 'Issues you report will show up here.',
              actionLabel: 'Report an issue',
              onAction: onReportTap,
            )
          else
            for (final incident in incidents.recentIncidents)
              IncidentCard(
                incident: incident,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        IncidentDetailsScreen(incidentId: incident.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onReportTap});

  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'See an issue on campus?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Report it and help improve our learning environment.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.apartment_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onReportTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Report an Issue'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
