// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendee_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAttendeeRepository)
final getAttendeeRepositoryProvider = GetAttendeeRepositoryProvider._();

final class GetAttendeeRepositoryProvider
    extends
        $FunctionalProvider<
          AttendeeRepository,
          AttendeeRepository,
          AttendeeRepository
        >
    with $Provider<AttendeeRepository> {
  GetAttendeeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAttendeeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAttendeeRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendeeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendeeRepository create(Ref ref) {
    return getAttendeeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendeeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendeeRepository>(value),
    );
  }
}

String _$getAttendeeRepositoryHash() =>
    r'b21ade60dcffb84e3b04284b3d047fd5e9402a57';
