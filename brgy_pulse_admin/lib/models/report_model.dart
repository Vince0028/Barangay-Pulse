import 'package:latlong2/latlong.dart';

enum ReportCategory { trash, parking, noise, curfew, flood, sos, safeZone }

enum ReportStatus { pending, inProgress, resolved }

class Report {
  final String id;
  final String description;
  final ReportCategory category;
  final LatLng location;
  final ReportStatus status;
  final DateTime timestamp;
  final String reportedBy;
  final String? floodSeverity;
  final String? imageUrl;
  final String? adminNotes;
  final String? claimedBy;
  final DateTime? claimedAt;
  final DateTime? resolvedAt;
  final String? proofPhotoUrl;

  Report({
    required this.id,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.timestamp,
    required this.reportedBy,
    this.floodSeverity,
    this.imageUrl,
    this.adminNotes,
    this.claimedBy,
    this.claimedAt,
    this.resolvedAt,
    this.proofPhotoUrl,
  });

  Report copyWith({
    String? id, String? description, ReportCategory? category, LatLng? location,
    ReportStatus? status, DateTime? timestamp, String? reportedBy,
    String? floodSeverity, String? imageUrl, String? adminNotes,
    String? claimedBy, DateTime? claimedAt, DateTime? resolvedAt, String? proofPhotoUrl,
  }) {
    return Report(
      id: id ?? this.id, description: description ?? this.description,
      category: category ?? this.category, location: location ?? this.location,
      status: status ?? this.status, timestamp: timestamp ?? this.timestamp,
      reportedBy: reportedBy ?? this.reportedBy, floodSeverity: floodSeverity ?? this.floodSeverity,
      imageUrl: imageUrl ?? this.imageUrl, adminNotes: adminNotes ?? this.adminNotes,
      claimedBy: claimedBy ?? this.claimedBy, claimedAt: claimedAt ?? this.claimedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt, proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
    );
  }

  static ReportCategory _catFromStr(String s) {
    switch (s) {
      case 'trash': return ReportCategory.trash;
      case 'parking': return ReportCategory.parking;
      case 'noise': return ReportCategory.noise;
      case 'curfew': return ReportCategory.curfew;
      case 'flood': return ReportCategory.flood;
      case 'sos': return ReportCategory.sos;
      case 'safeZone': return ReportCategory.safeZone;
      default: return ReportCategory.trash;
    }
  }

  static ReportStatus _statusFromStr(String s) {
    switch (s) {
      case 'pending': return ReportStatus.pending;
      case 'in_progress': return ReportStatus.inProgress;
      case 'resolved': return ReportStatus.resolved;
      default: return ReportStatus.pending;
    }
  }

  static String statusToStr(ReportStatus s) {
    switch (s) {
      case ReportStatus.pending: return 'pending';
      case ReportStatus.inProgress: return 'in_progress';
      case ReportStatus.resolved: return 'resolved';
    }
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      description: json['description'] as String,
      category: _catFromStr(json['category'] as String),
      location: LatLng((json['latitude'] as num).toDouble(), (json['longitude'] as num).toDouble()),
      status: _statusFromStr(json['status'] as String),
      timestamp: DateTime.parse(json['created_at'] as String),
      reportedBy: json['reported_by'] as String? ?? 'Anonymous',
      floodSeverity: json['flood_severity'] as String?,
      imageUrl: json['image_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      claimedBy: json['claimed_by'] as String?,
      claimedAt: json['claimed_at'] != null ? DateTime.parse(json['claimed_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      proofPhotoUrl: json['proof_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'category': category.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'status': statusToStr(status),
      'reported_by': reportedBy,
      'flood_severity': floodSeverity,
      'admin_notes': adminNotes,
    };
  }
}
