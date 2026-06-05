import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'ticket_repository_impl.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../../../core/network/supabase_config.dart';

part 'ticket_repository_provider.g.dart';

@riverpod
TicketRepository getTicketRepository(Ref ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return TicketRepositoryImpl(supabaseClient);
}
