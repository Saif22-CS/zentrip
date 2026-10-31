import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class PhotoPickerAvatar extends StatefulWidget {
  final File? initialFile;
  final void Function(File?) onChanged;
  final double size;

  const PhotoPickerAvatar({
    super.key,
    this.initialFile,
    required this.onChanged,
    this.size = 88,
  });

  @override
  State<PhotoPickerAvatar> createState() => _PhotoPickerAvatarState();
}

class _PhotoPickerAvatarState extends State<PhotoPickerAvatar> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _file = widget.initialFile;
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: Text(l10n.commonTakePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text(l10n.commonChooseFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_file != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.accentRed),
                title: Text(l10n.commonRemovePhoto, style: const TextStyle(color: AppColors.accentRed)),
                onTap: () {
                  setState(() => _file = null);
                  widget.onChanged(null);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (result == null) return;
    final picked = await picker.pickImage(source: result, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _file = file);
    widget.onChanged(file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySurface,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: _file != null
                ? Image.file(_file!, fit: BoxFit.cover)
                : Icon(Icons.person_rounded, size: widget.size * 0.5, color: AppColors.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
