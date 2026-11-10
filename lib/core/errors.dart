import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

String friendlyError(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is PostgrestException) {
    final mapped = _postgrestMessage(error);
    if (mapped != null) {
      return mapped;
    }
  }

  final text = error.toString().toLowerCase();
  if (text.contains('jwt') ||
      text.contains('session') ||
      text.contains('refresh token')) {
    return 'Sesi berakhir. Silakan masuk kembali.';
  }
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host lookup') ||
      text.contains('connection') ||
      text.contains('timeout')) {
    return 'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.';
  }
  if (text.contains('row-level security') ||
      text.contains('permission denied')) {
    return 'Akses data ditolak.';
  }
  return 'Data gagal dimuat. Coba lagi.';
}

String? _postgrestMessage(PostgrestException error) {
  final message = error.message.toLowerCase();
  final details = error.details?.toString().toLowerCase() ?? '';
  final code = error.code ?? '';

  // 23503: foreign key. Semua tabel data mereferensikan profiles.id, jadi
  // penyebab paling umum adalah profil akun yang belum dibuat trigger.
  if (code == '23503' ||
      message.contains('foreign key') ||
      details.contains('is not present in table')) {
    return 'Profil akun belum lengkap sehingga data tidak bisa disimpan.';
  }
  if (code == 'PGRST205' || message.contains('could not find the table')) {
    return 'Tabel database belum tersedia. Jalankan migrasi terbaru.';
  }
  if (code == 'PGRST204' || message.contains('schema cache')) {
    return 'Struktur database belum sesuai. Jalankan migrasi terbaru.';
  }
  if (code == '23505') {
    return 'Data yang sama sudah ada.';
  }
  if (code == '23514' || code == '22P02') {
    return 'Nilai yang dikirim tidak valid.';
  }
  if (code == '42501') {
    return 'Akses data ditolak.';
  }
  if (code == 'PGRST301' || message.contains('jwt')) {
    return 'Sesi berakhir. Silakan masuk kembali.';
  }
  if (kDebugMode && code.isNotEmpty) {
    return 'Data gagal dimuat (kode $code). Coba lagi.';
  }
  return null;
}
