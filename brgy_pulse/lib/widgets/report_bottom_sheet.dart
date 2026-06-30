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
      location: const LatLng(14.5650, 120.9930), // Current location placeholder
      status: ReportStatus.pending,
      timestamp: DateTime.now(),
      reportedBy: 'demo_user',
      floodSeverity:
          _selectedCategory == ReportCategory.flood ? _floodSeverity : null,
    );

    ref.read(reportProvider.notifier).addReport(report);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            const Text('Report submitted'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text('Report an Issue', style: tt.headlineSmall),
            const SizedBox(height: 4),
            Text('This will be sent to your barangay office.',
                style: tt.bodyMedium),
            const SizedBox(height: 20),

            // Category selector
            Text('Category', style: tt.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportCategory.values.map((cat) {
                final meta = AppConstants.categoryMeta[cat]!;
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? meta.color.withValues(alpha: 0.15) : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? meta.color.withValues(alpha: 0.5)
                            : AppColors.cardBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(meta.icon,
                            size: 16,
                            color: selected
                                ? meta.color
                                : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          meta.label,
                          style: tt.bodySmall?.copyWith(
                            color: selected
                                ? meta.color
                                : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Flood severity sub-selector
            if (_selectedCategory == ReportCategory.flood) ...[
              const SizedBox(height: 16),
              Text('Severity', style: tt.labelLarge),
              const SizedBox(height: 8),
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
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.15)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? color.withValues(alpha: 0.5)
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(
                            color: selected ? color : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: tt.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'What\'s happening? (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Photo button
            OutlinedButton.icon(
              onPressed: () {
                // TODO: image_picker integration
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Attach Photo'),
            ),
            const SizedBox(height: 16),

            // Submit
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Submit Report'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
