import 'package:flutter/material.dart';

import '../core/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const _command =
      'flutter run --dart-define=SUPABASE_URL=https://PROJECT.supabase.co '
      '--dart-define=SUPABASE_ANON_KEY=KEY';

  @override
  Widget build(BuildContext context) {
    final error = AppServices.initError;

    return ScreenFrame(
      contentPadding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SehatkuLogo(),
          const SizedBox(height: 36),
          Text('Supabase belum siap', style: AppText.display34),
          const SizedBox(height: 8),
          Text(
            'Aplikasi ini tidak memakai data contoh. Hubungkan proyek Supabase '
            'agar akun, langkah, jadwal, dan data admin tersimpan sungguhan.',
            style: AppText.body15,
          ),
          const SizedBox(height: 28),
          AppCard(
            radius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JALANKAN DENGAN KREDENSIAL', style: AppText.label11),
                const SizedBox(height: 10),
                SelectableText(
                  _command,
                  style: AppText.body12.copyWith(
                    color: AppColors.primaryDark,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gunakan URL proyek dan publishable/anon key. Jangan pernah '
                  'memasukkan service_role key ke aplikasi.',
                  style: AppText.body12,
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 20),
            ErrorStateCard(
              title: 'Koneksi Supabase gagal',
              body: error,
              height: null,
              buttonLabel: null,
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Setelah kredensial dipasang, jalankan ulang aplikasi. '
            'Skema database tersedia di supabase/migrations.',
            style: AppText.body12,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
