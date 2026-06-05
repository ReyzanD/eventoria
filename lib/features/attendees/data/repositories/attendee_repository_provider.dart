import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'attendee_repository_impl.dart';
import '../../domain/repositories/attendee_repository.dart';
import '../../../../core/network/supabase_config.dart';

part 'attendee_repository_provider.g.dart';

@riverpod
AttendeeRepository getAttendeeRepository(Ref ref) {
  final supabaseClient = ref.watch(supabaseProvider);

  return AttendeeRepositoryImpl(supabaseClient);
}
