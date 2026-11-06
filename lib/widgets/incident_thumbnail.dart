import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/incident.dart';

/// Shows the report photo, or the category icon when there is no photo.
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 56});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.primaryLight,
      child: Icon(
        incident.category.icon,
        color: AppColors.primary,
        size: size * 0.45,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.photoUrl == null
          ? placeholder
          : Image.network(
              incident.photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
