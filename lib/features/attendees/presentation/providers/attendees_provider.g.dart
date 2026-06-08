// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendees_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AttendeesController)
final attendeesControllerProvider = AttendeesControllerFamily._();

final class AttendeesControllerProvider
    extends $NotifierProvider<AttendeesController, AttendeesState> {
  AttendeesControllerProvider._({
    required AttendeesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendeesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendeesControllerHash();

  @override
  String toString() {
    return r'attendeesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AttendeesController create() => AttendeesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendeesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendeesState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AttendeesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendeesControllerHash() =>
    r'1f4fd94caf0697dd69e22a508843d279be9c972c';

final class AttendeesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AttendeesController,
          AttendeesState,
          AttendeesState,
          AttendeesState,
          String
        > {
  AttendeesControllerFamily._()
    : super(
        retry: null,
        name: r'attendeesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AttendeesControllerProvider call(String eventId) =>
      AttendeesControllerProvider._(argument: eventId, from: this);

  @override
  String toString() => r'attendeesControllerProvider';
}

abstract class _$AttendeesController extends $Notifier<AttendeesState> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  AttendeesState build(String eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AttendeesState, AttendeesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AttendeesState, AttendeesState>,
              AttendeesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
