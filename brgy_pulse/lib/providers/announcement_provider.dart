import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repositories/announcement_repo.dart';

class AnnouncementNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() => [];

  Future<void> refresh() async {
    state = await AnnouncementRepository.fetchAll();
  }
}

final announcementProvider =
    NotifierProvider<AnnouncementNotifier, List<Announcement>>(AnnouncementNotifier.new);
