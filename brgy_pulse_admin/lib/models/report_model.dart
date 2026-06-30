import 'package:latlong2/latlong.dart';

enum ReportCategory {
  trash,
  parking,
  noise,
  curfew,
  flood,
  sos,
  safeZone,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
}

class Report {
  final String id;
  final String description;
  final ReportCategory category;
  final LatLng location;
  final String? imageUrl;
  final ReportStatus status;
  final DateTime timestamp;
  final String reportedBy;
  final String? floodSeverity;
  final String? adminNotes;

  Report({
    required this.id,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    this.status = ReportStatus.pending,
    required this.timestamp,
    required this.reportedBy,
    this.floodSeverity,
    this.adminNotes,
  });

  Report copyWith({
    String? id,
    String? description,
    ReportCategory? category,
    LatLng? location,
    String? imageUrl,
    ReportStatus? status,
    DateTime? timestamp,
    String? reportedBy,
    String? floodSeverity,
    String? adminNotes,
  }) {
    return Report(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      reportedBy: reportedBy ?? this.reportedBy,
      floodSeverity: floodSeverity ?? this.floodSeverity,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
