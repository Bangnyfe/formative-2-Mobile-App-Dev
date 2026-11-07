import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_label.dart';

Future<void> showUpdateStatusSheet(BuildContext context, Incident incident) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => UpdateStatusSheet(incident: incident),
  );
}

class UpdateStatusSheet extends StatefulWidget {
  const UpdateStatusSheet({super.key, required this.incident});

  final Incident incident;

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  final _noteController = TextEditingController();
  IncidentStatus? _selected;
  bool _saving = false;
  String? _error;

  // Going back to "Submitted" would let the student edit it again.
  List<IncidentStatus> get _options => IncidentStatus.values
      .where(
        (s) => s != IncidentStatus.submitted && s != widget.incident.status,
      )
      .toList();

  bool get _noteRequired => _selected == IncidentStatus.rejected;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) {
      setState(() => _error = 'Choose a new status.');
      return;
    }
    if (_noteRequired && _noteController.text.trim().isEmpty) {
      setState(
        () => _error = 'Please give the student a reason for rejecting.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<StaffProvider>().updateStatus(
      incident: widget.incident,
      status: _selected!,
      note: _noteController.text,
    );
    if (!mounted) return;

    if (error == null) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Status updated to ${_selected!.label}.')),
      );
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Currently: ${widget.incident.status.label}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const SectionLabel('New status'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in _options)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: _selected == status,
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _selected = status;
                      _error = null;
                    }),
                    selectedColor: status.color.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: _selected == status
                          ? status.color
                          : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selected == status
                          ? status.color
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SectionLabel('Note to the reporter', optional: !_noteRequired),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _noteRequired
                    ? 'Why is this report being rejected?'
                    : 'e.g. A technician has been assigned.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Update Status',
              icon: Icons.check_rounded,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
