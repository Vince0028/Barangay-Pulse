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
  final String? floodSeverity; // Low, Medium, High — only for flood reports

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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category.name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'imageUrl': imageUrl,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'reportedBy': reportedBy,
      'floodSeverity': floodSeverity,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      description: map['description'],
      category: ReportCategory.values.byName(map['category']),
      location: LatLng(map['location']['latitude'], map['location']['longitude']),
      imageUrl: map['imageUrl'],
      status: ReportStatus.values.byName(map['status']),
      timestamp: DateTime.parse(map['timestamp']),
      reportedBy: map['reportedBy'],
      floodSeverity: map['floodSeverity'],
    );
  }
}
