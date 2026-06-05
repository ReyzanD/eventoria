// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventTiers)
final eventTiersProvider = EventTiersFamily._();

final class EventTiersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TicketModel>>,
          List<TicketModel>,
          FutureOr<List<TicketModel>>
        >
    with
        $FutureModifier<List<TicketModel>>,
        $FutureProvider<List<TicketModel>> {
  EventTiersProvider._({
    required EventTiersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventTiersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventTiersHash();

  @override
  String toString() {
    return r'eventTiersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TicketModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TicketModel>> create(Ref ref) {
    final argument = this.argument as String;
    return eventTiers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventTiersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventTiersHash() => r'da08458d9c30a9cf2bef6e97cde3bb4b8cc3a718';

final class EventTiersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TicketModel>>, String> {
  EventTiersFamily._()
    : super(
        retry: null,
        name: r'eventTiersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventTiersProvider call(String eventId) =>
      EventTiersProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventTiersProvider';
}

@ProviderFor(TicketBookingController)
final ticketBookingControllerProvider = TicketBookingControllerProvider._();

final class TicketBookingControllerProvider
    extends $NotifierProvider<TicketBookingController, AsyncValue<void>> {
  TicketBookingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ticketBookingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ticketBookingControllerHash();

  @$internal
  @override
  TicketBookingController create() => TicketBookingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$ticketBookingControllerHash() =>
    r'43ca84b34369a0dd54458f978e3f24894df18c86';

abstract class _$TicketBookingController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
