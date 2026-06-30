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
}
