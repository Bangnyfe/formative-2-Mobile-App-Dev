import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';

/// Optional photo field: an "add photo" box, or a preview with a remove button.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.onPicked,
    required this.onRemove,
    this.file,
    this.networkUrl,
  });

  final File? file;
  final String? networkUrl;
  final ValueChanged<File> onPicked;
  final VoidCallback onRemove;

  Future<void> _choose(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Resized and compressed on the device so uploads stay small.
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 75,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = file != null || networkUrl != null;

    if (!hasPhoto) {
      return InkWell(
        onTap: () => _choose(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
              SizedBox(height: 8),
              Text(
                'Tap to add a photo',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: file != null
                ? Image.file(file!, fit: BoxFit.cover)
                : Image.network(networkUrl!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _OverlayButton(
                icon: Icons.edit_outlined,
                tooltip: 'Change photo',
                onTap: () => _choose(context),
              ),
              const SizedBox(width: 8),
              _OverlayButton(
                icon: Icons.close,
                tooltip: 'Remove photo',
                onTap: onRemove,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
