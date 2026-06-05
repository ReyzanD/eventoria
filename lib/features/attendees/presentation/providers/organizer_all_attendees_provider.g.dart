// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_all_attendees_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrganizerAllAttendeesController)
final organizerAllAttendeesControllerProvider =
    OrganizerAllAttendeesControllerProvider._();

final class OrganizerAllAttendeesControllerProvider
    extends
        $AsyncNotifierProvider<
          OrganizerAllAttendeesController,
          List<OrganizerAllAttendeeItem>
        > {
  OrganizerAllAttendeesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizerAllAttendeesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizerAllAttendeesControllerHash();

  @$internal
  @override
  OrganizerAllAttendeesController create() => OrganizerAllAttendeesController();
}

String _$organizerAllAttendeesControllerHash() =>
    r'b19512abd9a08eb4742afe48fd692114f19b15a9';

abstract class _$OrganizerAllAttendeesController
    extends $AsyncNotifier<List<OrganizerAllAttendeeItem>> {
  FutureOr<List<OrganizerAllAttendeeItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<OrganizerAllAttendeeItem>>,
              List<OrganizerAllAttendeeItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OrganizerAllAttendeeItem>>,
                List<OrganizerAllAttendeeItem>
              >,
              AsyncValue<List<OrganizerAllAttendeeItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
