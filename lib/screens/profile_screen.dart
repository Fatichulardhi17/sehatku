import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.health.loadProfile();
  }

  void _reload() {
    setState(() {
      _future = AppServices.health.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 3,
        items: mainNavItems,
        onTap: widget.onSelectTab,
      ),
      child: FutureBuilder<ProfileSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _ProfileSkeleton());
          }
          if (snapshot.hasError) {
            return _ProfileError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          return _ProfileContent(
            data: snapshot.data!,
            onReload: _reload,
          );
        },
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Profil',
          subtitle: 'Akun dan pengaturan',
        ),
        const SizedBox(height: 23),
        ErrorStateCard(
          title: 'Profil gagal dimuat',
          body: friendlyError(error),
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.data,
    required this.onReload,
  });

  final ProfileSummary data;
  final VoidCallback onReload;

  void _showEditTarget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditTargetSheet(
        currentTarget: data.target,
        onSaved: onReload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderValue = data.reminderEnabled
        ? 'Aktif, ${timeLabel(data.reminderTime)}'
        : 'Nonaktif';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Profil',
          subtitle: 'Akun dan pengaturan',
        ),
        const SizedBox(height: 23),
        Row(
          children: [
            AvatarBadge(
              initial: data.profile.initial,
              size: 72,
              fontSize: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.profile.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.value20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Anggota sejak ${data.profile.createdAt.year}',
                    style: AppText.body13,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                label: 'Hari aktif',
                value: '${data.activeDays}',
                background: AppColors.surface,
                valueColor: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _ProfileStat(
                label: 'Langkah',
                value: thousand(data.totalSteps),
                background: AppColors.mint,
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _ProfileStat(
                label: 'Target',
                value: thousand(data.target),
                background: AppColors.surface,
                valueColor: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SectionHeader(title: 'Pengaturan'),
        const SizedBox(height: 12),
        InfoRow(label: 'Email', value: data.profile.email),
        const SizedBox(height: 8),
        InfoRow(
          label: 'Target harian',
          value: '${thousand(data.target)} langkah',
          onTap: () => _showEditTarget(context),
        ),
        const SizedBox(height: 8),
        InfoRow(label: 'Pengingat', value: reminderValue),
        const SizedBox(height: 8),
        InfoRow(label: 'Tema', value: data.themeLabel),
        const SizedBox(height: 8),
        const InfoRow(label: 'Tentang Sehatku', value: 'Versi 1.0'),
        if (data.profile.role == 'admin') ...[
          const SizedBox(height: 12),
          InfoRow(
            label: 'Dasbor admin',
            value: 'Buka',
            onTap: () => Navigator.of(context).pushNamed('/admin'),
          ),
        ],
        const SizedBox(height: 24),
        AppCard(
          height: 52,
          radius: 16,
          onTap: () => _signOut(context),
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              'Keluar',
              style: AppText.body14.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await AppServices.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}

class _EditTargetSheet extends StatefulWidget {
  const _EditTargetSheet({
    required this.currentTarget,
    required this.onSaved,
  });

  final int currentTarget;
  final VoidCallback onSaved;

  @override
  State<_EditTargetSheet> createState() => _EditTargetSheetState();
}

class _EditTargetSheetState extends State<_EditTargetSheet> {
  late final TextEditingController _controller;
  late int _selectedPreset;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.currentTarget;
    _controller = TextEditingController(text: widget.currentTarget.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = int.tryParse(_controller.text.trim()) ?? 0;
    if (target <= 0) {
      setState(() {
        _errorMessage = 'Target langkah harus lebih besar dari 0.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AppServices.health.updateUserSettings(dailyStepTarget: target);
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

  void _selectPreset(int value) {
    setState(() {
      _selectedPreset = value;
      _controller.text = value.toString();
    });
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
                Text('Ubah Target Harian', style: AppText.title18),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tentukan target langkah harian untuk menjaga konsistensi latihan.',
              style: AppText.body13,
            ),
            const SizedBox(height: 18),
            Text(
              'Pilihan Cepat',
              style: AppText.body13.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final preset in [6000, 8000, 10000, 12000]) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GhostButton(
                        label: '${preset ~/ 1000}k',
                        height: 38,
                        background: _selectedPreset == preset
                            ? AppColors.primary
                            : AppColors.surface,
                        foreground: _selectedPreset == preset
                            ? Colors.white
                            : AppColors.primaryDark,
                        onPressed:
                            _loading ? null : () => _selectPreset(preset),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Target Langkah Kustom',
              hint: 'Contoh: 8000',
              controller: _controller,
              keyboardType: TextInputType.number,
              enabled: !_loading,
              onChanged: (val) {
                final parsed = int.tryParse(val.trim());
                if (parsed != null && parsed != _selectedPreset) {
                  setState(() {
                    _selectedPreset = parsed;
                  });
                }
              },
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
              label: _loading ? 'Menyimpan...' : 'Simpan Target',
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
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
      height: 78,
      radius: 18,
      color: background,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body12),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.value18.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 90,
          height: 31,
          color: AppColors.skeletonStrong,
          radius: 8,
        ),
        const SizedBox(height: 10),
        const SkeletonBox(width: 142, height: 17, radius: 8),
        const SizedBox(height: 23),
        const Row(
          children: [
            SkeletonBox(width: 72, height: 72, radius: 36),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 160,
                    height: 24,
                    color: AppColors.skeletonStrong,
                    radius: 8,
                  ),
                  SizedBox(height: 8),
                  SkeletonBox(width: 120, height: 16, radius: 8),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 78,
                color: AppColors.surface,
                radius: 18,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 78,
                color: AppColors.mint,
                radius: 18,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 78,
                color: AppColors.surface,
                radius: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SkeletonBox(width: 96, height: 22, radius: 6),
        const SizedBox(height: 12),
        for (var index = 0; index < 5; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          const SkeletonBox(
            width: double.infinity,
            height: 60,
            color: AppColors.surface,
            radius: 16,
          ),
        ],
        const SizedBox(height: 24),
        const SkeletonBox(
          width: double.infinity,
          height: 52,
          color: AppColors.surface,
          radius: 16,
        ),
      ],
    );
  }
}
