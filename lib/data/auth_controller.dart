import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  const AuthResult.ok([this.message]) : ok = true;
  const AuthResult.failure(this.message) : ok = false;

  final bool ok;
  final String? message;
}

class AuthController {
  AuthController(this._client);

  final SupabaseClient? _client;

  bool get isConfigured => _client != null;

  bool get isSignedIn => _client?.auth.currentSession != null;

  String? get userEmail => _client?.auth.currentUser?.email;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return const AuthResult.failure(
        'Supabase belum dikonfigurasi. Jalankan ulang dengan kredensial proyek.',
      );
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        return const AuthResult.failure('Email atau kata sandi salah.');
      }
      return const AuthResult.ok();
    } on AuthException catch (error) {
      return AuthResult.failure(_friendly(error.message));
    } catch (_) {
      return const AuthResult.failure(
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return const AuthResult.failure(
        'Supabase belum dikonfigurasi. Jalankan ulang dengan kredensial proyek.',
      );
    }

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      if (response.session == null) {
        return const AuthResult.ok(
          'Akun dibuat. Cek email untuk konfirmasi, lalu masuk.',
        );
      }
      return const AuthResult.ok();
    } on AuthException catch (error) {
      return AuthResult.failure(_friendly(error.message));
    } catch (_) {
      return const AuthResult.failure(
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) {
      return;
    }
    try {
      await client.auth.signOut();
    } catch (_) {
      // Sesi lokal tetap dianggap selesai.
    }
  }

  String _friendly(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Email atau kata sandi salah.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'Email sudah terdaftar.';
    }
    if (lower.contains('password')) {
      return 'Kata sandi minimal 8 karakter.';
    }
    if (lower.contains('email')) {
      return 'Masukkan email yang valid.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
