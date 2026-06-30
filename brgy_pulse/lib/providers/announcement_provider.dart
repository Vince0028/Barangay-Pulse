import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';

class AnnouncementNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() => _seed;

  static final List<Announcement> _seed = [
    Announcement(
      id: 'ann_001',
      title: 'Water Interruption Notice',
      body: 'Maynilad will conduct maintenance on July 1-2. Expect low to no water pressure from 10PM to 5AM. Please store enough water for your household.',
      postedBy: 'Kap. Reyes',
      posterRole: 'Barangay Captain',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Announcement(
      id: 'ann_002',
      title: 'Free Blood Pressure Screening',
      body: 'The barangay health center will offer free BP and blood sugar screening this Saturday, 8AM-12PM at the covered court. Open to all residents aged 40 and above.',
      postedBy: 'Dr. Santos',
      posterRole: 'Health Officer',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Announcement(
      id: 'ann_003',
      title: 'Garbage Collection Schedule Change',
      body: 'Starting July 1, biodegradable waste collection moves to Monday/Wednesday/Friday. Non-biodegradable stays on Tuesday/Thursday. Please separate your waste properly.',
      postedBy: 'Kag. Mendoza',
      posterRole: 'Committee on Environment',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Announcement(
      id: 'ann_004',
      title: 'Barangay Assembly Meeting',
      body: 'General assembly meeting on July 5 at 3PM, covered court. Agenda includes the new curfew ordinance and flood drainage project update. All residents are encouraged to attend.',
      postedBy: 'Kap. Reyes',
      posterRole: 'Barangay Captain',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

final announcementProvider =
    NotifierProvider<AnnouncementNotifier, List<Announcement>>(AnnouncementNotifier.new);
