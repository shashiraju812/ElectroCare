// test/features/profile/domain/usecases/update_profile_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:electrical_shop_app/features/profile/domain/entities/profile_entity.dart';
import 'package:electrical_shop_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:electrical_shop_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:electrical_shop_app/core/error/failures.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late UpdateProfileUseCase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateProfileUseCase(mockRepository);
  });

  const tProfile = ProfileEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    phone: '1234567890',
    initials: 'TU',
    isVerified: true,
    rating: 5.0,
    totalJobs: 10,
  );

  test('should call updateProfile on the repository when validation passes', () async {
    // arrange
    when(() => mockRepository.updateProfile(any()))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tProfile);

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.updateProfile(tProfile)).called(1);
  });

  test('should return ValidationFailure when phone number is not 10 digits', () async {
    // arrange
    final invalidProfile = tProfile.copyWith(phone: '123');

    // act
    final result = await usecase(invalidProfile);

    // assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have returned a failure'),
    );
    verifyNever(() => mockRepository.updateProfile(any()));
  });

  test('should return ValidationFailure when name is empty', () async {
    // arrange
    final invalidProfile = tProfile.copyWith(name: '');

    // act
    final result = await usecase(invalidProfile);

    // assert
    expect(result.isLeft(), true);
    verifyNever(() => mockRepository.updateProfile(any()));
  });
}

// Helper to allow mocktail to handle ProfileEntity
class FakeProfileEntity extends Fake implements ProfileEntity {}

void setupFallbackValues() {
  registerFallbackValue(FakeProfileEntity());
}
