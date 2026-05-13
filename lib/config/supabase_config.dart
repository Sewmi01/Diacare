import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.maybeGet("SUPABASE_URL") ?? "";
  static String get anonKey => dotenv.maybeGet("SUPABASE_ANON_KEY") ?? "";
  static String get reportsBucket =>
      dotenv.maybeGet("SUPABASE_REPORTS_BUCKET") ?? "patient-reports";

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
