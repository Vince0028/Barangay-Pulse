import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/official_model.dart';
import '../repositories/official_repo.dart';

class OfficialNotifier extends Notifier<List<Official>> {
  @override
  List<Official> build() => [];

  Future<void> refresh() async {
    state = await OfficialRepository.fetchAll();
  }

  void rateOfficial(String id, double rating) {
    // Update locally
    state = state.map((o) {
      if (o.id != id) return o;
      final newCount = o.ratingsCount + 1;
      final newAvg = ((o.averageRating * o.ratingsCount) + rating) / newCount;
      return o.copyWith(averageRating: newAvg, ratingsCount: newCount);
    }).toList();

    // Persist to Supabase
    OfficialRepository.submitRating(id, rating.toInt());
  }
}

final officialProvider =
    NotifierProvider<OfficialNotifier, List<Official>>(OfficialNotifier.new);
