import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<ScheduleSummary> _future;
  late DateTime _selectedDate;
  int _selectedChip = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _future = _load();
  }

  Future<ScheduleSummary> _load() {
    return AppServices.health.loadSchedule(date: _selectedDate);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _selectChip(int index, List<DayChip> chips) {
    if (index < 0 || index >= chips.length) {
      return;
    }
    final date = chips[index].dateValue;
    if (DateUtils.isSameDay(date, _selectedDate)) {
      return;
    }
    setState(() {
      _selectedChip = index;
      _selectedDate = date;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 2,
        items: mainNavItems,
        onTap: widget.onSelectTab,
      ),
      child: FutureBuilder<ScheduleSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _ScheduleSkeleton());
          }
          if (snapshot.hasError) {
            return _ScheduleError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final data = snapshot.data!;
          return _ScheduleContent(
            data: data,
            selectedChip: _selectedChip,
            onSelectChip: (index) => _selectChip(index, data.chips),
            onReload: _reload,
          );
        },
      ),
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Jadwal Latihan',
          subtitle: 'Lima hari ke depan',
        ),
        const SizedBox(height: 23),
        ErrorStateCard(
          title: 'Jadwal gagal dimuat',
          body: friendlyError(error),
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  const _ScheduleContent({
    required this.data,
    required this.selectedChip,
    required this.onSelectChip,
    required this.onReload,
  });

  final ScheduleSummary data;
  final int selectedChip;
  final ValueChanged<int> onSelectChip;
  final VoidCallback onReload;

  Future<void> _toggleWorkout(BuildContext context, WorkoutItem item) async {
    if (item.id.isEmpty) {
      return;
    }
    try {
      await AppServices.health.toggleWorkoutStatus(
        workoutId: item.id,
        isDone: !item.isDone,
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

  void _showAddWorkout(BuildContext context, DateTime targetDate) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddWorkoutSheet(
        targetDate: targetDate,
        onSaved: onReload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = data.chips[selectedChip];
    final isToday = DateUtils.isSameDay(selected.dateValue, DateTime.now());
    final title = isToday
        ? 'Latihan hari ini'
        : 'Latihan ${formatDateId(selected.dateValue)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Jadwal Latihan',
          subtitle: 'Lima hari ke depan',
        ),
        const SizedBox(height: 23),
        Row(
          children: [
            for (var index = 0; index < data.chips.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: _DayChip(
                  chip: data.chips[index],
                  active: index == selectedChip,
                  onTap: () => onSelectChip(index),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 26),
        SectionHeader(
          title: title,
          actionLabel: '+ Latihan',
          onAction: () => _showAddWorkout(context, selected.dateValue),
        ),
        const SizedBox(height: 12),
        if (data.workouts.isEmpty)
          EmptyStateCard(
            title: 'Belum ada latihan',
            body: 'Tidak ada latihan pada tanggal ini. Jadwalkan sesi latihanmu.',
            buttonLabel: 'Tambah latihan',
            onPressed: () => _showAddWorkout(context, selected.dateValue),
            height: 150,
          )
        else
          for (var index = 0; index < data.workouts.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            WorkoutCard(
              item: data.workouts[index],
              highlighted: index == 0,
              onToggleStatus: () => _toggleWorkout(context, data.workouts[index]),
            ),
          ],
        if (data.reminder != null) ...[
          const SizedBox(height: 20),
          AppCard(
            height: 76,
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.peach,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.reminder!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body14.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.reminder!.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AddWorkoutSheet extends StatefulWidget {
  const _AddWorkoutSheet({
    required this.targetDate,
    required this.onSaved,
  });

  final DateTime targetDate;
  final VoidCallback onSaved;

  @override
  State<_AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<_AddWorkoutSheet> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController(text: 'Kardio');
  final _timeController = TextEditingController(text: '07:00');
  final _durationController = TextEditingController(text: '45');
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Nama latihan wajib diisi.';
      });
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    var time = _timeController.text.trim();
    if (!time.contains(':')) {
      time = '$time:00';
    }
    if (time.length == 5) {
      time = '$time:00';
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AppServices.health.addWorkout(
        title: title,
        workoutType: _typeController.text.trim(),
        startTime: time,
        durationMinutes: duration,
        date: widget.targetDate,
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
                Text('Tambah Jadwal Latihan', style: AppText.title18),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Jadwalkan latihan untuk ${formatDateId(widget.targetDate)}.',
              style: AppText.body13,
            ),
            const SizedBox(height: 20),
            AppField(
              label: 'Nama Latihan',
              hint: 'Contoh: Lari Pagi di Taman',
              controller: _titleController,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Jenis Latihan',
              hint: 'Contoh: Kardio, Fleksibilitas, HIIT, Gym',
              controller: _typeController,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppField(
                    label: 'Jam Mulai (JJ:MM)',
                    hint: '07:00',
                    controller: _timeController,
                    keyboardType: TextInputType.datetime,
                    enabled: !_loading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppField(
                    label: 'Durasi (menit)',
                    hint: '45',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    enabled: !_loading,
                  ),
                ),
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
              label: _loading ? 'Menyimpan...' : 'Simpan Latihan',
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

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.chip,
    required this.active,
    required this.onTap,
  });

  final DayChip chip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chip.label,
                style: AppText.body11.copyWith(
                  color: active ? AppColors.mint : AppColors.muted,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${chip.date}',
                style: AppText.value18.copyWith(
                  color: active ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 172,
          height: 31,
          color: AppColors.skeletonStrong,
          radius: 8,
        ),
        const SizedBox(height: 10),
        const SkeletonBox(width: 56, height: 17, radius: 8),
        const SizedBox(height: 23),
        Row(
          children: [
            for (var index = 0; index < 5; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              const Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 64,
                  color: AppColors.surface,
                  radius: 18,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 26),
        const SkeletonBox(width: 119, height: 22, radius: 6),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          SkeletonBox(
            width: double.infinity,
            height: 120,
            color: index == 0 ? AppColors.mint : AppColors.surface,
            radius: 22,
          ),
        ],
        const SizedBox(height: 20),
        const SkeletonBox(
          width: double.infinity,
          height: 76,
          color: AppColors.surface,
          radius: 18,
        ),
      ],
    );
  }
}
