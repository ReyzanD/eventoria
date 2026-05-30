import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:eventoria/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:eventoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventoria/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventoria/features/auth/domain/entities/profile_entity.dart';
import 'package:eventoria/core/errors/failures.dart';

class MockAuthRepository implements AuthRepository {
  bool signUpCalled = false;
  late String capturedEmail;
  late UserRole capturedRole;

  @override
  Future<Either<Failure, ProfileEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required DateTime createdAt,
  }) async {
    signUpCalled = true;
    capturedEmail = email;
    capturedRole = role;

    return Right(
      ProfileEntity(
        id: 'mock-uuid-12345',
        fullName: fullName,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, ProfileEntity>> signIn({
    required String email,
    required String password,
  }) async => Left(ServerFailure('Not implemented'));
  @override
  Future<Either<Failure, ProfileEntity?>> getCurrentProfile() async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
}

void main() {
  testWidgets(
    'Should validate input fields, select Organizer role, and submit registration successfully',
    (WidgetTester tester) async {
      final mockRepository = MockAuthRepository();

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
          child: const MaterialApp(home: SignUpScreen()),
        ),
      );

      // 1. Initial Render Verification
      expect(find.text('Create Account'), findsOneWidget);

      // 2. Fill text form fields FIRST (before triggering validation)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Reyzan Developer',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'reyzan@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'securepassword123',
      );
      await tester.pumpAndSettle();

      // 3. Change role to Organizer (tap the Organizer card)
      final organizerOption = find.text('Organizer');
      expect(organizerOption, findsOneWidget);
      await tester.tap(organizerOption);
      await tester.pumpAndSettle();

      // 4. Submit valid registration form
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // 5. Final Repository Assertions
      expect(mockRepository.signUpCalled, isTrue);
      expect(mockRepository.capturedEmail, equals('reyzan@example.com'));
      expect(mockRepository.capturedRole, equals(UserRole.organizer));
    },
  );
}
