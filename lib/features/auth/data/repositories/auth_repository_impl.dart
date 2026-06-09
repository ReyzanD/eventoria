import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  UserRole _parseUserRole(dynamic value) {
    final role = (value ?? 'attendee').toString().toLowerCase().trim();

    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'organizer':
        return UserRole.organizer;
      case 'attendee':
      default:
        return UserRole.attendee;
    }
  }

  ProfileModel _buildFallbackProfile({
    required supabase.User user,
    required String fallbackEmail,
  }) {
    final rawMetadata = user.userMetadata ?? {};

    return ProfileModel(
      id: user.id,
      fullName: (rawMetadata['full_name'] as String?) ?? 'Venu User',
      email: user.email ?? fallbackEmail,
      avatarUrl: rawMetadata['avatar_url'] as String?,
      role: _parseUserRole(rawMetadata['role']),
      createdAt: DateTime.now(),
      isVerified: false,
    );
  }

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
        return const Left(AuthFailure('Sign up failed'));
      }

      final localProfile = ProfileModel(
        id: response.user!.id,
        fullName: fullName,
        email: email,
        avatarUrl: null,
        role: role,
        createdAt: createdAt,
        isVerified: false,
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
      debugPrint('SIGNIN: start');
      developer.log('SIGNIN: start');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('SIGNIN: auth success');
      developer.log('SIGNIN: auth success');
      final user = response.user;
      debugPrint('SIGNIN: user id = ${user?.id}');
      developer.log('SIGNIN: user id = ${user?.id}');
      if (user == null) {
        return const Left(AuthFailure('User not found'));
      }
      debugPrint('SIGNIN: before profiles query');
      developer.log('SIGNIN: before profiles query');
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      debugPrint('SIGNIN: profiles query success');
      debugPrint('SIGNIN profileData: $profileData');
      developer.log('SIGNIN: profiles query success');
      developer.log('SIGNIN profileData: $profileData');
      final mergedProfileData = {
        ...profileData,
        'email': profileData['email'] ?? user.email ?? email,
      };
      return Right(ProfileModel.fromJson(mergedProfileData));
    } on supabase.AuthException catch (e, st) {
      debugPrint('SIGNIN AuthException: ${e.message}');
      debugPrintStack(stackTrace: st);
      developer.log('SIGNIN AuthException: ${e.message}', stackTrace: st);
      return Left(AuthFailure(e.message));
    } on supabase.PostgrestException catch (e, st) {
      debugPrint('SIGNIN PostgrestException: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrintStack(stackTrace: st);
      developer.log(
        'SIGNIN PostgrestException: ${e.message}, code=${e.code}, details=${e.details}, hint=${e.hint}',
        stackTrace: st,
      );
      return Left(AuthFailure('Profile query failed: ${e.message}'));
    } catch (e, st) {
      debugPrint('SIGNIN unexpected error: $e');
      debugPrintStack(stackTrace: st);
      developer.log('SIGNIN unexpected error: $e', stackTrace: st);
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getCurrentProfile() async {
    try {
      debugPrint('GET_PROFILE: start');
      developer.log('GET_PROFILE: start');
      final user = _client.auth.currentUser;
      debugPrint('GET_PROFILE: current user = ${user?.id}');
      developer.log('GET_PROFILE: current user = ${user?.id}');
      if (user == null) {
        return const Right(null);
      }
      debugPrint('GET_PROFILE: before profiles query');
      developer.log('GET_PROFILE: before profiles query');
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      debugPrint('GET_PROFILE: profiles query success');
      debugPrint('GET_PROFILE profileData: $profileData');
      developer.log('GET_PROFILE: profiles query success');
      developer.log('GET_PROFILE profileData: $profileData');
      final mergedProfileData = {
        ...profileData,
        'email': profileData['email'] ?? user.email ?? '',
      };
      return Right(ProfileModel.fromJson(mergedProfileData));
    } on supabase.PostgrestException catch (e, st) {
      debugPrint('GET_PROFILE PostgrestException: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrintStack(stackTrace: st);
      developer.log(
        'GET_PROFILE PostgrestException: ${e.message}, code=${e.code}, details=${e.details}, hint=${e.hint}',
        stackTrace: st,
      );
      return Left(AuthFailure('Current profile query failed: ${e.message}'));
    } catch (e, st) {
      debugPrint('GET_PROFILE unexpected error: $e');
      debugPrintStack(stackTrace: st);
      developer.log('GET_PROFILE unexpected error: $e', stackTrace: st);
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
