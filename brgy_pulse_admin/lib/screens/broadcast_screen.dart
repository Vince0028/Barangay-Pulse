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
  String _selectedZone = 'All Zones';
  String _severity = 'Advisory';

  final _severityOptions = ['Advisory', 'Warning', 'Critical Evacuation'];
  final _zoneOptions = ['All Zones', 'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Warning': return AdminColors.warning;
      case 'Critical Evacuation': return AdminColors.danger;
      default: return AdminColors.primary;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'Warning': return Icons.warning_amber_rounded;
      case 'Critical Evacuation': return Icons.crisis_alert_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  void _sendBroadcast() {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(broadcastProvider.notifier).addBroadcast(
      _messageController.text.trim(),
      _severity,
      _selectedZone,
    );
    _messageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert broadcast sent')),
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
            Row(
              children: [
                Expanded(child: Text('Emergency Broadcast', style: tt.headlineLarge)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(broadcastProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Send alerts to all registered civilians.', style: tt.bodyMedium),
            const SizedBox(height: 20),

            // Severity
            Text('Severity Level', style: tt.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: _severityOptions.map((opt) {
                final sel = _severity == opt;
                final clr = _severityColor(opt);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = opt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? clr.withValues(alpha: 0.1) : context.cardFill,
                        borderRadius: BorderRadius.circular(kRadius),
                        border: Border.all(color: sel ? clr.withValues(alpha: 0.4) : context.border),
                      ),
                      child: Column(
                        children: [
                          Icon(_severityIcon(opt), size: 18, color: sel ? clr : context.textMuted),
                          const SizedBox(height: 3),
                          Text(opt, textAlign: TextAlign.center,
                              style: tt.bodySmall?.copyWith(
                                color: sel ? clr : context.textSecondary,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 9,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: _selectedZone,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Target Zone',
                prefixIcon: Icon(Icons.location_on_outlined, size: 16),
              ),
              items: _zoneOptions.map((zone) => DropdownMenuItem(
                value: zone,
                child: Text(zone),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedZone = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Alert Message',
                hintText: 'e.g. Evacuate Zone 4 due to rising flood waters...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendBroadcast,
                icon: const Icon(Icons.campaign_rounded, size: 18),
                label: const Text('Broadcast Alert'),
                style: ElevatedButton.styleFrom(backgroundColor: _severityColor(_severity)),
              ),
            ),

            const SizedBox(height: 28),
            Text('History', style: tt.headlineSmall),
            const SizedBox(height: 10),

            if (broadcasts.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No broadcasts sent yet.', style: tt.bodyMedium),
              ))
            else
              ...broadcasts.map((b) {
                final clr = _severityColor(b.severity);
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_severityIcon(b.severity), size: 14, color: clr),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: clr.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(b.severity,
                                  style: tt.bodySmall?.copyWith(color: clr, fontWeight: FontWeight.w600, fontSize: 9)),
                            ),
                            const SizedBox(width: 6),
                            Text(b.zone, style: tt.bodySmall),
                            const Spacer(),
                            Text(_timeAgo(b.timestamp), style: tt.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(b.message, style: tt.bodyMedium),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
