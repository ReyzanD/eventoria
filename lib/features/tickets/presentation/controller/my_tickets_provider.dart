import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../data/repositories/ticket_repository_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'my_tickets_provider.g.dart';

@riverpod
class MyTicketsController extends _$MyTicketsController {
  @override
  Future<List<TicketEntity>> build() async {
    // 1. Get the current logged-in user from your auth provider
    final profile = await ref.watch(authControllerProvider.future);

    if (profile == null) {
      return []; // Return an empty list if not logged in
    }

    // 2. Get the ticket repository
    final repository = ref.watch(getTicketRepositoryProvider);

    // 3. Fetch and return the tickets using the method we just wrote!
    return repository.getMyTickets(profile.id);
  }

  // A helper method for pull-to-refresh
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
