import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../mesh/models/mesh_message.dart';
import '../mesh/services/mesh_controller.dart';
import '../mesh/services/mesh_storage.dart';
import '../services/supabase_service.dart';

class AdminMeshChatScreen extends StatefulWidget {
  const AdminMeshChatScreen({super.key});

  @override
  State<AdminMeshChatScreen> createState() => _AdminMeshChatScreenState();
}

class _AdminMeshChatScreenState extends State<AdminMeshChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  MeshController? _meshController;
  StreamSubscription<MeshMessage>? _messageSub;
  StreamSubscription<int>? _peerSub;
  List<MeshMessage> _messages = [];
  int _peerCount = 0;
  bool _meshStarted = false;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    try {
      _messages = MeshStorage.getMessages();
      setState(() {});
    } catch (e) {
      debugPrint('[MeshChat] Error loading messages: $e');
    }
  }

  Future<void> _startMesh() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesh chat requires Android. Build as APK to use.')),
      );
      return;
    }

    setState(() => _isStarting = true);

    final user = SupabaseService.currentUser;
    final profile = user?.userMetadata;
    final name = profile?['full_name'] as String? ?? 'Admin';

    _meshController = MeshController(
      username: name,
      userRole: 'admin',
    );

    _messageSub = _meshController!.onMessage.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
      _scrollToBottom();
    });

    _peerSub = _meshController!.onPeerCountChanged.listen((count) {
      setState(() => _peerCount = count);
    });

    final success = await _meshController!.startMesh();
    setState(() {
      _meshStarted = success;
      _isStarting = false;
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _meshController == null) return;

    _meshController!.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _peerSub?.cancel();
    _meshController?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final userName = SupabaseService.currentUser?.userMetadata?['full_name'] ?? 'Admin';

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(bottom: BorderSide(color: context.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cell_tower_rounded, color: AdminColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('Emergency Chat', style: tt.headlineSmall),
                    const Spacer(),
                    if (_meshStarted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _peerCount > 0
                              ? AdminColors.success.withValues(alpha: 0.1)
                              : AdminColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(kRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: _peerCount > 0 ? AdminColors.success : AdminColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_peerCount nearby',
                              style: tt.bodySmall?.copyWith(
                                color: _peerCount > 0 ? AdminColors.success : AdminColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _meshStarted
                      ? 'Connected via Bluetooth mesh • Responding to civilians'
                      : 'Chat with nearby civilians when WiFi is down',
                  style: tt.bodySmall?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),

          // Start mesh prompt
          if (!_meshStarted && !kIsWeb)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AdminColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cell_tower_rounded, size: 40, color: AdminColors.primary),
                      ),
                      const SizedBox(height: 20),
                      Text('Offline Mesh Chat', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'During emergencies, this lets you communicate with nearby civilians using Bluetooth — even without WiFi.',
                        style: tt.bodyMedium?.copyWith(color: context.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isStarting ? null : _startMesh,
                          icon: _isStarting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.bluetooth_searching_rounded),
                          label: Text(_isStarting ? 'Starting mesh...' : 'Start Emergency Chat'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Requires Bluetooth & Location permissions',
                        style: tt.bodySmall?.copyWith(color: context.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Web fallback
          if (kIsWeb)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_android_rounded, size: 48, color: context.textMuted),
                      const SizedBox(height: 16),
                      Text('Android Only', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Mesh chat uses Bluetooth and works only on Android devices. Build the APK to test this feature.',
                        style: tt.bodyMedium?.copyWith(color: context.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Chat messages
          if (_meshStarted)
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 40, color: context.textMuted),
                          const SizedBox(height: 12),
                          Text('No messages yet', style: tt.bodyMedium?.copyWith(color: context.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            'Waiting for civilians to connect...',
                            style: tt.bodySmall?.copyWith(color: context.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMe = msg.from == userName;
                        final isCivilian = msg.senderRole == 'civilian';

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AdminColors.primary
                                  : isCivilian
                                      ? const Color(0xFFFEF3C7) // light amber for civilians
                                      : context.cardFill,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              border: isMe ? null : Border.all(color: context.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCivilian ? Icons.person_rounded : Icons.shield_rounded,
                                          size: 12,
                                          color: isCivilian ? const Color(0xFFD97706) : AdminColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          msg.from,
                                          style: tt.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isCivilian ? const Color(0xFFD97706) : AdminColors.primary,
                                          ),
                                        ),
                                        Text(
                                          isCivilian ? ' • Civilian' : ' • Official',
                                          style: tt.bodySmall?.copyWith(
                                            color: isCivilian ? const Color(0xFFD97706) : AdminColors.primary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  msg.body,
                                  style: tt.bodyMedium?.copyWith(
                                    color: isMe ? Colors.white : context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(msg.timestamp),
                                  style: tt.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : context.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

          // Message input
          if (_meshStarted)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(top: BorderSide(color: context.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Respond to civilians...',
                        filled: true,
                        fillColor: context.cardFill,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AdminColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
