import 'package:flutter/material.dart';

import 'core/services.dart';
import 'screens/admin_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.init();
  runApp(const SehatkuApp());
}

class SehatkuApp extends StatelessWidget {
  const SehatkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = AppServices.ready;
    return MaterialApp(
      title: 'Sehatku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute:
          !ready ? '/setup' : (AppServices.authenticated ? '/home' : '/'),
      routes: {
        '/setup': (_) => const SetupScreen(),
        '/': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => _signedIn(const MainShell()),
        '/activity': (_) => _signedIn(const MainShell(initialIndex: 1)),
        '/schedule': (_) => _signedIn(const MainShell(initialIndex: 2)),
        '/profile': (_) => _signedIn(const MainShell(initialIndex: 3)),
        '/admin': (_) => _signedIn(const AdminDashboardScreen()),
        '/admin-users': (_) => _signedIn(const AdminUsersScreen()),
      },
    );
  }

  Widget _signedIn(Widget child) {
    return AppServices.authenticated ? child : const LoginScreen();
  }
}
