import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/home_repository.dart';
import '../models/home_feed.dart';

final Provider<HomeRepository> homeRepositoryProvider =
    Provider<HomeRepository>((ref) {
  return HomeRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drives screen 08 (Home). Exposes an [AsyncValue] so the UI can render
/// the Loading / Error / Success states required by the state contract in
/// `00-blueprint-overview.md` §6 with a three-line `.when(...)` in the view.
///
/// Pull-to-refresh calls `ref.invalidate(homeFeedProvider)`, which reruns
/// this function and the UI rebuilds automatically.
final FutureProvider<HomeFeed> homeFeedProvider =
    FutureProvider<HomeFeed>((ref) {
  final HomeRepository repository = ref.watch(homeRepositoryProvider);
  return repository.getHomeFeed();
});
