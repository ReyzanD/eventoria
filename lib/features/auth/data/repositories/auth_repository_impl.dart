import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;
  AuthRepositoryImpl(this._client);

  @override
  Future<Either<Failure, ProfileEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required DateTime createdAt,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role.name},
      );

      if (response.user == null) {
        return Left(AuthFailure('Sign up failed'));
      }

      final localProfile = ProfileModel(
        id: response.user!.id,
        fullName: fullName,
        email: email,
        avatarUrl: null,
        role: role,
        createdAt: DateTime.now(),
      );

      return Right(localProfile);
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const Left(AuthFailure('User Not Found'));
      }

      try {
        // Try parsing database record first
        final profileData = await _client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
        return Right(ProfileModel.fromJson(profileData));
      } catch (dbError) {
        // FALLBACK: Parse from metadata tokens if Postgres parsing acts up
        final rawMetadata = response.user!.userMetadata ?? {};
        final String rawRole = (rawMetadata['role'] ?? 'attendee')
            .toString()
            .toLowerCase();

        final fallbackProfile = ProfileModel(
          id: response.user!.id,
          fullName: rawMetadata['full_name'] ?? 'Venu User',
          email: response.user!.email ?? email,
          role: rawRole.contains('organizer')
              ? UserRole.organizer
              : UserRole.attendee,
          avatarUrl: rawMetadata['avatar_url'],
          createdAt: DateTime.now(),
        );
        return Right(fallbackProfile);
      }
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getCurrentProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Right(null);

      try {
        final profileData = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        return Right(ProfileModel.fromJson(profileData));
      } catch (dbError) {
        // FALLBACK: Keep persistent sessions active even if database query encounters latency
        final rawMetadata = user.userMetadata ?? {};
        final String rawRole = (rawMetadata['role'] ?? 'attendee')
            .toString()
            .toLowerCase();

        final fallbackProfile = ProfileModel(
          id: user.id,
          fullName: rawMetadata['full_name'] ?? 'Venu User',
          email: user.email ?? '',
          role: rawRole.contains('organizer')
              ? UserRole.organizer
              : UserRole.attendee,
          avatarUrl: rawMetadata['avatar_url'],
          createdAt: DateTime.now(),
        );
        return Right(fallbackProfile);
      }
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
