class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nnpmazxlephuxsmezhyo.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ucG1henhsZXBodXhzbWV6aHlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM4MDM4MzksImV4cCI6MjEwOTM3OTgzOX0.e41jFLdpxD0RskwPD2chidOkGO9-qiDR8H5SRbs2rrY',
  );

  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
