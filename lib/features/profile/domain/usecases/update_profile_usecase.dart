// lib/features/profile/domain/usecases/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, ProfileEntity> {
  final IProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ProfileEntity profile) async {
    // Business rule: Phone must be 10 digits
    if (profile.phone.length != 10) {
      return const Left(ValidationFailure('Phone number must be exactly 10 digits'));
    }
    
    // Business rule: Name cannot be empty
    if (profile.name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    return await repository.updateProfile(profile);
  }
}
