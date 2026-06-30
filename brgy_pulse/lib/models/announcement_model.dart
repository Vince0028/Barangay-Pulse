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
    required this.posterRole,
    required this.timestamp,
  });
}
