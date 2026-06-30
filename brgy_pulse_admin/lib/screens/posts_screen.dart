import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/announcement_model.dart';
import '../providers/admin_provider.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _createPost() {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;

    ref.read(adminAnnouncementProvider.notifier).addAnnouncement(
      _titleController.text.trim(),
      _bodyController.text.trim(),
    );

    _titleController.clear();
    _bodyController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement posted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(adminAnnouncementProvider);
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Create Post', style: tt.headlineLarge),
            const SizedBox(height: 4),
            Text('Publish announcements to all residents.', style: tt.bodyMedium),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              style: tt.bodyLarge,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Body',
                hintText: 'Write your announcement...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createPost,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Publish'),
              ),
            ),

            const SizedBox(height: 28),
            Row(
              children: [
                Text('Published', style: tt.headlineSmall),
                const Spacer(),
                Text('${announcements.length}', style: tt.bodySmall),
              ],
            ),
            const SizedBox(height: 10),

            ...announcements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(a.title, style: tt.titleMedium)),
                              GestureDetector(
                                onTap: () {
                                  ref.read(adminAnnouncementProvider.notifier).deleteAnnouncement(a.id);
                                },
                                child: Icon(Icons.delete_outline_rounded, size: 16, color: AdminColors.danger),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(a.body, style: tt.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(a.postedBy, style: tt.bodySmall),
                              const Spacer(),
                              Text(_timeAgo(a.timestamp), style: tt.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
