class Announcement {
  final String id;
  final String title;
  final String body;
  final String postedBy;
  final String posterRole;
  final DateTime timestamp;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.postedBy,
    this.posterRole = '',
    required this.timestamp,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // Handle joined official data if present
    final posterName = json['official']?['profiles']?['full_name'] as String? ??
        json['posted_by'] as String? ?? 'Official';
    final role = json['official']?['role_title'] as String? ?? '';

    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      postedBy: posterName,
      posterRole: role,
      timestamp: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'posted_by': postedBy,
    };
  }
}
