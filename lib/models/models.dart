class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.initial,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String initial;
  final String role;
  final DateTime createdAt;

  factory Profile.fromMap(Map<String, dynamic> map) {
    final name = (map['full_name'] as String?)?.trim();
    final email = (map['email'] as String?)?.trim() ?? '';
    return Profile(
      id: map['id'] as String,
      fullName: name == null || name.isEmpty ? email.split('@').first : name,
      email: email,
      initial: (map['avatar_initial'] as String?)?.isNotEmpty == true
          ? map['avatar_initial'] as String
          : (name == null || name.isEmpty ? 'S' : name[0].toUpperCase()),
      role: (map['role'] as String?) ?? 'user',
      createdAt: DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class DailyMetric {
  const DailyMetric({
    required this.date,
    required this.steps,
    required this.activeMinutes,
    required this.calories,
    required this.distanceKm,
  });

  final DateTime date;
  final int steps;
  final int activeMinutes;
  final int calories;
  final double distanceKm;

  factory DailyMetric.fromMap(Map<String, dynamic> map) {
    return DailyMetric(
      date: DateTime.tryParse((map['metric_date'] as String?) ?? '') ??
          DateTime.now(),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      activeMinutes: (map['active_minutes'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PlanItem {
  const PlanItem({
    this.id = '',
    required this.title,
    required this.detail,
    required this.durationMinutes,
    required this.intensity,
    this.status = 'planned',
  });

  final String id;
  final String title;
  final String detail;
  final int durationMinutes;
  final String intensity;
  final String status;

  bool get isDone => status == 'done';

  factory PlanItem.fromMap(Map<String, dynamic> map) {
    return PlanItem(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'Latihan',
      detail: (map['detail'] as String?) ?? '',
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
      intensity: (map['intensity'] as String?) ?? 'ringan',
      status: (map['status'] as String?) ?? 'planned',
    );
  }
}

class HomeSummary {
  const HomeSummary({
    required this.profile,
    required this.today,
    required this.target,
    required this.plans,
  });

  final Profile profile;
  final DailyMetric today;
  final int target;
  final List<PlanItem> plans;
}

class WeeklySummary {
  const WeeklySummary({
    required this.days,
    required this.totalSteps,
    required this.averageSteps,
    required this.activeDays,
    required this.totalDistance,
    required this.totalCalories,
  });

  final List<DailyMetric> days;
  final int totalSteps;
  final int averageSteps;
  final int activeDays;
  final double totalDistance;
  final int totalCalories;
}

class WorkoutItem {
  const WorkoutItem({
    this.id = '',
    required this.time,
    required this.title,
    required this.type,
    required this.durationMinutes,
    this.status = 'planned',
  });

  final String id;
  final String time;
  final String title;
  final String type;
  final int durationMinutes;
  final String status;

  bool get isDone => status == 'done';

  factory WorkoutItem.fromMap(Map<String, dynamic> map) {
    return WorkoutItem(
      id: (map['id'] as String?) ?? '',
      time: (map['start_time'] as String?) ?? '06:00',
      title: (map['title'] as String?) ?? 'Latihan',
      type: (map['workout_type'] as String?) ?? '',
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
      status: (map['status'] as String?) ?? 'planned',
    );
  }
}

class ReminderItem {
  const ReminderItem({required this.title, required this.body});

  final String title;
  final String body;

  factory ReminderItem.fromMap(Map<String, dynamic> map) {
    return ReminderItem(
      title: (map['title'] as String?) ?? 'Pengingat',
      body: (map['body'] as String?) ?? '',
    );
  }
}

class DayChip {
  const DayChip({
    required this.label,
    required this.date,
    required this.dateValue,
  });

  final String label;
  final int date;
  final DateTime dateValue;
}

class ScheduleSummary {
  const ScheduleSummary({
    required this.chips,
    required this.workouts,
    required this.reminder,
  });

  final List<DayChip> chips;
  final List<WorkoutItem> workouts;
  final ReminderItem? reminder;
}

class ProfileSummary {
  const ProfileSummary({
    required this.profile,
    required this.activeDays,
    required this.totalSteps,
    required this.target,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.themeLabel,
  });

  final Profile profile;
  final int activeDays;
  final int totalSteps;
  final int target;
  final bool reminderEnabled;
  final String reminderTime;
  final String themeLabel;
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.initial,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String initial;
  final String status;

  factory AdminUser.fromMap(Map<String, dynamic> map,
      {String status = 'Aktif'}) {
    final name = (map['full_name'] as String?)?.trim();
    final email = (map['email'] as String?)?.trim() ?? '';
    return AdminUser(
      id: map['id'] as String,
      name: name == null || name.isEmpty ? email.split('@').first : name,
      email: email,
      initial: (map['avatar_initial'] as String?)?.isNotEmpty == true
          ? map['avatar_initial'] as String
          : (name == null || name.isEmpty ? 'A' : name[0].toUpperCase()),
      status: (map['role'] as String?) == 'admin' ? 'Admin' : status,
    );
  }
}

class AdminSummary {
  const AdminSummary({
    required this.totalUsers,
    required this.activeUsers,
    required this.recent,
  });

  final int totalUsers;
  final int activeUsers;
  final List<AdminUser> recent;
}
