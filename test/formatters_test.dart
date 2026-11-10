import 'package:flutter_test/flutter_test.dart';
import 'package:sehatku/core/formatters.dart';
import 'package:sehatku/models/models.dart';

void main() {
  group('formatters', () {
    test('thousand memakai pemisah titik', () {
      expect(thousand(0), '0');
      expect(thousand(999), '999');
      expect(thousand(1000), '1.000');
      expect(thousand(1234567), '1.234.567');
      expect(thousand(-1200), '-1.200');
    });

    test('decimal memakai koma', () {
      expect(decimal(0), '0,0');
      expect(decimal(3.14), '3,1');
      expect(decimal(12.0), '12,0');
    });

    test('timeLabel memformat jam dan menit', () {
      expect(timeLabel('07:00:00'), '07.00');
      expect(timeLabel('7:5:00'), '07.05');
      expect(timeLabel('istirahat'), 'istirahat');
    });

    test('formatDateId memakai nama bulan Indonesia', () {
      expect(formatDateId(DateTime(2026, 11, 4)), '4 November 2026');
    });

    test('dayShort memakai nama hari yang tidak ambigu', () {
      expect(dayShort(DateTime(2026, 11, 2)), 'Sen');
      expect(dayShort(DateTime(2026, 11, 8)), 'Min');
    });
  });

  group('models', () {
    test('Profile.fromMap membaca profil dan peran', () {
      final profile = Profile.fromMap({
        'id': 'u1',
        'full_name': 'Rina',
        'email': 'rina@example.com',
        'role': 'admin',
        'created_at': '2026-01-02T03:04:05Z',
      });

      expect(profile.fullName, 'Rina');
      expect(profile.initial, 'R');
      expect(profile.role, 'admin');
      expect(profile.createdAt.year, 2026);
    });

    test('DailyMetric.fromMap memberi nilai aman', () {
      final metric = DailyMetric.fromMap({
        'metric_date': '2026-11-04',
        'steps': 4200,
        'active_minutes': 30,
        'calories': 210,
        'distance_km': 3.2,
      });

      expect(metric.steps, 4200);
      expect(metric.activeMinutes, 30);
      expect(metric.distanceKm, 3.2);
    });

    test('ScheduleSummary mendukung pengingat kosong', () {
      final summary = ScheduleSummary(
        chips: [
          DayChip(
            label: 'Rab',
            date: 4,
            dateValue: DateTime(2026, 11, 4),
          ),
        ],
        workouts: const [],
        reminder: null,
      );

      expect(summary.reminder, isNull);
      expect(summary.workouts, isEmpty);
    });

    test('PlanItem.fromMap membaca status dan isDone', () {
      final plan = PlanItem.fromMap({
        'id': 'plan-1',
        'title': 'Jalan Pagi',
        'detail': 'Keliling komplek',
        'duration_minutes': 25,
        'intensity': 'sedang',
        'status': 'done',
      });

      expect(plan.id, 'plan-1');
      expect(plan.title, 'Jalan Pagi');
      expect(plan.isDone, isTrue);
    });

    test('WorkoutItem.fromMap membaca status dan isDone', () {
      final workout = WorkoutItem.fromMap({
        'id': 'workout-1',
        'start_time': '07:30',
        'title': 'Jogging',
        'workout_type': 'Kardio',
        'duration_minutes': 40,
        'status': 'planned',
      });

      expect(workout.id, 'workout-1');
      expect(workout.title, 'Jogging');
      expect(workout.isDone, isFalse);
    });
  });
}
