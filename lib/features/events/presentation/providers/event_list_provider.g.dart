// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<
          EventRepositoryImpl,
          EventRepositoryImpl,
          EventRepositoryImpl
        >
    with $Provider<EventRepositoryImpl> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EventRepositoryImpl create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepositoryImpl>(value),
    );
  }
}

String _$eventRepositoryHash() => r'f5a1a5353af32316ab797541b7701d4295888ddc';

@ProviderFor(getPublishedEvents)
final getPublishedEventsProvider = GetPublishedEventsProvider._();

final class GetPublishedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventEntity>>,
          List<EventEntity>,
          FutureOr<List<EventEntity>>
        >
    with
        $FutureModifier<List<EventEntity>>,
        $FutureProvider<List<EventEntity>> {
  GetPublishedEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPublishedEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPublishedEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventEntity>> create(Ref ref) {
    return getPublishedEvents(ref);
  }
}

String _$getPublishedEventsHash() =>
    r'e94a72079f803fd2ca467c950fefe9f168ba3d98';
