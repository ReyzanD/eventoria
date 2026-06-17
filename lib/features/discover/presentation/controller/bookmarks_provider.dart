import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookmarkedIdsProvider =
    NotifierProvider<BookmarkedIdsNotifier, Set<String>>(
  BookmarkedIdsNotifier.new,
);

class BookmarkedIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = Set.of(state)..remove(id);
    } else {
      state = Set.of(state)..add(id);
    }
  }
}
