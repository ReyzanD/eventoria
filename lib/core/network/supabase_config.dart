import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Pull variables out of the loaded .env file map keys
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;
}
