import '../../../core/format/baht.dart';
import '../models/home_feed.dart';
import 'home_sample_data.dart';

/// A course the learner already started, shown in "เรียนต่อ".
class HomeContinue {
  const HomeContinue({
    required this.title,
    required this.progress,
    required this.route,
  });

  final String title;

  /// 0..1
  final double progress;

  /// Where tapping the card goes.
  final String route;
}

class HomeLive {
  const HomeLive({required this.title, required this.startsIn});

  final String title;
  final String startsIn;
}

/// Everything the Home screen shows that can come from the server, built
/// either from the bundled sample data or from `GET /home`.
class HomeContent {
  const HomeContent({
    required this.careerProgress,
    required this.continueItems,
    required this.recommended,
    required this.live,
  });

  /// The demo content from the mockup (offline / slug ids).
  factory HomeContent.sample() {
    return const HomeContent(
      careerProgress: HomeSampleData.careerProgress,
      continueItems: [
        HomeContinue(
          title: HomeSampleData.continueTitle,
          progress: HomeSampleData.continueProgress,
          route: '/player/${HomeSampleData.continueLessonId}',
        ),
      ],
      recommended: HomeSampleData.recommended,
      live: HomeLive(
        title: HomeSampleData.liveTitle,
        startsIn: HomeSampleData.liveStartsIn,
      ),
    );
  }

  factory HomeContent.fromFeed(HomeFeed feed) {
    final live = feed.live.isEmpty ? null : feed.live.first;
    return HomeContent(
      careerProgress: _fraction(feed.careerPathProgressPct),
      continueItems: [
        for (final c in feed.continueLearning)
          HomeContinue(
            title: c.title,
            progress: _fraction(c.progressPct ?? 0),
            route: '/course/${c.id}',
          ),
      ],
      recommended: [
        for (final c in feed.recommended)
          HomeCourse(
            id: '${c.id}',
            title: c.title,
            rating: c.ratingAvg == null
                ? ''
                : '${c.ratingAvg!.toStringAsFixed(1)} ★',
            price: formatBaht(c.discountPrice ?? c.price),
            gradient: c.thumbnailGradient,
          ),
      ],
      live: live == null
          ? null
          : HomeLive(title: live.title, startsIn: live.startsInLabel()),
    );
  }

  final double careerProgress;
  final List<HomeContinue> continueItems;
  final List<HomeCourse> recommended;
  final HomeLive? live;

  static double _fraction(double percent) => (percent / 100).clamp(0.0, 1.0);
}
