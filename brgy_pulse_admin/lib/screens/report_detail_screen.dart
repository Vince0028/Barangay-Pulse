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
  bool _proofAttached = false;

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
            // Header
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: meta.bgColor,
                    borderRadius: BorderRadius.circular(kRadius),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 22),
                ),
                const SizedBox(width: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sMeta.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kRadius),
                  ),
                  child: Text(sMeta.label,
                      style: tt.bodySmall?.copyWith(color: sMeta.color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details
            _Row(icon: Icons.person_outline, label: 'Reported by', value: report.reportedBy),
            _Row(icon: Icons.access_time, label: 'Submitted', value: _formatTime(report.timestamp)),
            _Row(icon: Icons.location_on_outlined, label: 'Location',
                value: '${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}'),
            if (report.floodSeverity != null)
              _Row(icon: Icons.water_rounded, label: 'Flood severity', value: report.floodSeverity!),
            const SizedBox(height: 14),

            // Description
            Text('Description', style: tt.labelLarge),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(report.description, style: tt.bodyLarge),
              ),
            ),
            const SizedBox(height: 20),

            // Status update
            Text('Update Status', style: tt.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: ReportStatus.values.map((s) {
                final sm = statusMeta[s]!;
                final sel = report.status == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (s == ReportStatus.resolved && !_proofAttached) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Attach proof photo before resolving')),
                        );
                        return;
                      }
                      ref.read(adminReportProvider.notifier).updateStatus(report.id, s);
                      if (s == ReportStatus.resolved) {
                        ref.read(officerProfileProvider.notifier).completeTask(report.id, report.category);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? sm.color.withValues(alpha: 0.1) : context.cardFill,
                        borderRadius: BorderRadius.circular(kRadius),
                        border: Border.all(
                          color: sel ? sm.color.withValues(alpha: 0.4) : context.border,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(sm.label, textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(
                            color: sel ? sm.color : context.textSecondary,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Proof photo
            Text('Proof Photo', style: tt.labelLarge),
            const SizedBox(height: 6),
            if (_proofAttached)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: AdminColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Photo attached', style: tt.bodyMedium?.copyWith(color: AdminColors.success))),
                      GestureDetector(
                        onTap: () => setState(() => _proofAttached = false),
                        child: Icon(Icons.close_rounded, size: 16, color: context.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Simulated — would use image_picker
                    setState(() => _proofAttached = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proof photo attached')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Attach Proof Photo'),
                ),
              ),
            if (!_proofAttached && report.status == ReportStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Required before marking as resolved',
                    style: tt.bodySmall?.copyWith(color: AdminColors.warning)),
              ),
            const SizedBox(height: 20),

            // Notes
            Text('Admin Notes', style: tt.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Internal notes...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(adminReportProvider.notifier).addNotes(report.id, _notesController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notes saved')),
                  );
                },
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Notes'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.textMuted),
          const SizedBox(width: 6),
          Text('$label:', style: tt.bodySmall),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: tt.titleMedium)),
        ],
      ),
    );
  }
}
