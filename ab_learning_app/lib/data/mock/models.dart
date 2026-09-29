class Course {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final double rating;
  final int students;
  final double progress; // 0..1, only meaningful for enrolled courses
  final String coverColorHex;
  final int totalLessons;
  final int completedLessons;
  final String description;
  final List<String> whatYouLearn;
  final String priceLabel;
  final String? originalPriceLabel;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.rating,
    required this.students,
    this.progress = 0,
    required this.coverColorHex,
    required this.totalLessons,
    required this.completedLessons,
    this.description = '',
    this.whatYouLearn = const [],
    this.priceLabel = 'Free',
    this.originalPriceLabel,
  });
}

class LessonItem {
  final String id;
  final String title;
  final String duration;
  final LessonState state;
  final bool hasQuiz;

  const LessonItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.state,
    this.hasQuiz = false,
  });
}

enum LessonState { locked, inProgress, completed }

class CourseSection {
  final String title;
  final List<LessonItem> lessons;

  const CourseSection({required this.title, required this.lessons});
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class SkillScore {
  final String skill;
  final double percent; // 0..1

  const SkillScore({required this.skill, required this.percent});
}

class ChatMessage {
  final String text;
  final bool fromUser;

  const ChatMessage({required this.text, required this.fromUser});
}

/// Result of a completed quiz attempt, built client-side from mock data.
/// Shape mirrors `quiz_attempts` in `05-openapi.yaml` so swapping in
/// `POST /api/v1/quizzes/{id}/submit` later only touches the data source.
class QuizAttemptResult {
  final int correctCount;
  final int totalCount;
  final List<int?> selectedAnswers;

  const QuizAttemptResult({
    required this.correctCount,
    required this.totalCount,
    required this.selectedAnswers,
  });

  double get scorePercent => totalCount == 0 ? 0 : correctCount / totalCount;

  bool get isPass => scorePercent >= 0.6;
}

// --- RBAC -----------------------------------------------------------------
//
// Mirrors the `role` enum on `User` in `05-openapi.yaml`
// (GUEST/LEARNER/INSTRUCTOR/CORP_ADMIN/CORP_MANAGER/EMPLOYER/ADMIN). GUEST is
// the pre-login state and isn't represented here since the app requires a
// role once logged in.
enum UserRole { learner, instructor, corpAdmin, corpManager, employer, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.learner:
        return 'Learner';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.corpAdmin:
        return 'Corporate Admin';
      case UserRole.corpManager:
        return 'Corporate Manager';
      case UserRole.employer:
        return 'Employer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Route both corporate roles share the same shell — they differ only in
  /// permissions (e.g. billing) once the backend enforces that in Phase 3+.
  bool get isCorporate => this == UserRole.corpAdmin || this == UserRole.corpManager;
}

/// A single KPI stat shown at the top of a role dashboard (screens 31, 36,
/// 39, 40). `deltaLabel` is optional trend text, e.g. "+12% this month".
class KpiStat {
  final String label;
  final String value;
  final String? deltaLabel;
  final bool deltaIsPositive;

  const KpiStat({
    required this.label,
    required this.value,
    this.deltaLabel,
    this.deltaIsPositive = true,
  });
}
