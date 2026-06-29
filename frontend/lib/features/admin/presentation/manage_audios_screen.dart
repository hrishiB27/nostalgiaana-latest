import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../content/data/models/content_type.dart';
import '../application/admin_audios_notifier.dart';
import '../application/admin_content_state.dart';
import '../data/models/content_detail_response_model.dart';
import 'widgets/admin_error_view.dart';
import 'widgets/content_form_sheet.dart';
import 'widgets/content_list_tile.dart';

class ManageAudiosScreen extends ConsumerStatefulWidget {
  const ManageAudiosScreen({super.key});

  @override
  ConsumerState<ManageAudiosScreen> createState() => _ManageAudiosScreenState();
}

class _ManageAudiosScreenState extends ConsumerState<ManageAudiosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminAudiosProvider.notifier).load());
  }

  Future<void> _openAddForm() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContentFormSheet(
        contentType: ContentType.audio,
        onSubmit: (request, media, thumbnail) =>
            ref.read(adminAudiosProvider.notifier).upload(request, media, thumbnail),
      ),
    );
  }

  Future<void> _confirmDelete(ContentDetailResponseModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete audio?'),
        content: Text('"${item.title}" and its uploaded audio file will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.crimson),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminAudiosProvider.notifier).delete(item.id);
    }
  }

  Widget _buildBody(AdminContentState state) {
    if (state.items.isEmpty) {
      if (state.status == AdminContentStatus.error) {
        return AdminErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref.read(adminAudiosProvider.notifier).load(),
        );
      }
      if (state.status == AdminContentStatus.loaded) {
        return const Center(
          child: Text('No audios yet. Tap + to add one.', style: TextStyle(color: AppColors.offWhite)),
        );
      }
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ContentListTile(item: item, onDelete: () => _confirmDelete(item));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminContentState>(adminAudiosProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });
    final state = ref.watch(adminAudiosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Audios')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        backgroundColor: AppColors.teal,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state),
    );
  }
}
