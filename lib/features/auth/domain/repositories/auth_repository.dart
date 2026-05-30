import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, ProfileEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required DateTime createdAt,
  });

  Future<Either<Failure, ProfileEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, ProfileEntity?>> getCurrentProfile();
  Future<Either<Failure, void>> signOut();
}
