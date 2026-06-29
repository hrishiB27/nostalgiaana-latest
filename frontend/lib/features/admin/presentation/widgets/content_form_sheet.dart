import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/network/api_error.dart';
import '../../../category/application/category_providers.dart';
import '../../../content/data/models/content_type.dart';
import '../../data/models/content_upload_request.dart';

typedef ContentFormSubmit = Future<void> Function(
  ContentUploadRequest request,
  PlatformFile media,
  PlatformFile? thumbnail,
);

/// Single upload form shared by Manage Shows and Manage Audios. Which
/// media picker (`video`/`audio`) and copy it shows is driven entirely by
/// [contentType]; what happens with the result is entirely up to whatever
/// [onSubmit] does — this widget doesn't know about either notifier.
class ContentFormSheet extends ConsumerStatefulWidget {
  const ContentFormSheet({super.key, required this.contentType, required this.onSubmit});

  final ContentType contentType;
  final ContentFormSubmit onSubmit;

  @override
  ConsumerState<ContentFormSheet> createState() => _ContentFormSheetState();
}

class _ContentFormSheetState extends ConsumerState<ContentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _speakerController = TextEditingController();

  String? _categoryId;
  bool _isPremium = false;
  PlatformFile? _media;
  PlatformFile? _thumbnail;
  bool _mediaMissing = false;
  bool _isSubmitting = false;
  String? _submitError;

  bool get _isShow => widget.contentType == ContentType.show;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: _isShow ? FileType.video : FileType.audio,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _media = result.files.single;
        _mediaMissing = false;
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _thumbnail = result.files.single);
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final media = _media;
    setState(() => _mediaMissing = media == null);
    if (!formValid || media == null) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      await widget.onSubmit(
        ContentUploadRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _categoryId,
          speaker: _speakerController.text.trim().isEmpty ? null : _speakerController.text.trim(),
          isPremium: _isPremium,
        ),
        media,
        _thumbnail,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _submitError = messageFor(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final mediaLabel = _isShow ? 'Video file' : 'Audio file';
    final accent = _isShow ? AppColors.crimson : AppColors.teal;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    _isShow ? 'Add Show' : 'Add Audio',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.offWhite),
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppColors.offWhite),
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _speakerController,
                    style: const TextStyle(color: AppColors.offWhite),
                    decoration: const InputDecoration(labelText: 'Speaker (optional)'),
                  ),
                  const SizedBox(height: 16),
                  categories.when(
                    data: (items) => DropdownButtonFormField<String?>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Category (optional)'),
                      dropdownColor: AppColors.charcoal,
                      style: const TextStyle(color: AppColors.offWhite),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('None')),
                        ...items.map(
                          (category) => DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _categoryId = value),
                    ),
                    loading: () => const LinearProgressIndicator(color: AppColors.teal),
                    error: (error, stackTrace) => Text(
                      'Could not load categories — you can still upload without one.',
                      style: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Premium content', style: TextStyle(color: AppColors.offWhite)),
                    subtitle: Text(
                      _isPremium ? 'Only PREMIUM/ADMIN accounts can stream this' : 'Free for all listeners',
                      style: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.55)),
                    ),
                    value: _isPremium,
                    activeThumbColor: AppColors.gold,
                    onChanged: (value) => setState(() => _isPremium = value),
                  ),
                  const SizedBox(height: 8),
                  _FilePickerRow(
                    label: mediaLabel,
                    fileName: _media?.name,
                    icon: _isShow ? Icons.videocam_outlined : Icons.audiotrack_outlined,
                    accent: accent,
                    onPick: _pickMedia,
                  ),
                  if (_mediaMissing) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Required',
                      style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _FilePickerRow(
                    label: 'Thumbnail (optional)',
                    fileName: _thumbnail?.name,
                    icon: Icons.image_outlined,
                    accent: accent,
                    onPick: _pickThumbnail,
                  ),
                  if (_submitError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _submitError!,
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: accent),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.offWhite),
                          )
                        : Text(_isShow ? 'Upload Show' : 'Upload Audio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  const _FilePickerRow({
    required this.label,
    required this.fileName,
    required this.icon,
    required this.accent,
    required this.onPick,
  });

  final String label;
  final String? fileName;
  final IconData icon;
  final Color accent;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName ?? label,
                style: TextStyle(
                  color: fileName != null ? AppColors.offWhite : AppColors.offWhite.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.attach_file, color: AppColors.offWhite.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
