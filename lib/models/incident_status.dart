import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The lifecycle of a report: submitted -> inReview -> inProgress -> resolved.
/// Staff may also reject a report (e.g. duplicate or not a campus issue).
enum IncidentStatus {
  submitted('Submitted', AppColors.warning),
  inReview('In Review', AppColors.info),
  inProgress('In Progress', AppColors.primary),
  resolved('Resolved', AppColors.success),
  rejected('Rejected', AppColors.danger);

  const IncidentStatus(this.label, this.color);

  final String label;
  final Color color;

  bool get isClosed =>
      this == IncidentStatus.resolved || this == IncidentStatus.rejected;

  static IncidentStatus fromName(String? name) =>
      IncidentStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => IncidentStatus.submitted,
      );
}
