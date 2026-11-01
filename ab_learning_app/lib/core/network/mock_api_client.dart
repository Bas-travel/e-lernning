import 'api_client.dart';
import 'api_exception.dart';

/// In-memory implementation of [ApiClient].
///
/// Response shapes are copied verbatim from `05-openapi.yaml` so switching
/// to [DioApiClient] later is a drop-in replacement — no model or UI code
/// needs to change.
///
/// Seed accounts (matches `db/init/02_seed.sql` on the Go side exactly, so
/// the same 5 logins work whether you're pointed at the mock or the real
/// backend):
///   learner@ablearning.com  / password123  (LEARNER)
///   krit@ablearning.com     / password123  (INSTRUCTOR)
///   corp@ablearning.com     / password123  (CORP_ADMIN)
///   employer@ablearning.com / password123  (EMPLOYER)
///   admin@ablearning.com    / password123  (ADMIN)
class MockApiClient implements ApiClient {
  /// Simulated round-trip latency so loading states are visible during
  /// development instead of flashing instantly.
  static const Duration _latency = Duration(milliseconds: 700);
  static final List<Map<String, dynamic>> _pendingCourses = [
    <String, dynamic>{
      'id': 3,
      'title': 'Prompt Engineering',
      'instructor_name': 'Bank',
      'category': 'AI',
      'submitted_at': DateTime.now().toIso8601String(),
    },
  ];
  static int _nextMockId = 10;
  static final List<Map<String, dynamic>> _mockCourses = [];
  static final List<Map<String, dynamic>> _mockEmployees = [
    {
      'id': 1,
      'name': 'Narin Pongsak',
      'email': 'narin@abc-tech.co',
      'department': 'Engineering',
      'status': 'active'
    },
    {
      'id': 2,
      'name': 'Pimchanok Sae-Tang',
      'email': 'pimchanok@abc-tech.co',
      'department': 'Design',
      'status': 'active'
    },
    {
      'id': 3,
      'name': 'Thanawat K.',
      'email': 'thanawat@abc-tech.co',
      'department': 'Sales',
      'status': 'inactive'
    },
  ];
  static final List<Map<String, dynamic>> _mockPaths = [
    {
      'id': 1,
      'name': 'Cloud Engineering Foundations',
      'goal': 'Engineering',
      'deadline': null,
      'courses': [
        {'id': 1, 'title': 'Go Backend Masterclass'}
      ]
    },
    {
      'id': 2,
      'name': 'Data Literacy for Teams',
      'goal': 'All departments',
      'deadline': null,
      'courses': [
        {'id': 2, 'title': 'AI for Business'}
      ]
    },
  ];
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'email': 'krit@ablearning.co',
      'role': 'INSTRUCTOR',
      'status': 'active',
      'first_name': 'Krit',
      'last_name': 'Anantasin'
    },
    {
      'id': 2,
      'email': 'learner@ablearning.co',
      'role': 'LEARNER',
      'status': 'active',
      'first_name': 'Anan',
      'last_name': 'Suksawat'
    },
    {
      'id': 3,
      'email': 'corpadmin@ablearning.co',
      'role': 'CORP_ADMIN',
      'status': 'active',
      'first_name': 'Corp',
      'last_name': 'Admin'
    },
  ];
  static final List<Map<String, dynamic>> _mockPayments = [
    {
      'id': 1,
      'order_code': 'TX-2026-0912',
      'user_email': 'learner@ablearning.co',
      'amount': 2490.0,
      'refunded_amount': 0.0,
      'method': 'card',
      'status': 'paid',
      'order_status': 'completed'
    },
    {
      'id': 2,
      'order_code': 'TX-2026-0911',
      'user_email': 'anan@ablearning.co',
      'amount': 1590.0,
      'refunded_amount': 0.0,
      'method': 'promptpay',
      'status': 'paid',
      'order_status': 'completed'
    },
  ];
  static final List<Map<String, dynamic>> _mockJobs = [
    {
      'id': 1,
      'title': 'Backend Developer',
      'description': '',
      'location': 'Bangkok',
      'status': 'open'
    },
    {
      'id': 2,
      'title': 'Product Designer',
      'description': '',
      'location': 'Remote',
      'status': 'open'
    },
  ];
  static final List<Map<String, dynamic>> _mockApplications = [
    {
      'id': 1,
      'user_id': 3,
      'name': 'Anan Suksawat',
      'email': 'anan@ablearning.co',
      'job_title': 'Backend Developer',
      'status': 'reviewed'
    },
  ];

  static final Map<String, Map<String, dynamic>> _seedUsers =
      <String, Map<String, dynamic>>{
    'learner@ablearning.com': <String, dynamic>{
      'id': 3,
      'role': 'LEARNER',
      'first_name': 'Anan',
      'last_name': 'Suksawat',
    },
    'krit@ablearning.com': <String, dynamic>{
      'id': 1,
      'role': 'INSTRUCTOR',
      'first_name': 'Krit',
      'last_name': 'Anantasin',
    },
    'corp@ablearning.com': <String, dynamic>{
      'id': 4,
      'role': 'CORP_ADMIN',
      'first_name': 'Siriwan',
      'last_name': 'Kittipong',
    },
    'employer@ablearning.com': <String, dynamic>{
      'id': 5,
      'role': 'EMPLOYER',
      'first_name': 'Pakorn',
      'last_name': 'Srisawat',
    },
    'admin@ablearning.com': <String, dynamic>{
      'id': 6,
      'role': 'ADMIN',
      'first_name': 'System',
      'last_name': 'Administrator',
    },
  };
  static final Map<String, Map<String, dynamic>> _registeredUsers = {};
  static final Map<String, String> _registeredPasswords = {};
  static int _nextRegisteredUserId = 100;

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final normalizedEmail = identifier.trim().toLowerCase();
    final Map<String, dynamic>? seed =
        _seedUsers[normalizedEmail] ?? _registeredUsers[normalizedEmail];
    final isValidPassword = _registeredPasswords.containsKey(normalizedEmail)
        ? _registeredPasswords[normalizedEmail] == password
        : password == 'password123';
    if (seed == null || !isValidPassword) {
      throw ApiException.invalidCredentials();
    }

    return <String, dynamic>{
      'access_token': 'mock-access-token-${seed['id']}',
      'refresh_token': 'mock-refresh-token-${seed['id']}',
      'user': <String, dynamic>{
        'id': seed['id'],
        'email': identifier.trim().toLowerCase(),
        'role': seed['role'],
        'first_name': seed['first_name'],
        'last_name': seed['last_name'],
        'avatar_url': null,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        !email.contains('@') ||
        password.length < 8) {
      throw const ApiException(
          code: 'VALIDATION_ERROR',
          message: 'Please enter valid registration details.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    if (_seedUsers.containsKey(normalizedEmail) ||
        _registeredUsers.containsKey(normalizedEmail)) {
      throw const ApiException(
          code: 'EMAIL_ALREADY_EXISTS',
          message: 'อีเมลนี้มีบัญชีแล้ว กรุณาเข้าสู่ระบบ');
    }
    final id = _nextRegisteredUserId++;
    _registeredUsers[normalizedEmail] = <String, dynamic>{
      'id': id,
      'role': 'LEARNER',
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
    };
    _registeredPasswords[normalizedEmail] = password;
    return <String, dynamic>{
      'id': id,
      'email': normalizedEmail,
      'role': 'LEARNER',
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'avatar_url': null,
    };
  }

  @override
  Future<Map<String, dynamic>> getHome() async {
    await Future<void>.delayed(_latency);

    return <String, dynamic>{
      'greeting_name': 'อนันต์',
      'continue_learning': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'title': 'Go Backend Masterclass',
          'instructor_name': 'Dr. Krit',
          'progress_pct': 68.0,
          'thumbnail_gradient': 'primary',
        },
      ],
      'recommended': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 2,
          'title': 'AI for Business',
          'instructor_name': 'Bank',
          'price': 1990.0,
          'discount_price': null,
          'rating_avg': 4.9,
          'thumbnail_gradient': 'primary',
        },
        <String, dynamic>{
          'id': 3,
          'title': 'Flutter Professional',
          'instructor_name': 'Mew',
          'price': 2490.0,
          'discount_price': null,
          'rating_avg': 4.8,
          'thumbnail_gradient': 'accent',
        },
        <String, dynamic>{
          'id': 4,
          'title': 'Digital Marketing',
          'instructor_name': 'Ploy',
          'price': 1590.0,
          'discount_price': null,
          'rating_avg': 4.7,
          'thumbnail_gradient': 'secondary',
        },
      ],
      'live': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'title': 'AI for Business — Live Q&A',
          'instructor_name': 'Bank',
          'scheduled_at':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'status': 'upcoming',
        },
      ],
      'career_path_progress_pct': 78.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getInstructorDashboard() async {
    await Future<void>.delayed(_latency);
    return <String, dynamic>{
      'course_count': 1,
      'total_students': 8421,
      'avg_rating': 4.9,
    };
  }

  @override
  Future<Map<String, dynamic>> getCorporateDashboard() async {
    await Future<void>.delayed(_latency);
    return <String, dynamic>{
      'organization_name': 'ABC Technology',
      'employee_count': 500,
      'registered_employees': 2,
      'training_budget': 500000.0,
      'active_learners': 1,
      'completion_rate_pct': 68.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getEmployerDashboard() async {
    await Future<void>.delayed(_latency);
    return <String, dynamic>{
      'company_name': 'TechCorp Thailand',
      'open_jobs': 2,
      'total_applications': 1,
      'shortlisted_count': 0,
      'hired_count': 0,
    };
  }

  @override
  Future<List<dynamic>> getEmployerTopApplicants() async {
    await Future<void>.delayed(_latency);
    return <dynamic>[
      <String, dynamic>{
        'user_id': 3,
        'name': 'Anan',
        'headline': 'Backend Developer',
        'match_score': 92.0,
        'job_title': 'Backend Developer',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getAdminDashboard() async {
    await Future<void>.delayed(_latency);
    return <String, dynamic>{
      'total_users': 6,
      'total_instructors': 2,
      'total_courses': 3,
      'total_revenue': 2990.0,
      'pending_moderation': 1,
    };
  }

  @override
  Future<List<dynamic>> getAdminPendingCourses() async {
    await Future<void>.delayed(_latency);
    return List<dynamic>.from(_pendingCourses);
  }

  @override
  Future<void> approveCourse(int id) async {
    await Future<void>.delayed(_latency);
    _pendingCourses.removeWhere((course) => course['id'] == id);
  }

  @override
  Future<void> rejectCourse(int id, {required String reason}) async {
    await Future<void>.delayed(_latency);
    _pendingCourses.removeWhere((course) => course['id'] == id);
  }

  @override
  Future<Map<String, dynamic>> getInstructorRevenue() async {
    await Future<void>.delayed(_latency);
    return {
      'gross': 96400.0,
      'platform_fee': 9640.0,
      'net': 86760.0,
      'pending': 12300.0,
      'paid_out': 74460.0,
      'payouts': <dynamic>[]
    };
  }

  @override
  Future<List<dynamic>> getInstructorCourses({String? status}) async {
    await Future<void>.delayed(_latency);
    return _mockCourses
        .where((course) => status == null || course['status'] == status)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createInstructorCourse(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final course = <String, dynamic>{
      'id': _nextMockId++,
      ...body,
      'status': 'draft',
      'category': body['category'] ?? 'Programming',
      'student_count': 0,
      'rating_avg': 0.0,
      'lesson_count': 0
    };
    _mockCourses.insert(0, course);
    return Map<String, dynamic>.from(course);
  }

  @override
  Future<Map<String, dynamic>> getInstructorCourse(int id) async {
    await Future<void>.delayed(_latency);
    final course = _mockCourses.firstWhere((item) => item['id'] == id);
    return Map<String, dynamic>.from(course);
  }

  @override
  Future<Map<String, dynamic>> createInstructorSection(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final section = <String, dynamic>{
      'id': _nextMockId++,
      'lessons': <dynamic>[],
      ...body
    };
    final course =
        _mockCourses.firstWhere((item) => item['id'] == body['course_id']);
    final sections = (course['sections'] as List<dynamic>? ?? <dynamic>[]);
    sections.add(section);
    course['sections'] = sections;
    return Map<String, dynamic>.from(section);
  }

  @override
  Future<Map<String, dynamic>> createInstructorLesson(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final lesson = <String, dynamic>{'id': _nextMockId++, ...body};
    for (final course in _mockCourses) {
      final sections = (course['sections'] as List<dynamic>? ?? <dynamic>[]);
      for (final section in sections.cast<Map<String, dynamic>>()) {
        if (section['id'] == body['section_id']) {
          (section['lessons'] as List<dynamic>).add(lesson);
          return Map<String, dynamic>.from(lesson);
        }
      }
    }
    throw StateError('Section not found');
  }

  @override
  Future<Map<String, dynamic>> uploadInstructorVideo(
      {required List<int> bytes, required String filename}) async {
    await Future<void>.delayed(_latency);
    return {
      'url': 'https://mock.invalid/uploads/$filename',
      'size_bytes': bytes.length
    };
  }

  @override
  Future<Map<String, dynamic>> submitInstructorCourse(int id) async {
    await Future<void>.delayed(_latency);
    final course = _mockCourses.firstWhere((item) => item['id'] == id);
    course['status'] = 'pending_review';
    return Map<String, dynamic>.from(course);
  }

  @override
  Future<List<dynamic>> getCategories() async {
    await Future<void>.delayed(_latency);
    return const [
      {'id': 1, 'name_en': 'Programming', 'name_th': 'การเขียนโปรแกรม'},
      {'id': 2, 'name_en': 'AI', 'name_th': 'ปัญญาประดิษฐ์'},
      {'id': 3, 'name_en': 'Data', 'name_th': 'ข้อมูล'},
      {'id': 4, 'name_en': 'Marketing', 'name_th': 'การตลาด'},
      {'id': 5, 'name_en': 'Business', 'name_th': 'ธุรกิจ'},
    ];
  }

  @override
  Future<List<dynamic>> getCourses({String? query, int page = 1}) async {
    await Future<void>.delayed(_latency);
    return const [
      {'id': 1, 'title': 'Go Backend Masterclass', 'status': 'published'},
      {'id': 2, 'title': 'AI for Business', 'status': 'published'},
    ];
  }

  @override
  Future<List<dynamic>> getCorporateEmployees(
      {String? query, String? department, String? status}) async {
    await Future<void>.delayed(_latency);
    final needle = query?.toLowerCase() ?? '';
    return _mockEmployees
        .where((e) =>
            (department == null ||
                department.isEmpty ||
                e['department'] == department) &&
            (status == null || status.isEmpty || e['status'] == status) &&
            ('${e['name']} ${e['email']}'.toLowerCase().contains(needle)))
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> addCorporateEmployee(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final employee = <String, dynamic>{
      'id': _nextMockId++,
      'name': body['email'],
      'email': body['email'],
      'department': body['department'] ?? '',
      'status': 'active',
      ...body
    };
    _mockEmployees.insert(0, employee);
    return Map<String, dynamic>.from(employee);
  }

  @override
  Future<void> updateCorporateEmployee(
      int id, Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final employee = _mockEmployees.firstWhere((item) => item['id'] == id);
    employee.addAll(body);
  }

  @override
  Future<List<dynamic>> getCorporateLearningPaths() async {
    await Future<void>.delayed(_latency);
    return _mockPaths.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createCorporateLearningPath(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final path = <String, dynamic>{
      'id': _nextMockId++,
      ...body,
      'courses': <dynamic>[]
    };
    _mockPaths.insert(0, path);
    return Map<String, dynamic>.from(path);
  }

  @override
  Future<List<dynamic>> getAdminUsers({String? query}) async {
    await Future<void>.delayed(_latency);
    final needle = query?.toLowerCase() ?? '';
    return _mockUsers
        .where((u) => '${u['email']} ${u['first_name']} ${u['last_name']}'
            .toLowerCase()
            .contains(needle))
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> updateAdminUser(
      int id, Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final user = _mockUsers.firstWhere((item) => item['id'] == id);
    user.addAll(body);
    return Map<String, dynamic>.from(user);
  }

  @override
  Future<Map<String, dynamic>> suspendAdminUser(int id,
          {String reason = ''}) async =>
      updateAdminUser(id, {'status': 'suspended'});

  @override
  Future<List<dynamic>> getAdminPayments({String? status}) async {
    await Future<void>.delayed(_latency);
    return _mockPayments
        .where((p) => status == null || p['status'] == status)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> refundAdminPayment(int id,
      {String reason = ''}) async {
    await Future<void>.delayed(_latency);
    final payment = _mockPayments.firstWhere((item) => item['id'] == id);
    payment['refunded_amount'] = payment['amount'];
    payment['status'] = 'refunded';
    return {'payment_id': id, 'total_refunded': payment['amount']};
  }

  @override
  Future<List<dynamic>> getEmployerJobs() async {
    await Future<void>.delayed(_latency);
    return _mockJobs.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createEmployerJob(
      Map<String, dynamic> body) async {
    await Future<void>.delayed(_latency);
    final job = <String, dynamic>{
      'id': _nextMockId++,
      'status': 'open',
      ...body
    };
    _mockJobs.insert(0, job);
    return Map<String, dynamic>.from(job);
  }

  @override
  Future<List<dynamic>> getEmployerApplications() async {
    await Future<void>.delayed(_latency);
    return _mockApplications.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> updateEmployerApplication(int id,
      {required String status}) async {
    await Future<void>.delayed(_latency);
    _mockApplications.firstWhere((item) => item['id'] == id)['status'] = status;
  }
}
