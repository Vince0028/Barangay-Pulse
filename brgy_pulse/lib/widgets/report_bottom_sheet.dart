import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/report_model.dart';
import '../providers/report_provider.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  const ReportBottomSheet({super.key});

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  final _descriptionController = TextEditingController();
  ReportCategory _selectedCategory = ReportCategory.trash;
  String _floodSeverity = 'Low';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final report = Report(
      id: 'rpt_${DateTime.now().millisecondsSinceEpoch}',
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : AppConstants.categoryMeta[_selectedCategory]!.label,
      category: _selectedCategory,
      location: const LatLng(AppConstants.mapCenterLat, AppConstants.mapCenterLng),
      status: ReportStatus.pending,
      timestamp: DateTime.now(),
      reportedBy: 'demo_user',
      floodSeverity:
          _selectedCategory == ReportCategory.flood ? _floodSeverity : null,
    );

    ref.read(reportProvider.notifier).addReport(report);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r + 4)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text('Report an Issue', style: tt.headlineSmall),
            const SizedBox(height: 2),
            Text('This will be sent to ${AppConstants.barangayName}.', style: tt.bodyMedium),
            const SizedBox(height: 16),

            // Category chips
            Text('Category', style: tt.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ReportCategory.values.map((cat) {
                final meta = AppConstants.categoryMeta[cat]!;
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? meta.color.withValues(alpha: 0.1) : context.cardFill,
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      border: Border.all(
                        color: selected ? meta.color.withValues(alpha: 0.4) : context.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(meta.icon, size: 14,
                            color: selected ? meta.color : context.textSecondary),
                        const SizedBox(width: 4),
                        Text(meta.label,
                            style: tt.bodySmall?.copyWith(
                              color: selected ? meta.color : context.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Flood severity
            if (_selectedCategory == ReportCategory.flood) ...[
              const SizedBox(height: 14),
              Text('Severity', style: tt.labelLarge),
              const SizedBox(height: 6),
              Row(
                children: AppConstants.floodSeverity.map((level) {
                  final selected = _floodSeverity == level;
                  final color = level == 'Low'
                      ? AppColors.warning
                      : level == 'Medium'
                          ? const Color(0xFFE67E22)
                          : AppColors.danger;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _floodSeverity = level),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color.withValues(alpha: 0.1) : context.cardFill,
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(
                            color: selected ? color.withValues(alpha: 0.4) : context.border,
                          ),
                        ),
                        child: Text(level, textAlign: TextAlign.center,
                            style: tt.bodySmall?.copyWith(
                              color: selected ? color : context.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'What\'s happening? (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined, size: 16),
              label: const Text('Attach Photo'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Report'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
