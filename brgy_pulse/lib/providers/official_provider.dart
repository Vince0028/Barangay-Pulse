import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/official_model.dart';

class OfficialNotifier extends Notifier<List<Official>> {
  @override
  List<Official> build() => _seed;

  void rateOfficial(String id, double rating) {
    state = state.map((o) {
      if (o.id != id) return o;
      final newCount = o.ratingsCount + 1;
      final newAvg = ((o.averageRating * o.ratingsCount) + rating) / newCount;
      return o.copyWith(averageRating: newAvg, ratingsCount: newCount);
    }).toList();
  }

  static final List<Official> _seed = [
    Official(
      id: 'off_001',
      name: 'Kap. Ricardo Reyes',
      role: 'Barangay Captain',
      points: 450,
      missionsCompleted: 32,
      averageRating: 4.5,
      ratingsCount: 28,
    ),
    Official(
      id: 'off_002',
      name: 'Kag. Maria Mendoza',
      role: 'Kagawad - Environment',
      points: 320,
      missionsCompleted: 24,
      averageRating: 4.2,
      ratingsCount: 15,
    ),
    Official(
      id: 'off_003',
      name: 'Tanod Jun Bautista',
      role: 'Barangay Tanod',
      points: 580,
      missionsCompleted: 45,
      averageRating: 4.8,
      ratingsCount: 38,
    ),
    Official(
      id: 'off_004',
      name: 'Kag. Elena Cruz',
      role: 'Kagawad - Peace & Order',
      points: 210,
      missionsCompleted: 16,
      averageRating: 3.9,
      ratingsCount: 12,
    ),
    Official(
      id: 'off_005',
      name: 'Tanod Mark Villanueva',
      role: 'Barangay Tanod',
      points: 390,
      missionsCompleted: 29,
      averageRating: 4.6,
      ratingsCount: 22,
    ),
  ];
}

final officialProvider =
    NotifierProvider<OfficialNotifier, List<Official>>(OfficialNotifier.new);
