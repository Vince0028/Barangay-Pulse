import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/report_model.dart';
import '../providers/admin_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(adminReportProvider);
    final report = reports.firstWhere((r) => r.id == widget.reportId);
    final meta = categoryMeta[report.category]!;
    final sMeta = statusMeta[report.status]!;
    final tt = Theme.of(context).textTheme;

    if (report.adminNotes != null && _notesController.text.isEmpty) {
      _notesController.text = report.adminNotes!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + status header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meta.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.label, style: tt.headlineSmall),
                      Text('ID: ${report.id}', style: tt.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sMeta.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sMeta.label,
                      style: tt.bodySmall?.copyWith(color: sMeta.color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details section
            _DetailRow(icon: Icons.person_outline, label: 'Reported by', value: report.reportedBy),
            _DetailRow(icon: Icons.access_time, label: 'Submitted', value: _formatTime(report.timestamp)),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Coordinates',
              value: '${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}',
            ),
            if (report.floodSeverity != null)
              _DetailRow(icon: Icons.water_rounded, label: 'Flood severity', value: report.floodSeverity!),

            const SizedBox(height: 16),

            // Description
            Text('Description', style: tt.labelLarge),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(report.description, style: tt.bodyLarge),
              ),
            ),
            const SizedBox(height: 24),

            // Status update
            Text('Update Status', style: tt.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: ReportStatus.values.map((s) {
                final sm = statusMeta[s]!;
                final selected = report.status == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(adminReportProvider.notifier).updateStatus(report.id, s);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? sm.color.withValues(alpha: 0.15) : AdminColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? sm.color.withValues(alpha: 0.5) : AdminColors.cardBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        sm.label,
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(
                          color: selected ? sm.color : AdminColors.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Admin notes
            Text('Admin Notes', style: tt.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Add internal notes about this report...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(adminReportProvider.notifier).addNotes(report.id, _notesController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notes saved')),
                  );
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Notes'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminColors.textMuted),
          const SizedBox(width: 8),
          Text('$label:', style: tt.bodySmall),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: tt.titleMedium)),
        ],
      ),
    );
  }
}
