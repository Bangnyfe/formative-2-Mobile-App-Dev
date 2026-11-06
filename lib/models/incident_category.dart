import 'package:flutter/material.dart';

enum IncidentCategory {
  facilities('Facilities', Icons.apartment_rounded),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_rounded),
  safety('Safety', Icons.shield_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded),
  furniture('Furniture', Icons.chair_outlined),
  other('Other', Icons.more_horiz_rounded);

  const IncidentCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Falls back to [other] for unknown values so old documents never crash the UI.
  static IncidentCategory fromName(String? name) => IncidentCategory.values
      .firstWhere((c) => c.name == name, orElse: () => IncidentCategory.other);
}
