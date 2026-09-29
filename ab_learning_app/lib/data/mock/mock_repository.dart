import 'models.dart';

/// Temporary in-memory data source for Phase 1 screens.
/// Replace with real calls to `ab-learning-api` (see 05-openapi.yaml)
/// once the corresponding Go endpoints are ready.
class MockRepository {
  static const List<String> categories = [
    'All',
    'Programming',
    'Design',
    'Business',
    'Data',
    'Marketing',
  ];

  static const List<Course> courses = [
    Course(
      id: 'c1',
      title: 'Flutter for Beginners',
      instructor: 'Nina Sato',
      category: 'Programming',
      rating: 4.8,
      students: 12450,
      progress: 0.62,
      coverColorHex: '4338CA',
      totalLessons: 24,
      completedLessons: 15,
      description:
          'A hands-on introduction to building real, cross-platform apps with '
          'Flutter — from your very first widget to shipping a polished, '
          'navigable app with state management.',
      whatYouLearn: [
        'Set up a Flutter project and understand the widget tree',
        'Build responsive layouts with Rows, Columns, and Stacks',
        'Manage app state and navigate between screens',
        'Connect a Flutter app to a REST API',
      ],
      priceLabel: '฿1,290',
      originalPriceLabel: '฿2,490',
    ),
    Course(
      id: 'c2',
      title: 'UX Research Fundamentals',
      instructor: 'Marc Delgado',
      category: 'Design',
      rating: 4.6,
      students: 8320,
      progress: 0.2,
      coverColorHex: '0EA5E9',
      totalLessons: 18,
      completedLessons: 4,
      description:
          'Learn how to plan, run, and synthesize user research so your '
          'design decisions are backed by evidence instead of guesswork.',
      whatYouLearn: [
        'Plan a research study around a clear question',
        'Run effective user interviews and usability tests',
        'Synthesize findings into actionable insights',
        'Present research to stakeholders with confidence',
      ],
      priceLabel: '฿990',
    ),
    Course(
      id: 'c3',
      title: 'Go Backend Essentials',
      instructor: 'Priya Nair',
      category: 'Programming',
      rating: 4.9,
      students: 6103,
      progress: 0,
      coverColorHex: '7C3AED',
      totalLessons: 30,
      completedLessons: 0,
      description:
          'Build production-ready backend services in Go: HTTP handlers, '
          'clean architecture, database access, and deployment basics.',
      whatYouLearn: [
        'Structure a Go project using clean architecture',
        'Build REST handlers, services, and repositories',
        'Work with SQL databases from Go',
        'Containerize and deploy a Go API',
      ],
      priceLabel: '฿1,590',
      originalPriceLabel: '฿2,990',
    ),
    Course(
      id: 'c4',
      title: 'Data Storytelling with SQL',
      instructor: 'Ahmad Yusuf',
      category: 'Data',
      rating: 4.5,
      students: 4210,
      progress: 1.0,
      coverColorHex: '22C55E',
      totalLessons: 12,
      completedLessons: 12,
      description:
          'Go from raw tables to a compelling data story: write efficient '
          'SQL, then present findings in a way stakeholders actually act on.',
      whatYouLearn: [
        'Write joins, window functions, and aggregations confidently',
        'Spot the story hiding in a dataset',
        'Design dashboards that highlight what matters',
      ],
      priceLabel: '฿890',
    ),
    Course(
      id: 'c5',
      title: 'Growth Marketing Playbook',
      instructor: 'Elena Cruz',
      category: 'Marketing',
      rating: 4.4,
      students: 3987,
      progress: 0,
      coverColorHex: 'F59E0B',
      totalLessons: 16,
      completedLessons: 0,
      description:
          'A practical playbook for growth: funnels, channels, and the '
          'experiments that actually move the needle for early-stage teams.',
      whatYouLearn: [
        'Map a full-funnel growth strategy',
        'Pick the right channels for your stage',
        'Run and evaluate growth experiments',
      ],
      priceLabel: '฿1,090',
    ),
  ];

  static List<Course> get enrolledCourses =>
      courses.where((c) => c.completedLessons > 0 || c.progress > 0).toList();

  static Course courseById(String id) =>
      courses.firstWhere((c) => c.id == id, orElse: () => courses.first);

  // --- Curriculum & lesson progress ------------------------------------
  //
  // The prototype uses a single shared curriculum/lesson set regardless of
  // course id (see original `curriculumFor` stub). Lesson completion is
  // tracked dynamically here so the "mark complete -> unlock next lesson"
  // flow in the lesson player and quiz screens actually works during a
  // session, without needing a real backend yet.

  static final Set<String> _completedLessonIds = {'l1', 'l2'};

  static const List<_LessonBlueprint> _lessonBlueprints = [
    _LessonBlueprint(id: 'l1', title: 'Welcome & Setup', duration: '4:12'),
    _LessonBlueprint(id: 'l2', title: 'Environment Setup', duration: '9:40'),
    _LessonBlueprint(id: 'l3', title: 'Your First Widget', duration: '12:05'),
    _LessonBlueprint(id: 'l4', title: 'State Management Basics', duration: '15:20'),
    _LessonBlueprint(id: 'l5', title: 'Navigation & Routing', duration: '11:08'),
    _LessonBlueprint(id: 'l6', title: 'Section Quiz', duration: '10 questions', hasQuiz: true),
    _LessonBlueprint(id: 'l7', title: 'Connecting to an API', duration: '18:32'),
    _LessonBlueprint(id: 'l8', title: 'Final Project Walkthrough', duration: '22:14'),
  ];

  static const Map<int, String> _sectionTitleByStartIndex = {
    0: 'Section 1 · Getting Started',
    3: 'Section 2 · Core Concepts',
    6: 'Section 3 · Building a Real App',
  };

  static LessonState _stateFor(int index) {
    final id = _lessonBlueprints[index].id;
    if (_completedLessonIds.contains(id)) return LessonState.completed;
    final firstIncomplete = _lessonBlueprints
        .indexWhere((l) => !_completedLessonIds.contains(l.id));
    if (index == firstIncomplete) return LessonState.inProgress;
    return LessonState.locked;
  }

  static List<CourseSection> curriculumFor(String courseId) {
    final sections = <CourseSection>[];
    List<LessonItem> current = [];
    String currentTitle = _sectionTitleByStartIndex[0]!;

    for (var i = 0; i < _lessonBlueprints.length; i++) {
      if (_sectionTitleByStartIndex.containsKey(i)) {
        if (current.isNotEmpty) {
          sections.add(CourseSection(title: currentTitle, lessons: current));
        }
        currentTitle = _sectionTitleByStartIndex[i]!;
        current = [];
      }
      final bp = _lessonBlueprints[i];
      current.add(LessonItem(
        id: bp.id,
        title: bp.title,
        duration: bp.duration,
        state: _stateFor(i),
        hasQuiz: bp.hasQuiz,
      ));
    }
    if (current.isNotEmpty) {
      sections.add(CourseSection(title: currentTitle, lessons: current));
    }
    return sections;
  }

  static LessonItem? lessonById(String lessonId) {
    for (final section in curriculumFor('')) {
      for (final lesson in section.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  /// Marks [lessonId] as completed, which unlocks the next lesson in order.
  static void completeLesson(String lessonId) {
    _completedLessonIds.add(lessonId);
  }

  /// Returns the lesson immediately after [lessonId], or null if it was the
  /// last one in the curriculum.
  static LessonItem? nextLessonAfter(String lessonId) {
    final index = _lessonBlueprints.indexWhere((l) => l.id == lessonId);
    if (index == -1 || index + 1 >= _lessonBlueprints.length) return null;
    final next = _lessonBlueprints[index + 1];
    return lessonById(next.id);
  }

  static bool isLastLesson(String lessonId) =>
      _lessonBlueprints.isNotEmpty && _lessonBlueprints.last.id == lessonId;

  static const List<QuizQuestion> sampleQuiz = [
    QuizQuestion(
      question: 'What does the "StatelessWidget" class describe in Flutter?',
      options: [
        'A widget that never rebuilds after the first frame',
        'A widget with immutable configuration that Flutter can rebuild anytime',
        'A widget that manages a database connection',
        'A widget that only works on iOS',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which widget is commonly used for declarative navigation?',
      options: ['ListView', 'go_router / Navigator', 'FutureBuilder', 'Theme'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What is the purpose of "setState" in a StatefulWidget?',
      options: [
        'To permanently delete a widget',
        'To fetch data from the network',
        'To notify the framework that internal state changed and the UI should rebuild',
        'To compile the app',
      ],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'In the AB LEARNING curriculum model, what unlocks the next lesson?',
      options: [
        'Paying an extra fee',
        'Completing the current lesson (and its quiz, if any)',
        'Nothing, all lessons are always unlocked',
        'Waiting 24 hours',
      ],
      correctIndex: 1,
    ),
  ];

  static const List<SkillScore> skillBreakdown = [
    SkillScore(skill: 'Widgets & Layout', percent: 0.9),
    SkillScore(skill: 'State Management', percent: 0.55),
    SkillScore(skill: 'Navigation', percent: 0.75),
    SkillScore(skill: 'API Integration', percent: 0.4),
  ];

  static List<ChatMessage> initialTutorThread(String contextTitle) => [
        ChatMessage(
          text: 'สวัสดีครับ! ผมคือ AI Tutor พร้อมช่วยเรื่อง "$contextTitle" ถามอะไรก็ได้เลยครับ',
          fromUser: false,
        ),
      ];

  static const List<String> tutorSuggestedQuestions = [
    'สรุปบทเรียนนี้ให้หน่อย',
    'ยกตัวอย่างเพิ่มเติม',
    'ช่วยออกข้อสอบให้หน่อย',
    'ให้คำแนะนำสายอาชีพ',
  ];

  /// Very small canned-response "AI" so the AI Tutor shell feels alive
  /// without a real model behind it yet. Replace with `POST /api/v1/ai/tutor`
  /// once available.
  static String mockTutorReply(String userMessage) {
    final text = userMessage.trim().toLowerCase();
    if (text.contains('สรุป') || text.contains('summar')) {
      return 'สรุปสั้น ๆ ให้นะครับ: บทเรียนนี้เน้นแนวคิดหลัก 2-3 อย่างที่คุณเพิ่งเรียนไป '
          'ลองทบทวนโน้ตของคุณแล้วลองอธิบายเป็นคำพูดของตัวเองดูครับ จะช่วยให้จำได้แม่นขึ้น';
    }
    if (text.contains('ตัวอย่าง') || text.contains('example')) {
      return 'ได้เลยครับ ลองนึกภาพสถานการณ์จริงที่ใช้เรื่องนี้ เช่น การนำไปประยุกต์ใช้ในโปรเจกต์เล็ก ๆ '
          'ของคุณเอง จะช่วยให้เห็นภาพชัดขึ้นมากครับ';
    }
    if (text.contains('ข้อสอบ') || text.contains('quiz')) {
      return 'ลองทำแบบทดสอบท้ายบทดูก่อนได้เลยครับ ถ้าอยากได้โจทย์เพิ่มเติมบอกได้นะครับ '
          'ผมจะช่วยออกโจทย์ให้ตรงกับจุดที่คุณยังไม่มั่นใจ';
    }
    if (text.contains('อาชีพ') || text.contains('career')) {
      return 'สำหรับสายอาชีพนี้ แนะนำให้สร้างพอร์ตโฟลิโอควบคู่ไปกับการเรียนครับ '
          'ลองเริ่มจากโปรเจกต์เล็ก ๆ ที่โชว์ทักษะที่คุณเพิ่งเรียนไปได้เลย';
    }
    return 'เข้าใจแล้วครับ ลองเล่ารายละเอียดเพิ่มเติมอีกนิดได้ไหมครับ จะได้ช่วยแนะนำได้ตรงจุดมากขึ้น';
  }

  // --- Role dashboards (Phase 2 — RBAC + Role Shell) --------------------
  //
  // KPI values below are static mock numbers matching the fields called out
  // in `01-screens-spec.md` screens 31/36/39/40. Replace with
  // `GET /api/v1/{instructor,corporate,employer,admin}/dashboard` in Phase 3.

  static const List<KpiStat> instructorKpis = [
    KpiStat(label: 'Revenue', value: '฿86,400', deltaLabel: '+12% this month'),
    KpiStat(label: 'Students', value: '1,284', deltaLabel: '+64 new'),
    KpiStat(label: 'Courses', value: '5'),
    KpiStat(label: 'Rating', value: '4.8'),
    KpiStat(label: 'Completion', value: '71%', deltaLabel: '+3%'),
  ];

  static const List<KpiStat> corporateKpis = [
    KpiStat(label: 'Employees', value: '212'),
    KpiStat(label: 'Active Learners', value: '158'),
    KpiStat(label: 'Completion Rate', value: '64%', deltaLabel: '+5%'),
    KpiStat(label: 'Training Hours', value: '3,420'),
    KpiStat(label: 'Budget Used', value: '฿410,000'),
  ];

  static const List<KpiStat> employerKpis = [
    KpiStat(label: 'Candidates', value: '96'),
    KpiStat(label: 'Applications', value: '312', deltaLabel: '+21 this week'),
    KpiStat(label: 'Open Jobs', value: '7'),
    KpiStat(label: 'Shortlisted', value: '18'),
    KpiStat(label: 'Hired', value: '4'),
  ];

  static const List<KpiStat> adminKpis = [
    KpiStat(label: 'Users', value: '18,240', deltaLabel: '+340 this week'),
    KpiStat(label: 'Learners', value: '16,900'),
    KpiStat(label: 'Instructors', value: '312'),
    KpiStat(label: 'Revenue', value: '฿2.1M', deltaLabel: '+8%'),
    KpiStat(label: 'GMV', value: '฿4.8M'),
    KpiStat(label: 'Courses', value: '540'),
    KpiStat(label: 'Live Sessions', value: '12'),
    KpiStat(label: 'Open Reports', value: '6', deltaIsPositive: false, deltaLabel: 'needs review'),
  ];
}

class _LessonBlueprint {
  final String id;
  final String title;
  final String duration;
  final bool hasQuiz;

  const _LessonBlueprint({
    required this.id,
    required this.title,
    required this.duration,
    this.hasQuiz = false,
  });
}
