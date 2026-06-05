import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
}

@riverpod
class AuthController extends _$AuthController {
  late final AuthRepository _repository;

  @override
  Future<ProfileEntity?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final result = await _repository.getCurrentProfile();
    return result.fold((failure) => null, (profile) => profile);
  }

  Future<void> login(
    String email,
    String password, {
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signIn(email: email, password: password);

    result.fold((failure) {
      onError(failure.message);
      state = AsyncValue.error(failure.message, StackTrace.current);
    }, (profile) => state = AsyncValue.data(profile));
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required Function(String) onError,
    required VoidCallback onSuccess,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );

    result.fold(
      (failure) {
        onError(failure.message);
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (profile) {
        state = AsyncValue.data(profile);
        onSuccess();
      },
    );
  }

  Future<void> logout({required Function(String) onError}) async {
    state = const AsyncValue.loading();
    final result = await _repository.signOut();

    result.fold((failure) {
      onError(failure.message);
      state = AsyncValue.error(failure.message, StackTrace.current);
    }, (_) => state = const AsyncValue.data(null));
  }
}
