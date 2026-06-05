import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_config.g.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;
}

// --- ADD THIS RIVERPOD PROVIDER BENEATH YOUR CLASS ---
@riverpod
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}
