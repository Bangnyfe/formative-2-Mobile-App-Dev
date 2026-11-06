import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';

/// Horizontal progress tracker: Submitted -> In Review -> In Progress -> Resolved.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  static const _steps = [
    IncidentStatus.submitted,
    IncidentStatus.inReview,
    IncidentStatus.inProgress,
    IncidentStatus.resolved,
  ];

  // For a rejected report, show progress up to the last stage it reached.
  int get _currentIndex {
    if (incident.status != IncidentStatus.rejected) {
      return _steps.indexOf(incident.status);
    }
    final reached = incident.statusHistory
        .map((change) => _steps.indexOf(change.status))
        .where((index) => index >= 0);
    return reached.isEmpty ? 0 : reached.reduce((a, b) => a > b ? a : b);
  }

  DateTime? _dateFor(IncidentStatus status) {
    final matches = incident.statusHistory.where((c) => c.status == status);
    return matches.isEmpty ? null : matches.last.at;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex;
    final children = <Widget>[];

    for (var i = 0; i < _steps.length; i++) {
      if (i > 0) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Container(
                height: 2,
                color: i <= current ? AppColors.primary : AppColors.border,
              ),
            ),
          ),
        );
      }
      children.add(
        _Step(
          status: _steps[i],
          isDone: i <= current,
          isCurrent: i == current,
          date: _dateFor(_steps[i]),
        ),
      );
    }

    return Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        if (incident.status == IncidentStatus.rejected) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.block, size: 18, color: AppColors.danger),
                SizedBox(width: 8),
                Text(
                  'This report was rejected by campus staff.',
                  style: TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.isDone,
    required this.isCurrent,
    this.date,
  });

  final IncidentStatus status;
  final bool isDone;
  final bool isCurrent;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isDone ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: isDone
                ? Icon(
                    isCurrent ? Icons.circle : Icons.check,
                    size: isCurrent ? 8 : 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            status.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            date != null ? Formatters.shortDate(date!) : '—',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
