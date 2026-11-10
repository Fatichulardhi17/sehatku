import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../core/formatters.dart';
import '../models/models.dart';

class HealthRepository {
  HealthRepository(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) {
      throw const AppException('Supabase belum dikonfigurasi.');
    }
    return client;
  }

  User get _user {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AppException('Silakan masuk terlebih dahulu.');
    }
    return user;
  }

  String get _todayIso => _iso(DateTime.now());

  Future<HomeSummary> loadHome() async {
    final db = _db;
    final user = _user;
    final uid = user.id;

    final profileRow =
        await db.from('profiles').select().eq('id', uid).maybeSingle();
    final settingsRow = await db
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    final metricRows = await db
        .from('daily_metrics')
        .select()
        .eq('user_id', uid)
        .order('metric_date', ascending: false)
        .limit(1);
    final planRows = await db
        .from('plans')
        .select()
        .eq('user_id', uid)
        .eq('plan_date', _todayIso)
        .order('sort_position');

    final metrics = (metricRows as List<dynamic>)
        .map(
            (row) => DailyMetric.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final plans = (planRows as List<dynamic>)
        .map((row) => PlanItem.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final target = settingsRow == null
        ? 8000
        : ((settingsRow['daily_step_target'] as num?)?.toInt() ?? 8000);

    return HomeSummary(
      profile: profileRow == null
          ? _profileFromAuth(user)
          : Profile.fromMap(profileRow),
      today: metrics.isEmpty ? _emptyMetric() : metrics.first,
      target: target,
      plans: plans,
    );
  }

  Future<WeeklySummary> loadWeekly() async {
    final db = _db;
    final uid = _user.id;
    final start = _iso(DateTime.now().subtract(const Duration(days: 6)));
    final rows = await db
        .from('daily_metrics')
        .select()
        .eq('user_id', uid)
        .gte('metric_date', start)
        .order('metric_date');
    final days = (rows as List<dynamic>)
        .map(
            (row) => DailyMetric.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final totalSteps = days.fold<int>(0, (sum, day) => sum + day.steps);
    final totalDistance =
        days.fold<double>(0, (sum, day) => sum + day.distanceKm);
    final totalCalories = days.fold<int>(0, (sum, day) => sum + day.calories);

    return WeeklySummary(
      days: days,
      totalSteps: totalSteps,
      averageSteps: days.isEmpty ? 0 : (totalSteps / days.length).round(),
      activeDays: days.where((day) => day.steps > 0).length,
      totalDistance: totalDistance,
      totalCalories: totalCalories,
    );
  }

  Future<ScheduleSummary> loadSchedule({DateTime? date}) async {
    final db = _db;
    final uid = _user.id;
    final selected = date ?? DateTime.now();
    final rows = await db
        .from('workouts')
        .select()
        .eq('user_id', uid)
        .eq('workout_date', _iso(selected))
        .order('start_time');
    final reminderRows = await db
        .from('reminders')
        .select()
        .eq('user_id', uid)
        .eq('enabled', true)
        .order('remind_at')
        .limit(1);
    final workouts = (rows as List<dynamic>)
        .map(
            (row) => WorkoutItem.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final reminders = (reminderRows as List<dynamic>);
    final reminder = reminders.isEmpty
        ? null
        : ReminderItem.fromMap(
            Map<String, dynamic>.from(reminders.first as Map),
          );

    return ScheduleSummary(
      chips: _buildChips(),
      workouts: workouts,
      reminder: reminder,
    );
  }

  Future<ProfileSummary> loadProfile() async {
    final db = _db;
    final user = _user;
    final uid = user.id;
    final profileRow =
        await db.from('profiles').select().eq('id', uid).maybeSingle();
    final settingsRow = await db
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    final rows = await db
        .from('daily_metrics')
        .select()
        .eq('user_id', uid)
        .order('metric_date', ascending: false)
        .limit(30);
    final days = (rows as List<dynamic>)
        .map(
            (row) => DailyMetric.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
    final totalSteps = days.fold<int>(0, (sum, day) => sum + day.steps);
    final theme = settingsRow == null
        ? 'light'
        : (settingsRow['theme'] as String? ?? 'light');
    final target = settingsRow == null
        ? 8000
        : ((settingsRow['daily_step_target'] as num?)?.toInt() ?? 8000);
    final reminderEnabled = settingsRow == null
        ? true
        : (settingsRow['reminder_enabled'] as bool? ?? true);
    final reminderTime = settingsRow == null
        ? '07:00:00'
        : (settingsRow['reminder_time'] as String? ?? '07:00:00');

    return ProfileSummary(
      profile: profileRow == null
          ? _profileFromAuth(user)
          : Profile.fromMap(profileRow),
      activeDays: days.where((day) => day.steps > 0).length,
      totalSteps: totalSteps,
      target: target,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      themeLabel: switch (theme) {
        'dark' => 'Gelap',
        'system' => 'Sistem',
        _ => 'Terang',
      },
    );
  }

  Future<AdminSummary> loadAdminSummary() async {
    final db = _db;
    await _assertAdmin(db);
    final profiles = await db
        .from('profiles')
        .select('id, full_name, email, avatar_initial, role, created_at')
        .order('created_at', ascending: false);
    final rows = profiles as List<dynamic>;
    final activeIds = await _activeUserIds(db);
    final users = rows
        .map(
          (row) => _toAdminUser(
            Map<String, dynamic>.from(row as Map),
            activeIds,
          ),
        )
        .toList();

    return AdminSummary(
      totalUsers: users.length,
      activeUsers: activeIds.length,
      recent: users.take(4).toList(),
    );
  }

  Future<List<AdminUser>> loadAdminUsers() async {
    final db = _db;
    await _assertAdmin(db);
    final profiles = await db
        .from('profiles')
        .select('id, full_name, email, avatar_initial, role, created_at')
        .order('created_at', ascending: false)
        .limit(50);
    final rows = profiles as List<dynamic>;
    final activeIds = await _activeUserIds(db);

    return rows
        .map(
          (row) => _toAdminUser(
            Map<String, dynamic>.from(row as Map),
            activeIds,
          ),
        )
        .toList();
  }

  Future<void> _assertAdmin(SupabaseClient db) async {
    final uid = _user.id;
    final row =
        await db.from('profiles').select('role').eq('id', uid).maybeSingle();
    if (row == null || row['role'] != 'admin') {
      throw const AppException('Akses admin diperlukan.');
    }
  }

  Future<Set<String>> _activeUserIds(SupabaseClient db) async {
    final since = _iso(DateTime.now().subtract(const Duration(days: 7)));
    final rows = await db
        .from('daily_metrics')
        .select('user_id')
        .gte('metric_date', since);
    return {
      for (final row in rows as List<dynamic>)
        (row as Map)['user_id'] as String,
    };
  }

  AdminUser _toAdminUser(Map<String, dynamic> row, Set<String> activeIds) {
    final id = row['id'] as String;
    final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '') ??
        DateTime.now();
    final status = activeIds.contains(id)
        ? 'Aktif'
        : DateTime.now().difference(createdAt).inDays <= 7
            ? 'Baru'
            : 'Tidak aktif';
    return AdminUser.fromMap(row, status: status);
  }

  Profile _profileFromAuth(User user) {
    final email = user.email ?? '';
    final metadataName = (user.userMetadata?['full_name'] as String?)?.trim();
    final name = metadataName == null || metadataName.isEmpty
        ? (email.isEmpty ? 'Pengguna' : email.split('@').first)
        : metadataName;
    final createdAt = DateTime.tryParse(user.createdAt) ?? DateTime.now();
    return Profile(
      id: user.id,
      fullName: name,
      email: email,
      initial: name.isEmpty ? 'S' : name[0].toUpperCase(),
      role: 'user',
      createdAt: createdAt,
    );
  }

  DailyMetric _emptyMetric() => DailyMetric(
        date: DateTime.now(),
        steps: 0,
        activeMinutes: 0,
        calories: 0,
        distanceKm: 0,
      );

  Future<void> logTodayMetric({
    required int steps,
    required int activeMinutes,
    required int calories,
    double? distanceKm,
    DateTime? date,
  }) async {
    final db = _db;
    final uid = _user.id;
    final targetDate = _iso(date ?? DateTime.now());
    final distance = distanceKm ?? (steps * 0.00075);

    await db.from('daily_metrics').upsert({
      'user_id': uid,
      'metric_date': targetDate,
      'steps': steps,
      'active_minutes': activeMinutes,
      'calories': calories,
      'distance_km': double.parse(distance.toStringAsFixed(2)),
    }, onConflict: 'user_id,metric_date');
  }

  Future<void> addPlan({
    required String title,
    String detail = '',
    int durationMinutes = 0,
    String intensity = 'ringan',
    DateTime? date,
  }) async {
    final db = _db;
    final uid = _user.id;
    final targetDate = _iso(date ?? DateTime.now());

    await db.from('plans').insert({
      'user_id': uid,
      'plan_date': targetDate,
      'title': title.trim(),
      'detail': detail.trim(),
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'status': 'planned',
    });
  }

  Future<void> togglePlanStatus({
    required String planId,
    required bool isDone,
  }) async {
    final db = _db;
    final uid = _user.id;

    await db
        .from('plans')
        .update({'status': isDone ? 'done' : 'planned'})
        .eq('id', planId)
        .eq('user_id', uid);
  }

  Future<void> addWorkout({
    required String title,
    required String workoutType,
    required String startTime,
    required int durationMinutes,
    DateTime? date,
  }) async {
    final db = _db;
    final uid = _user.id;
    final targetDate = _iso(date ?? DateTime.now());

    await db.from('workouts').insert({
      'user_id': uid,
      'workout_date': targetDate,
      'title': title.trim(),
      'workout_type': workoutType.trim(),
      'start_time': startTime,
      'duration_minutes': durationMinutes,
      'status': 'planned',
    });
  }

  Future<void> toggleWorkoutStatus({
    required String workoutId,
    required bool isDone,
  }) async {
    final db = _db;
    final uid = _user.id;

    await db
        .from('workouts')
        .update({'status': isDone ? 'done' : 'planned'})
        .eq('id', workoutId)
        .eq('user_id', uid);
  }

  Future<void> updateUserSettings({
    int? dailyStepTarget,
    bool? reminderEnabled,
    String? reminderTime,
    String? theme,
  }) async {
    final db = _db;
    final uid = _user.id;

    final updates = <String, dynamic>{
      'user_id': uid,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (dailyStepTarget != null) updates['daily_step_target'] = dailyStepTarget;
    if (reminderEnabled != null) updates['reminder_enabled'] = reminderEnabled;
    if (reminderTime != null) updates['reminder_time'] = reminderTime;
    if (theme != null) updates['theme'] = theme;

    await db.from('user_settings').upsert(updates, onConflict: 'user_id');
  }

  List<DayChip> _buildChips() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return List<DayChip>.generate(5, (index) {
      final date = start.add(Duration(days: index));
      return DayChip(
        label: dayShort(date),
        date: date.day,
        dateValue: date,
      );
    });
  }

  String _iso(DateTime date) => date.toIso8601String().substring(0, 10);
}
