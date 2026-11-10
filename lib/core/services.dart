import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_controller.dart';
import '../data/health_repository.dart';
import 'env.dart';

class AppServices {
  const AppServices._();

  static SupabaseClient? client;
  static late AuthController auth;
  static late HealthRepository health;
  static String? initError;

  static bool _ready = false;

  static bool get configured => Env.supabaseConfigured;

  static bool get ready => client != null;

  static bool get authenticated => client?.auth.currentSession != null;

  static Future<void> init() async {
    if (_ready) {
      return;
    }
    if (Env.supabaseConfigured) {
      try {
        await Supabase.initialize(
          url: Env.supabaseUrl,
          publishableKey: Env.supabaseAnonKey,
        );
        client = Supabase.instance.client;
      } catch (error) {
        initError = error.toString();
        client = null;
      }
    }
    auth = AuthController(client);
    health = HealthRepository(client);
    _ready = true;
  }
}
