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

  static final Map<String, Map<String, dynamic>> _seedUsers = <String, Map<String, dynamic>>{
    'learner@ablearning.com': <String, dynamic>{
      'id': 3, 'role': 'LEARNER', 'first_name': 'Anan', 'last_name': 'Suksawat',
    },
    'krit@ablearning.com': <String, dynamic>{
      'id': 1, 'role': 'INSTRUCTOR', 'first_name': 'Krit', 'last_name': 'Anantasin',
    },
    'corp@ablearning.com': <String, dynamic>{
      'id': 4, 'role': 'CORP_ADMIN', 'first_name': 'Siriwan', 'last_name': 'Kittipong',
    },
    'employer@ablearning.com': <String, dynamic>{
      'id': 5, 'role': 'EMPLOYER', 'first_name': 'Pakorn', 'last_name': 'Srisawat',
    },
    'admin@ablearning.com': <String, dynamic>{
      'id': 6, 'role': 'ADMIN', 'first_name': 'System', 'last_name': 'Administrator',
    },
  };

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final Map<String, dynamic>? seed = _seedUsers[identifier.trim().toLowerCase()];
    if (seed == null || password != 'password123') {
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
    return <dynamic>[
      <String, dynamic>{
        'id': 3,
        'title': 'Prompt Engineering',
        'instructor_name': 'Bank',
        'category': 'AI',
        'submitted_at': DateTime.now().toIso8601String(),
      },
    ];
  }

  @override
  Future<void> approveCourse(int id) async {
    await Future<void>.delayed(_latency);
    // No state to mutate in the mock — a real MockApiClient with an
    // in-memory pending-courses list would remove `id` here.
  }
}
