import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_form_provider.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/photo_picker_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_label.dart';

/// Creates a new report, or edits [incident] when one is passed in.
class NewReportScreen extends StatelessWidget {
  const NewReportScreen({super.key, this.incident});

  final Incident? incident;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportFormProvider(existing: incident),
      child: _NewReportView(incident: incident),
    );
  }
}

class _NewReportView extends StatefulWidget {
  const _NewReportView({this.incident});

  final Incident? incident;

  @override
  State<_NewReportView> createState() => _NewReportViewState();
}

class _NewReportViewState extends State<_NewReportView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final incident = widget.incident;
    if (incident != null) {
      _titleController.text = incident.title;
      _descriptionController.text = incident.description;
      _locationController.text = incident.location;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onPhotoPicked(File file) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<ReportFormProvider>().setPhoto(file);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final form = context.read<ReportFormProvider>();
    final formValid = _formKey.currentState!.validate();
    final categoryValid = form.validateCategory();
    if (!formValid || !categoryValid) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await form.submit(
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      reporter: context.read<AuthProvider>().appUser!,
    );

    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            form.isEditing
                ? 'Report updated.'
                : 'Report submitted. You can track it in My Reports.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ReportFormProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(form.isEditing ? 'Edit Report' : 'Report an Incident'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const SectionLabel('Select a category'),
              CategorySelector(
                selected: form.category,
                onSelected: form.selectCategory,
                errorText: form.showCategoryError
                    ? 'Please choose a category'
                    : null,
              ),
              const SizedBox(height: 20),
              const SectionLabel('Title'),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: AppConstants.titleMaxLength,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe the issue',
                  counterText: '',
                ),
                validator: Validators.incidentTitle,
              ),
              const SizedBox(height: 16),
              const SectionLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 4,
                maxLines: 6,
                maxLength: AppConstants.descriptionMaxLength,
                decoration: const InputDecoration(
                  hintText: 'What happened, when did you notice it, and who is affected?',
                ),
                validator: Validators.incidentDescription,
              ),
              const SizedBox(height: 8),
              const SectionLabel('Location'),
              _LocationField(controller: _locationController),
              const SizedBox(height: 16),
              const SectionLabel('Add a photo', optional: true),
              PhotoPickerField(
                file: form.newPhoto,
                networkUrl: form.existingPhotoUrl,
                onPicked: _onPhotoPicked,
                onRemove: form.removePhoto,
              ),
              const SizedBox(height: 16),
              _AnonymousToggle(
                value: form.isAnonymous,
                onChanged: form.setAnonymous,
              ),
              const SizedBox(height: 24),
              if (form.errorMessage != null) ...[
                ErrorBanner(message: form.errorMessage!),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: form.isEditing ? 'Save Changes' : 'Submit Report',
                icon: form.isEditing ? Icons.check_rounded : Icons.send_rounded,
                isLoading: form.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Free-text location with suggestions for common campus places.
class _LocationField extends StatefulWidget {
  const _LocationField({required this.controller});

  final TextEditingController controller;

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return AppConstants.campusLocations;
        return AppConstants.campusLocations.where(
          (place) => place.toLowerCase().contains(query),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Social Commons, Egypt',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) => Validators.required(value, 'Location'),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 220,
                maxWidth: MediaQuery.sizeOf(context).width - 40,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnonymousToggle extends StatelessWidget {
  const _AnonymousToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Report anonymously',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: const Text(
          'Your name is hidden from other students. Campus staff can still see it to follow up.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
