import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/admin_provider.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _messageController = TextEditingController();
  final _zoneController = TextEditingController(text: 'All Zones');
  String _severity = 'Advisory';

  final _severityOptions = ['Advisory', 'Warning', 'Critical Evacuation'];

  @override
  void dispose() {
    _messageController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Warning':
        return AdminColors.warning;
      case 'Critical Evacuation':
        return AdminColors.danger;
      default:
        return AdminColors.primary;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'Warning':
        return Icons.warning_amber_rounded;
      case 'Critical Evacuation':
        return Icons.crisis_alert_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  void _sendBroadcast() {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(broadcastProvider.notifier).addBroadcast(
      Broadcast(
        message: _messageController.text.trim(),
        severity: _severity,
        zone: _zoneController.text.trim(),
        timestamp: DateTime.now(),
      ),
    );

    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AdminColors.success, size: 18),
            const SizedBox(width: 8),
            const Text('Alert broadcast sent'),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final broadcasts = ref.watch(broadcastProvider);
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Emergency Broadcast', style: tt.headlineLarge),
            const SizedBox(height: 4),
            Text('Send alerts to all registered civilians.', style: tt.bodyMedium),
            const SizedBox(height: 24),

            // Severity selector
            Text('Severity Level', style: tt.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: _severityOptions.map((opt) {
                final selected = _severity == opt;
                final color = _severityColor(opt);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = opt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.15) : AdminColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color.withValues(alpha: 0.5) : AdminColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_severityIcon(opt), size: 20,
                              color: selected ? color : AdminColors.textMuted),
                          const SizedBox(height: 4),
                          Text(
                            opt,
                            textAlign: TextAlign.center,
                            style: tt.bodySmall?.copyWith(
                              color: selected ? color : AdminColors.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Zone
            TextField(
              controller: _zoneController,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Target Zone',
                prefixIcon: Icon(Icons.location_on_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Message
            TextField(
              controller: _messageController,
              maxLines: 4,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Alert Message',
                hintText: 'e.g. Evacuate Zone 4 immediately due to rising flood waters...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendBroadcast,
                icon: const Icon(Icons.campaign_rounded, size: 20),
                label: const Text('Broadcast Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _severityColor(_severity),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Past broadcasts
            const SizedBox(height: 32),
            Text('Broadcast History', style: tt.headlineSmall),
            const SizedBox(height: 12),

            if (broadcasts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No broadcasts sent yet.', style: tt.bodyMedium),
                ),
              )
            else
              ...broadcasts.map((b) {
                final color = _severityColor(b.severity);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_severityIcon(b.severity), size: 16, color: color),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(b.severity,
                                  style: tt.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            Text(b.zone, style: tt.bodySmall),
                            const Spacer(),
                            Text(_timeAgo(b.timestamp), style: tt.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(b.message, style: tt.bodyMedium?.copyWith(color: AdminColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
