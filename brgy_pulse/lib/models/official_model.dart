class Official {
  final String id;
  final String name;
  final String role;
  final int points;
  final int missionsCompleted;
  final double averageRating;
  final int ratingsCount;

  Official({
    required this.id,
    required this.name,
    required this.role,
    this.points = 0,
    this.missionsCompleted = 0,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
  });

  Official copyWith({
    String? id,
    String? name,
    String? role,
    int? points,
    int? missionsCompleted,
    double? averageRating,
    int? ratingsCount,
  }) {
    return Official(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      points: points ?? this.points,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }

  factory Official.fromJson(Map<String, dynamic> json) {
    return Official(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? 'Official',
      role: json['role_title'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      missionsCompleted: (json['missions_completed'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
    );
  }
}
