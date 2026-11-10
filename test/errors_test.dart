import 'package:flutter_test/flutter_test.dart';
import 'package:sehatku/core/app_exception.dart';
import 'package:sehatku/core/errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('AppException memakai pesannya sendiri', () {
    expect(friendlyError(const AppException('Akses admin diperlukan.')),
        'Akses admin diperlukan.');
  });

  test('foreign key diarahkan ke profil akun', () {
    const error = PostgrestException(
      message:
          'insert or update on table "plans" violates foreign key constraint "plans_user_id_fkey"',
      code: '23503',
      details: 'Key (user_id)=(abc) is not present in table "profiles".',
    );
    expect(friendlyError(error), contains('Profil akun belum lengkap'));
  });

  test('schema cache menandakan migrasi belum lengkap', () {
    const error = PostgrestException(
      message: "Could not find the 'intensity' column of 'plans' in the schema cache",
      code: 'PGRST204',
    );
    expect(friendlyError(error), contains('Struktur database belum sesuai'));
  });

  test('tabel hilang menandakan migrasi belum dijalankan', () {
    const error = PostgrestException(
      message: "Could not find the table 'public.plans' in the schema cache",
      code: 'PGRST205',
    );
    expect(friendlyError(error), contains('Tabel database belum tersedia'));
  });

  test('row-level security tetap terbaca sebagai akses ditolak', () {
    const error = PostgrestException(
      message:
          'new row violates row-level security policy for table "plans"',
      code: '42501',
    );
    expect(friendlyError(error), 'Akses data ditolak.');
  });

  test('error jaringan tidak berubah', () {
    expect(friendlyError(Exception('SocketException: Failed host lookup')),
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.');
  });
}
