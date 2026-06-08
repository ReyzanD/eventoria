// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_tickets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyTicketsController)
final myTicketsControllerProvider = MyTicketsControllerProvider._();

final class MyTicketsControllerProvider
    extends $AsyncNotifierProvider<MyTicketsController, List<TicketEntity>> {
  MyTicketsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTicketsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTicketsControllerHash();

  @$internal
  @override
  MyTicketsController create() => MyTicketsController();
}

String _$myTicketsControllerHash() =>
    r'4ac820c9b544394f9d20bcb5755855533d7eb672';

abstract class _$MyTicketsController
    extends $AsyncNotifier<List<TicketEntity>> {
  FutureOr<List<TicketEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TicketEntity>>, List<TicketEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TicketEntity>>, List<TicketEntity>>,
              AsyncValue<List<TicketEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
