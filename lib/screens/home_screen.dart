import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.health.loadHome();
  }

  void _reload() {
    setState(() {
      _future = AppServices.health.loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 0,
        items: mainNavItems,
        onTap: widget.onSelectTab,
      ),
      child: FutureBuilder<HomeSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _HomeSkeleton());
          }
          if (snapshot.hasError) {
            return _HomeError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          return _HomeContent(
            data: snapshot.data!,
            onReload: _reload,
          );
        },
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Beranda',
          subtitle: 'Ringkasan hari ini',
        ),
        const SizedBox(height: 23),
        ErrorStateCard(
          title: 'Data beranda gagal dimuat',
          body: friendlyError(error),
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onReload,
  });

  final HomeSummary data;
  final VoidCallback onReload;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat pagi';
    }
    if (hour < 15) {
      return 'Selamat siang';
    }
    if (hour < 19) {
      return 'Selamat sore';
    }
    return 'Selamat malam';
  }

  Future<void> _togglePlan(BuildContext context, PlanItem plan) async {
    if (plan.id.isEmpty) {
      return;
    }
    try {
      await AppServices.health.togglePlanStatus(
        planId: plan.id,
        isDone: !plan.isDone,
      );
      onReload();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showLogMetrics(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LogMetricsSheet(
        initialMetric: data.today,
        onSaved: onReload,
      ),
    );
  }

  void _showAddPlan(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddPlanSheet(
        onSaved: onReload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = data.today;
    final target = data.target == 0 ? 1 : data.target;
    final percent = ((today.steps / target) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${data.profile.fullName}',
                    style: AppText.title26,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$_greeting. Yuk gerak hari ini.',
                    style: AppText.body14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AvatarBadge(initial: data.profile.initial),
          ],
        ),
        const SizedBox(height: 23),
        AppCard(
          radius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LANGKAH HARI INI', style: AppText.label11),
                  GhostButton(
                    label: '+ Catat',
                    height: 32,
                    width: 76,
                    background: AppColors.mint,
                    foreground: AppColors.primary,
                    onPressed: () => _showLogMetrics(context),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(thousand(today.steps), style: AppText.value44),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('langkah', style: AppText.body13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppProgressBar(value: today.steps / target),
              const SizedBox(height: 10),
              Text(
                '$percent% dari target ${thousand(data.target)} langkah',
                style: AppText.body12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Aktif',
                value: '${today.activeMinutes} menit',
                note: 'hari ini',
                background: AppColors.surface,
                valueColor: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                label: 'Kalori',
                value: '${today.calories} kkal',
                note: 'terbakar hari ini',
                background: AppColors.mint,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SectionHeader(
          title: 'Rencana hari ini',
          actionLabel: '+ Tambah',
          onAction: () => _showAddPlan(context),
        ),
        const SizedBox(height: 12),
        if (data.plans.isEmpty)
          EmptyStateCard(
            title: 'Belum ada rencana',
            body: 'Rencana hari ini belum dibuat. Catat rencana aktivitasmu.',
            buttonLabel: 'Buat rencana',
            onPressed: () => _showAddPlan(context),
            height: 150,
          )
        else ...[
          for (var index = 0;
              index < (data.plans.length > 3 ? 3 : data.plans.length);
              index++) ...[
            if (index > 0) const SizedBox(height: 8),
            PlanTile(
              title: data.plans[index].title,
              detail: data.plans[index].detail,
              isDone: data.plans[index].isDone,
              onTap: () => _togglePlan(context, data.plans[index]),
            ),
          ],
          if (data.plans.length > 3) ...[
            const SizedBox(height: 10),
            Center(
              child: GhostButton(
                label: 'Lihat semua (${data.plans.length})',
                width: 180,
                height: 40,
                background: AppColors.surface,
                foreground: AppColors.primary,
                onPressed: () => _showPlans(context, data.plans),
              ),
            ),
          ],
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  void _showPlans(BuildContext context, List<PlanItem> plans) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Semua rencana',
                          style: AppText.title18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        tooltip: 'Tutup',
                        color: AppColors.primaryDark,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => PlanTile(
                        title: plans[index].title,
                        detail: plans[index].detail,
                        isDone: plans[index].isDone,
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await _togglePlan(context, plans[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogMetricsSheet extends StatefulWidget {
  const _LogMetricsSheet({
    required this.initialMetric,
    required this.onSaved,
  });

  final DailyMetric initialMetric;
  final VoidCallback onSaved;

  @override
  State<_LogMetricsSheet> createState() => _LogMetricsSheetState();
}

class _LogMetricsSheetState extends State<_LogMetricsSheet> {
  late final TextEditingController _stepsController;
  late final TextEditingController _activeMinutesController;
  late final TextEditingController _caloriesController;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _stepsController = TextEditingController(
      text: widget.initialMetric.steps > 0
          ? widget.initialMetric.steps.toString()
          : '',
    );
    _activeMinutesController = TextEditingController(
      text: widget.initialMetric.activeMinutes > 0
          ? widget.initialMetric.activeMinutes.toString()
          : '',
    );
    _caloriesController = TextEditingController(
      text: widget.initialMetric.calories > 0
          ? widget.initialMetric.calories.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _activeMinutesController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final steps = int.tryParse(_stepsController.text.trim()) ?? 0;
    final activeMinutes =
        int.tryParse(_activeMinutesController.text.trim()) ?? 0;
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

    if (steps < 0 || activeMinutes < 0 || calories < 0) {
      setState(() {
        _errorMessage = 'Nilai tidak boleh bernilai negatif.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AppServices.health.logTodayMetric(
        steps: steps,
        activeMinutes: activeMinutes,
        calories: calories,
      );
      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = friendlyError(e);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catat Aktivitas Hari Ini', style: AppText.title18),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Perbarui jumlah langkah, durasi aktif, dan kalori.',
              style: AppText.body13,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Jumlah Langkah',
              hint: 'Contoh: 6500',
              controller: _stepsController,
              keyboardType: TextInputType.number,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Menit Aktif',
              hint: 'Contoh: 45',
              controller: _activeMinutesController,
              keyboardType: TextInputType.number,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Kalori Terbakar (kkal)',
              hint: 'Contoh: 320',
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              enabled: !_loading,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: AppText.body12.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _loading ? 'Menyimpan...' : 'Simpan Aktivitas',
              loading: _loading,
              showSpinner: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlanSheet extends StatefulWidget {
  const _AddPlanSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  String _intensity = 'ringan';
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Judul rencana wajib diisi.';
      });
      return;
    }
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AppServices.health.addPlan(
        title: title,
        detail: _detailController.text.trim(),
        durationMinutes: duration,
        intensity: _intensity,
      );
      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = friendlyError(e);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tambah Rencana Baru', style: AppText.title18),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tulis target rencana atau kebiasaan sehat hari ini.',
              style: AppText.body13,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Judul Rencana',
              hint: 'Contoh: Jalan santai sore',
              controller: _titleController,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Keterangan',
              hint: 'Contoh: Target 3.000 langkah di sekitar taman',
              controller: _detailController,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Durasi (menit)',
              hint: 'Contoh: 30',
              controller: _durationController,
              keyboardType: TextInputType.number,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            Text(
              'Tingkat Intensitas',
              style: AppText.body13.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final item in ['ringan', 'sedang', 'tinggi']) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GhostButton(
                        label: item[0].toUpperCase() + item.substring(1),
                        height: 38,
                        background: _intensity == item
                            ? AppColors.primary
                            : AppColors.surface,
                        foreground: _intensity == item
                            ? Colors.white
                            : AppColors.primaryDark,
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() {
                                  _intensity = item;
                                });
                              },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: AppText.body12.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _loading ? 'Menyimpan...' : 'Simpan Rencana',
              loading: _loading,
              showSpinner: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.note,
    required this.background,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String note;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 108,
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
            style: AppText.value20.copyWith(color: valueColor),
          ),
          const Spacer(),
          Text(note, style: AppText.body11),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 232,
                    height: 31,
                    color: AppColors.skeletonStrong,
                    radius: 8,
                  ),
                  SizedBox(height: 10),
                  SkeletonBox(width: 192, height: 17, radius: 8),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        const SkeletonBox(
          width: double.infinity,
          height: 196,
          color: AppColors.surface,
          radius: 24,
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 108,
                color: AppColors.surface,
                radius: 22,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 108,
                color: AppColors.mint,
                radius: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const SkeletonBox(
          width: 127,
          height: 22,
          color: AppColors.skeletonStrong,
          radius: 6,
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          const SkeletonBox(
            width: double.infinity,
            height: 72,
            color: AppColors.surface,
            radius: 18,
          ),
        ],
      ],
    );
  }
}
