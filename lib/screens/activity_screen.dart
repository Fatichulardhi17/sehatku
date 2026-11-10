import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<WeeklySummary> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.health.loadWeekly();
  }

  void _reload() {
    setState(() {
      _future = AppServices.health.loadWeekly();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 1,
        items: mainNavItems,
        onTap: widget.onSelectTab,
      ),
      child: FutureBuilder<WeeklySummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _ActivitySkeleton());
          }
          if (snapshot.hasError) {
            return _ActivityError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final data = snapshot.data!;
          if (data.days.isEmpty) {
            return _ActivityEmpty(onRetry: _reload);
          }
          return _ActivityContent(data: data);
        },
      ),
    );
  }
}

class _ActivityError extends StatelessWidget {
  const _ActivityError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Aktivitas',
          subtitle: 'Ringkasan 7 hari terakhir',
        ),
        const SizedBox(height: 23),
        ErrorStateCard(
          title: 'Data aktivitas gagal dimuat',
          body: friendlyError(error),
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActivityEmpty extends StatelessWidget {
  const _ActivityEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Aktivitas',
          subtitle: 'Ringkasan 7 hari terakhir',
        ),
        const SizedBox(height: 23),
        EmptyStateCard(
          title: 'Belum ada aktivitas',
          body: 'Data langkah akan muncul setelah tersinkron.',
          buttonLabel: 'Muat ulang',
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActivityContent extends StatelessWidget {
  const _ActivityContent({required this.data});

  final WeeklySummary data;

  @override
  Widget build(BuildContext context) {
    final maxSteps = data.days.fold<int>(
      1,
      (max, day) => day.steps > max ? day.steps : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Aktivitas',
          subtitle: 'Ringkasan 7 hari terakhir',
        ),
        const SizedBox(height: 23),
        AppCard(
          height: 260,
          radius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LANGKAH', style: AppText.label11),
              const SizedBox(height: 7),
              Text(thousand(data.totalSteps), style: AppText.value34),
              const SizedBox(height: 5),
              Text(
                'rata-rata ${thousand(data.averageSteps)} per hari',
                style: AppText.body12,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in data.days)
                      Expanded(
                        child: _Bar(
                          day: day,
                          maxSteps: maxSteps,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Rata-rata',
                value: thousand(data.averageSteps),
                background: AppColors.surface,
                valueColor: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                label: 'Hari aktif',
                value: '${data.activeDays} hari',
                background: AppColors.mint,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Rincian'),
        const SizedBox(height: 12),
        InfoRow(label: 'Langkah', value: thousand(data.totalSteps)),
        const SizedBox(height: 8),
        InfoRow(label: 'Jarak', value: '${decimal(data.totalDistance)} km'),
        const SizedBox(height: 8),
        InfoRow(label: 'Kalori', value: '${thousand(data.totalCalories)} kkal'),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.maxSteps});

  final DailyMetric day;
  final int maxSteps;

  @override
  Widget build(BuildContext context) {
    final isActive = day.steps == maxSteps;
    final height = 40 + (day.steps / maxSteps) * 40;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 26,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.mint,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayShort(day.date),
          style: AppText.body11.copyWith(
            color: isActive ? AppColors.primary : AppColors.muted,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.background,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 96,
      radius: 22,
      color: background,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body13),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.value22.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 104,
          height: 31,
          color: AppColors.skeletonStrong,
          radius: 8,
        ),
        const SizedBox(height: 10),
        const SkeletonBox(width: 166, height: 17, radius: 8),
        const SizedBox(height: 23),
        const SkeletonBox(
          width: double.infinity,
          height: 260,
          color: AppColors.surface,
          radius: 24,
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 96,
                color: AppColors.surface,
                radius: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 96,
                color: AppColors.mint,
                radius: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const SkeletonBox(width: 59, height: 22, radius: 6),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          const SkeletonBox(
            width: double.infinity,
            height: 60,
            color: AppColors.surface,
            radius: 16,
          ),
        ],
      ],
    );
  }
}
