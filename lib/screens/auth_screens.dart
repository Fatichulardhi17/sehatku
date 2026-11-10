import 'package:flutter/material.dart';

import '../core/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/screen_frame.dart';
import '../widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _bannerError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      contentPadding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SehatkuLogo(),
          const SizedBox(height: 36),
          Text('Masuk', style: AppText.display34),
          const SizedBox(height: 8),
          Text('Lanjutkan rencana sehatmu.', style: AppText.body15),
          const SizedBox(height: 60),
          AppField(
            label: 'Email',
            hint: 'nama@email.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            enabled: !_loading,
            hintColor: _emailError != null ? AppColors.danger : null,
          ),
          const SizedBox(height: 28),
          AppField(
            label: 'Kata sandi',
            hint: 'Masukkan kata sandi',
            controller: _password,
            obscure: true,
            errorText: _passwordError,
            enabled: !_loading,
            filledColor: _loading ? AppColors.skeleton : null,
          ),
          if (_passwordError == null) ...[
            const SizedBox(height: 10),
            Text('Minimal 8 karakter.', style: AppText.body12),
          ],
          const SizedBox(height: 28),
          PrimaryButton(
            label: _loading ? 'Memproses...' : 'Masuk',
            loading: _loading,
            onPressed: _submit,
          ),
          if (_bannerError != null) ...[
            const SizedBox(height: 20),
            AppCard(
              radius: 16,
              color: AppColors.dangerSoft,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bannerError!,
                    style: AppText.body13.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Periksa lagi lalu coba masuk.', style: AppText.body12),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          LinkRow(
            leading: 'Belum punya akun? ',
            action: 'Daftar',
            onTap: () => Navigator.of(context).pushNamed('/register'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _bannerError = null;
    });

    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@')) {
      setState(() => _emailError = 'Masukkan email yang valid.');
      return;
    }
    if (password.length < 8) {
      setState(() => _passwordError = 'Kata sandi minimal 8 karakter.');
      return;
    }

    setState(() => _loading = true);
    final result = await AppServices.auth.signIn(
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (result.ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      return;
    }
    setState(() {
      _loading = false;
      _bannerError = result.message ?? 'Email atau kata sandi salah.';
    });
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _bannerError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      contentPadding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SehatkuLogo(),
          const SizedBox(height: 36),
          Text('Buat akun', style: AppText.display34),
          const SizedBox(height: 8),
          Text('Mulai rencana sehatmu hari ini.', style: AppText.body15),
          const SizedBox(height: 34),
          AppField(
            label: 'Nama',
            hint: 'Nama panggilan',
            controller: _name,
            errorText: _nameError,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          AppField(
            label: 'Email',
            hint: 'nama@email.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          AppField(
            label: 'Kata sandi',
            hint: 'Minimal 8 karakter',
            controller: _password,
            obscure: true,
            errorText: _passwordError,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          AppField(
            label: 'Ulangi kata sandi',
            hint: 'Ulangi kata sandi',
            controller: _confirm,
            obscure: true,
            errorText: _confirmError,
            enabled: !_loading,
          ),
          if (_bannerError != null) ...[
            const SizedBox(height: 16),
            Text(
              _bannerError!,
              style: AppText.body12.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 30),
          PrimaryButton(
            label: _loading ? 'Memproses...' : 'Buat akun',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 40),
          LinkRow(
            leading: 'Sudah punya akun? ',
            action: 'Masuk',
            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _bannerError = null;
    });

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    var valid = true;
    if (name.isEmpty) {
      _nameError = 'Nama tidak boleh kosong.';
      valid = false;
    }
    if (!email.contains('@')) {
      _emailError = 'Masukkan email yang valid.';
      valid = false;
    }
    if (password.length < 8) {
      _passwordError = 'Kata sandi minimal 8 karakter.';
      valid = false;
    }
    if (confirm != password) {
      _confirmError = 'Kata sandi belum sama.';
      valid = false;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);
    final result = await AppServices.auth.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (result.ok) {
      final message = result.message;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
      return;
    }
    setState(() {
      _loading = false;
      _bannerError = result.message;
    });
  }
}
