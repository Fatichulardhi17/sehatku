import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<AdminSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.health.loadAdminSummary();
  }

  void _reload() {
    setState(() {
      _future = AppServices.health.loadAdminSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 0,
        items: adminNavItems,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/admin-users');
          } else if (index == 2) {
            _signOut(context);
          }
        },
      ),
      child: FutureBuilder<AdminSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _AdminDashboardSkeleton());
          }
          if (snapshot.hasError) {
            return _AdminError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final data = snapshot.data!;
          if (data.totalUsers == 0) {
            return _AdminEmpty(onRetry: _reload);
          }
          return _AdminDashboardContent(data: data);
        },
      ),
    );
  }
}

class _AdminError extends StatelessWidget {
  const _AdminError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Dasbor admin',
          subtitle: 'Jumlah dan daftar pengguna.',
        ),
        const SizedBox(height: 23),
        ErrorStateCard(
          title: 'Dasbor gagal dimuat',
          body: friendlyError(error),
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AdminEmpty extends StatelessWidget {
  const _AdminEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Dasbor admin',
          subtitle: 'Jumlah dan daftar pengguna.',
        ),
        const SizedBox(height: 23),
        EmptyStateCard(
          title: 'Belum ada pengguna',
          body: 'Pengguna yang mendaftar akan muncul di sini.',
          buttonLabel: 'Muat ulang',
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent({required this.data});

  final AdminSummary data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageHeading(
                title: 'Dasbor admin',
                subtitle: 'Jumlah dan daftar pengguna.',
              ),
            ),
            SizedBox(width: 12),
            AvatarBadge(initial: 'A'),
          ],
        ),
        const SizedBox(height: 23),
        AppCard(
          height: 156,
          radius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL PENGGUNA', style: AppText.label11),
              const SizedBox(height: 7),
              Text(thousand(data.totalUsers), style: AppText.value44),
              const SizedBox(height: 9),
              Text(
                '${thousand(data.activeUsers)} akun aktif dalam 7 hari terakhir',
                style: AppText.body13,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Pengguna terbaru',
          actionLabel: 'Lihat semua',
          onAction: () =>
              Navigator.of(context).pushReplacementNamed('/admin-users'),
        ),
        const SizedBox(height: 12),
        if (data.recent.isEmpty)
          const EmptyStateCard(
            title: 'Belum ada pengguna terbaru',
            body: 'Pengguna baru akan muncul di sini.',
            height: 150,
          )
        else
          for (var index = 0; index < data.recent.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            UserTile(user: data.recent[index]),
          ],
        const SizedBox(height: 20),
        Text('Diurutkan dari akun terbaru.', style: AppText.body12),
        const SizedBox(height: 8),
      ],
    );
  }
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<_AdminUsersData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<_AdminUsersData> _load() async {
    final summary = await AppServices.health.loadAdminSummary();
    final users = await AppServices.health.loadAdminUsers();
    return _AdminUsersData(total: summary.totalUsers, users: users);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      bottomNav: SehatkuBottomNav(
        activeIndex: 1,
        items: adminNavItems,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/admin');
          } else if (index == 2) {
            _signOut(context);
          }
        },
      ),
      child: FutureBuilder<_AdminUsersData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingRegion(child: _AdminUsersSkeleton());
          }
          if (snapshot.hasError) {
            return _AdminError(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final data = snapshot.data!;
          if (data.users.isEmpty) {
            return _AdminUsersEmpty(onRetry: _reload);
          }
          return _AdminUsersContent(data: data);
        },
      ),
    );
  }
}

class _AdminUsersData {
  const _AdminUsersData({required this.total, required this.users});

  final int total;
  final List<AdminUser> users;
}

class _AdminUsersEmpty extends StatelessWidget {
  const _AdminUsersEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeading(
          title: 'Pengguna',
          subtitle: 'Akun terdaftar.',
        ),
        const SizedBox(height: 23),
        EmptyStateCard(
          title: 'Belum ada pengguna',
          body: 'Pengguna yang mendaftar akan muncul di sini.',
          buttonLabel: 'Muat ulang',
          onPressed: onRetry,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AdminUsersContent extends StatelessWidget {
  const _AdminUsersContent({required this.data});

  final _AdminUsersData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeading(
          title: 'Pengguna',
          subtitle: '${thousand(data.total)} akun terdaftar.',
        ),
        const SizedBox(height: 23),
        const SectionHeader(title: 'Semua pengguna'),
        const SizedBox(height: 14),
        for (var index = 0; index < data.users.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          UserTile(user: data.users[index]),
        ],
        const SizedBox(height: 20),
        Text(
          'Menampilkan ${data.users.length} dari ${thousand(data.total)} pengguna.',
          style: AppText.body12,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AdminDashboardSkeleton extends StatelessWidget {
  const _AdminDashboardSkeleton();

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
                    width: 240,
                    height: 31,
                    color: AppColors.skeletonStrong,
                    radius: 8,
                  ),
                  SizedBox(height: 10),
                  SkeletonBox(width: 260, height: 17, radius: 8),
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
          height: 156,
          color: AppColors.surface,
          radius: 24,
        ),
        const SizedBox(height: 28),
        const SkeletonBox(width: 180, height: 22, radius: 6),
        const SizedBox(height: 12),
        for (var index = 0; index < 4; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          const SkeletonBox(
            width: double.infinity,
            height: 76,
            color: AppColors.surface,
            radius: 18,
          ),
        ],
      ],
    );
  }
}

class _AdminUsersSkeleton extends StatelessWidget {
  const _AdminUsersSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(
          width: 200,
          height: 31,
          color: AppColors.skeletonStrong,
          radius: 8,
        ),
        const SizedBox(height: 10),
        const SkeletonBox(width: 260, height: 17, radius: 8),
        const SizedBox(height: 23),
        const SkeletonBox(width: 200, height: 22, radius: 6),
        const SizedBox(height: 14),
        for (var index = 0; index < 6; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          const SkeletonBox(
            width: double.infinity,
            height: 76,
            color: AppColors.surface,
            radius: 18,
          ),
        ],
      ],
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  await AppServices.auth.signOut();
  if (context.mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}
